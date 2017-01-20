--local FriendSelectedCell = require("app.views.social.FriendSelectedCell")

local View = class("FriendsSelectView", function()
    return core.displayEX.newSwallowEnabledNode()
end)

local cell_path = "lobby/social/select_player_cell.ccbi"

function View:ctor(list, giftType, gift)
    self.viewNode  = CCBReaderLoad("lobby/social/select_player.ccbi", self)
    self:addChild(self.viewNode)

    AnimationUtil.setContentSizeAndScale(self.viewNode)

    self.flist = list

    self.gift = gift
    self.giftType = giftType
    self:registerEvent()
    self:initUI()

end

function View:onRemove()
    scn.ScnMgr.removeView(self)
end

function View:registerEvent()
    core.displayEX.newSmallButton(self.btn_close)
        :onButtonClicked(function(event)
            self:onRemove()
        end)

    core.displayEX.newButton(self.btn_sendgifts)
        :onButtonClicked(function(event)
            self:doSend()
        end)

    core.displayEX.newButton(self.btn_invite)
        :onButtonClicked(function(event)
            self:inviteFaceBookFriends()
        end)

    core.displayEX.addSpriteEvent(self.off_select_all_sp,function()
        self:doChangeSelectAll()
    end)
end

function View:inviteFaceBookFriends()
    local islogin = core.FBPlatform.getIsLogin()
    if islogin then
        local params = {
            message = "Play the casino game, go go!!!!",
            title   = "Invite friend & reward lots of coins",
        }

        core.FBPlatform.appRequest(params, function( ret, msg )
            local invite = json.decode(msg)
            --table.dump(invite, "invite")
            if invite.error_message then
            else

            end
        end)
    else
        scn.ScnMgr.addView("GiftsFBConnectView")
    end
end

function View:doSend()
    local list = self:getSelected()
    if list ~= nil and #list > 0 then
        local giftId = tonumber(self.gift.gift_id)

        net.GiftsCS:sendGift(list, giftId, function( msg )
            if msg.result == 1 then
                local costCoins = msg.costCoins
                local costGems = msg.costGems
                if giftId == 1 then --coins
                    local totalCoins = app:getUserModel():getCoins() - costCoins
 
                    if totalCoins > 0 then
                        app:getUserModel():setCoins(totalCoins)
                    else
                        scn.ScnMgr.popView("ShortCoinsView")
                        return
                    end
                end
            
                EventMgr:dispatchEvent({name  = EventMgr.UPDATE_LOBBYUI_EVENT})
            end
        end)
        self:onRemove()
    else
        scn.ScnMgr.addView("CommonView",{title="Select None",content="select friends please!!!"})
    end
end


function View:doChangeSelectAll(event)
    if self.friendsList == nil then return end
    
    local allvisible = self.on_select_all_sp:isVisible()
    self.on_select_all_sp:setVisible(not allvisible)

    for i=1,#self.friendsList.items_ do
        local it = self.friendsList.items_[i]
        for j=1,#it.cells do
            local cell = it.cells[j]
            cell.on_select_sp:setVisible(not allvisible)
        end
    end
end

function View:initUI()
    self.on_select_all_sp:setVisible(false)
    if #self.flist > 0 then
        self:addFriendsList()
    end
end

function View:getSelected()
    if self.friendsList == nil then return end

    local selfriendlist = {}
    for i=1,#self.friendsList.items_ do
        local it = self.friendsList.items_[i]
        for j=1,#it.cells do
            local cell = it.cells[j]
            local visible = cell.on_select_sp:isVisible()
            if visible == true then
                selfriendlist[#selfriendlist + 1] = cell.info
            end
        end
    end
    return selfriendlist
end

function View:addFriendsList()
    self.rect = self.content_rect:getBoundingBox()
    self.friendsList = cc.ui.UIListView.new {
        bg = nil,
        bgScale9 = false,
        viewRect = self.rect,
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
        scrollbarImgV = nil}
        :onTouch(handler(self, self.onFriendslistListener))
        :addTo(self.content_rect:getParent())

    -- add items
    local idx = 1
    local rownum = math.ceil((#self.flist )/2)


    local facebookCallBack = function(event)
        local user = event.user
        local photo = event.photo
        
        if photo ~= nil and photo ~= "-1" and self.friendsList ~= nil then
            for i=1,#self.friendsList.items_ do
                local it = self.friendsList.items_[i]
                for j=1,#it.cells do
                    local cell = it.cells[j]
                    if cell ~= nil and cell.info.facebookId == event.photo.id then
                        if cell.head ~= nil and cell.headNode ~= nil then
                            local head = display.newSprite(photo.path)
                            local x,y = cell.head:getPosition()
                            head:setPosition(x,y)
                            cell.headNode:addChild(head)
                            cell.head:removeFromParent()
                        end
                    end
                end
            end
        end
    end
    CCAccountManager:sharedAccountManager():init("facebook")
    CCAccountManager:sharedAccountManager():postFBListenerLua(facebookCallBack)
    
    for i=1, rownum do

        local item = self.friendsList:newItem()
        local content = display.newNode()
        item.cells = {}

        local numCells = 2
        local size
        for cellidx = 1, numCells do
            local fdata = self.flist[(i-1) * numCells + cellidx]
            if fdata then
                --print("fdata.name", fdata.name)
                --print("fdata.facebookId:", fdata.facebookId)
                 local cellOwner = {}
                 local cell  = CCBReaderLoad(cell_path, cellOwner)
                
                size = cell:getContentSize()
                local posX = 5
                if cellidx == 1 then
                    posX = -size.width -5
                end

                cell.on_select_sp = cellOwner.on_select_sp
                cell.head = cellOwner.head
                cell.headNode = cellOwner.headNode
                cell.info = fdata

                cellOwner.name_text:setString(fdata.name)
                cellOwner.on_select_sp:setVisible(false)

                cell:setPositionX(posX)
                cell:setPositionY(-size.height/2)
                content:addChild(cell)
                cell.idx = idx
                item.cells[cellidx] = cell
            end
            idx = idx + 1
        end

        item:addContent(content)
        item:setItemSize(self.rect.width+10, size.height+10 )
        self.friendsList:addItem(item)

        --down photo
        for cellidx = 1, numCells do
            local fdata = self.flist[(i-1) * numCells + cellidx]
            if fdata then
                CCAccountManager:sharedAccountManager():downloadPhoto(fdata.facebookId)
            end
        end
        
    end

    self.friendsList:setDelegate(handler(self, self.friendsListDelegate))
    self.friendsList:reload()
end

function View:onFriendslistListener(event)
    if "clicked" == event.name and event.item then
        for i=1,#event.item.cells do
            local cell = event.item.cells[i]

            if cell:getCascadeBoundingBox():containsPoint(cc.p(event.x, event.y)) then
                local visible = cell.on_select_sp:isVisible()
                cell.on_select_sp:setVisible(not visible)
            end
        end

    elseif "moved" == event.name then
        self.bListViewMove = true
    elseif "ended" == event.name then
        self.bListViewMove = false
    else
        --print("event name:" .. event.name)
    end
end

function View:friendsListDelegate(listView, tag, idx)
    if cc.ui.UIListView.COUNT_TAG == tag then
    elseif cc.ui.UIListView.CELL_TAG == tag then
    else
    end
end

return View