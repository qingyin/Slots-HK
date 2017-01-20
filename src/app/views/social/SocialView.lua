local FriendCell = require("app.views.social.FriendCell")

local tabBase = require("app.views.TabBase")

local View = class("SocialView", tabBase)

function View:ctor(args)
    self.viewNode  = CCBReaderLoad("lobby/social/social.ccbi", self)
    self:addChild(self.viewNode)
    self:setNodeEventEnabled(true)
   
    if args.tabidx then
        self.selectedIdx = args.tabidx
    else
        self.selectedIdx = 1
    end

    self.tabNum=2

    -- init status
    local islogin = core.FBPlatform.getIsLogin()
    if islogin then
        self.fbStatus:setVisible(not islogin)
        self.inviteStatus:setVisible(islogin)
    end

    self:registerUIEvent()
end

function View:registerUIEvent()

    self:addTabEvent(1,function()
        self:showFriends()
    end)

    self:addTabEvent(2,function()
        self:showPlayers()
    end)

    core.displayEX.newButton(self.closeBtn)
    self.closeBtn.clickedCall = function()
        scn.ScnMgr.removeView(self)
    end

    core.displayEX.newButton(self.fbBtn)
    self.fbBtn.clickedCall = function()
         self:connectFB()
    end

    core.displayEX.newButton(self.inviteBtn)
    self.inviteBtn.clickedCall = function()
        self:doInvite()
    end
end

function View:doInvite()
    local params = {
        message = "Play the casino game, go go!!!!",
        title   = "Invite friend & reward lots of coins",
    }

    core.FBPlatform:appRequest(params, function( ret, msg )
        local invite = json.decode(msg)
       -- table.dump(invite, "invite")
        if invite.error_message then
        else

        end
    end)
end

function View:showFriends(isUpdate)
    self:showTab(1)
    if isUpdate and self.friendList ~= nil then
        self.friendList:removeAllItems()
        self.friendList:removeSelf(true)
        self.friendList = nil
    end

    if  self.friendList == nil then
        local function onComplete(lists)

            print("friend num:", #lists)
            if 0 == #lists then
                self.infoTxt:setVisible(true)
            else
                self:addFriendList(lists)
            end
        end
        net.FriendsCS:getFriendsList(onComplete)
    end
end

function View:showPlayers()
    self:showTab(2)

    if self.pageView == nil then
        local function onComplete(lists)
            self:addPlayerList(lists)
        end
        net.FriendsCS:getOnlinePlayers(onComplete)
    end
end

function View:connectFB()
    local model = app:getObject("UserModel")
    local cls = model.class
    local properties = model:getProperties({cls.facebook})
    local fb = properties[cls.facebook]

    local facebookCallBack = function(ret, msg)
        fb[cls.fb.fbid]             = core.FBPlatform.getUid()
        fb[cls.fb.token]            = core.FBPlatform.getToken()

        local properties = {}
        properties[cls.facebook] = fb
        model:setProperties(properties)
        model:serializeModel()

        local properties = model:getProperties({cls.facebook})
        local fb = properties[cls.facebook]

        net.UserAuthCS:thirdLogin(fb[cls.fb.fbid], "name",
            function()
                local path = "/me/friends"
                local params = {fields="id"} -- @"id,name,first_name,last_name"

                if self.fbStatus then
                    self.fbStatus:setVisible(false)
                    self.inviteStatus:setVisible(true)
                end

                core.FBPlatform.requestAPI(path, plugin.FacebookAgent.HttpMethod.GET, params,
                    function( ret, msg )
                    -- body
                        local friends = json.decode(msg)
                        local fbs = ""
                        local idx = 1
                        --table.dump(friends, "friends")

                        for k,v in pairs(friends.data) do
                            if idx == 1 then
                                fbs = fbs..v.id
                            else
                                fbs = fbs..","..v.id
                            end
                            idx = idx + 1
                            print(k,v, v.id)
                        end

                        local function onComplete()
                            pcall(View.showFriends(self,true))
                        end
                        net.FriendsCS:addFacebookFriends(fbs, onComplete)
                    end
                )
            end
        )
        core.Waiting.logining = false
        core.Waiting.hide()
    end

    local permissions = "user_friends,user_photos,public_profile"
    core.FBPlatform.login(facebookCallBack, permissions)
end

local margin = 24

function View:addPlayerList(list)
    local container = self.playerRect:getParent()
    local box = self.playerRect:getBoundingBox()
    local c,r = 5,3
    self.pageView = cc.ui.UIPageView.new {
        viewRect = box,
        column = c, row = r,
    }
    :onTouch(handler(self, self.onPlayerlistListener))
    :addTo(container)

    local len = #list

    for i=1,len do
        local item = self.pageView:newItem()
        local cell = headViewClass.new({player=list[i],scale=1.4})
        cell:showGameName()
        cell:setTag(99)

        local itemsize = item:getContentSize()

        cell:setPositionX(itemsize.width/2)
        cell:setPositionY(itemsize.height/2)

        item:addChild(cell)
        self.pageView:addItem(item)
    end

    local pageNum,f = math.modf(len/(c*r))
    if f > 0 then pageNum = pageNum +1 end

    -- add indicators
    local x = -( margin * pageNum) / 2
    local y = -box.height/2 - 55

    self.indicator_ = display.newSprite(IMAGE_PNG.pageindacator_sel)
    self.indicator_:setPosition(x, y)
    self.indicator_.firstX_ = x

    for pageIndex = 1, pageNum do
        local icon = display.newSprite(IMAGE_PNG.pageindacator_bg)
        icon:setPosition(x, y)
        container:addChild(icon)
        x = x + margin
    end

    container:addChild(self.indicator_)

    self.pageView:reload()
end

function View:onPlayerlistListener(event)
   if "pageChange" ==  event.name then
       local x = self.indicator_.firstX_ + (self.pageView:getCurPageIdx() - 1) * margin
       transition.moveTo(self.indicator_, {x = x, time=0.1})
   elseif "clicked" == event.name then

        if event.item then
            local cell = event.item:getChildByTag(99)
            cell:onClickHead()
        end

   elseif "moved" == event.name then
       self.bListViewMove = true
   elseif "ended" == event.name then
       self.bListViewMove = false
   else
       --print("event name:" .. event.name)
   end
end

function View:addFriendList(list)

    local box = self.friendRect:getBoundingBox()
    self.friendList = cc.ui.UIListView.new {
        bg = nil,
        bgScale9 = false,
        viewRect = box,
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
        scrollbarImgV = nil}
        :onTouch(handler(self, self.onFriendlistListener))
    self.friendList:addTo(self.friendRect:getParent())

    -- add items
    local listnum = #list
    --listnum = 5
    for i=1, listnum do
        local data = list[i]
        local item = self.friendList:newItem()
        local cell = FriendCell.new(data)
        local itemsize = cell:getContentSize()
        item:addContent(cell)
        item:setItemSize(itemsize.width, itemsize.height+10)
        item:setTouchSwallowEnabled(false)
        self.friendList:addItem(item)
    end
    self.friendList:reload()
end


function View:onFriendlistListener(event)
    if "clicked" == event.name and event.item then
        local cell = event.item:getContent()
        cell:checkClick(cc.p(event.x, event.y))
    elseif "moved" == event.name then
        self.bListViewMove = true
    elseif "ended" == event.name then
        self.bListViewMove = false
    else
        --print("event name:" .. event.name)
    end
end


function View:onEnter()
    self:showFriends()
end

function View:onExit()
    self = {}
end

return View