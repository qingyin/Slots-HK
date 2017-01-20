local ChargeGiftCell = require("app.views.gift.ChargeGiftCell")
local CollectGiftCell = require("app.views.gift.CollectGiftCell")

local tabBase = require("app.views.TabBase")
local View = class("GiftsView", tabBase)

function View:ctor(args)
    -- local touchlayer = display.newColorLayer(cc.c4b(0, 0, 0, 200))
    -- self:addChild(touchlayer)
    -- touchlayer:setTouchSwallowEnabled(false)

    self:addChild(cc.LayerColor:create(cc.c4b(0, 0, 0, 200)))
    self:setNodeEventEnabled(true)
    self:setTouchEnabled(true)
    self:setTouchSwallowEnabled(true)

    self.viewNode  = CCBReaderLoad("lobby/present/givegifts.ccbi", self)
    self:addChild(self.viewNode)

    AnimationUtil.setContentSizeAndScale(self.viewNode)


    self.tabNum=2
    self.isAnimation = false

    if args.tabidx then
        self.selectedIdx = args.tabidx
    else
        self.selectedIdx = 1
    end
    self.data = args

    self:registerUIEvent()
    self:showTab(self.selectedIdx)
    self:init()
    

end

function View:init()
    self.freeGiftCoinValue:setString(DICT_GIFT["1"].item_cnt)
    self.freeGiftGemsValue:setString(DICT_GIFT["2"].item_cnt)
    if self.selectedIdx == 1 then
        self:showCollect()
    end
end

function View:registerUIEvent()
    self:addTabEvent(1,function()
        self:showCollect()
    end)

    self:addTabEvent(2,function()
        self:showTab(2)
    end)

    core.displayEX.newButton(self.freeGiftCoinBtn)
    self.freeGiftCoinBtn.clickedCall = function()
        self:selectFreeCoinGift()
    end

    core.displayEX.newButton(self.freeGiftGemsBtn)
    self.freeGiftGemsBtn.clickedCall = function()
        --self:selectFreeGemsGift()
        -- scn.ScnMgr.addView("CommonView",
        --     {
        --         title="Gift commingsoon",
        --         content="As soon as quickly is needed to unlock this gift"
        --     })
    end

    core.displayEX.newButton(self.inviteBtn)
    self.inviteBtn.clickedCall = function()
        self:inviteFaceBookFriends()
    end

    core.displayEX.newButton(self.closeBtn)
    self.closeBtn.clickedCall = function()
        scn.ScnMgr.removeView(self)
    end

    core.displayEX.newButton(self.gotoSendBtn)
    self.gotoSendBtn.clickedCall = function()
        --self:selectFreeCoinGift()
        self:showTab(2)
    end
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
            table.dump(invite, "invite")
            if invite.error_message then
            else

            end
        end)
    else
        scn.ScnMgr.addView("GiftsFBConnectView")
    end
end

function View:selectFreeCoinGift()
    if self.data.pid ~= nil then
        self:sendGift({{pid =self.data.pid}},DICT_GIFT["1"])
    else
        local islogin = core.FBPlatform.getIsLogin()
        if islogin then
            local function onComplete(plists)
                local list = {}
                for i = 1, #plists do
                    local item = plists[i]
                    if string.len(item.facebookId) > 0 then
                        list[#list + 1] = item
                    end
                end

                scn.ScnMgr.addView("social.FriendsSelectView",list,"1",DICT_GIFT["1"])
            end

            net.FriendsCS:getAllFriends(tonumber(1), onComplete)
        else
            scn.ScnMgr.addView("GiftsFBConnectView")
        end
    end
end

function View:sendGift(friends, gift)
    net.GiftsCS:sendGift(friends, tonumber(gift.gift_id), function( msg )
        if msg.result == 1 then
            local costCoins = msg.costCoins
            if tonumber(gift.gift_id) == 1 then --coins
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
end

function View:showCollect()
    self:showTab(1)

    local islogin = core.FBPlatform.getIsLogin()
    if islogin then
        self.no_gift_sprite:setVisible(false)
        self.gotoSendBtn:setVisible(false)
        if self.collectGiftsList == nil then
            net.GiftsCS:getGiftList(0, function(gifts)
                if #gifts > 0 then
                    self:updateCollectGiftList(gifts)
                else
                    self.no_gift_sprite:setVisible(true)
                    self.gotoSendBtn:setVisible(true)
                end
            end)
        else
            local items = self.collectGiftsList.items_
            if #items == 0 then
                self.collectGiftsList:removeFromParent(true)
                self.collectGiftsList = nil
                self.no_gift_sprite:setVisible(true)
                self.gotoSendBtn:setVisible(true)
            end
        end
    else
        self.no_gift_sprite:setVisible(true)
        self.gotoSendBtn:setVisible(true)
    end
end


function View:updateCollectGiftList(listData)
    local box = self.giftRect:getBoundingBox()
    self.collectGiftsList = cc.ui.UIListView.new {
        --bgColor = cc.c4b(200, 200, 200, 120),
        bg = nil,
        bgScale9 = false,
        viewRect = box,
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
        scrollbarImgV = nil}
    :onTouch(handler(self, self.onCollectListener))
    :addTo(self.tabPanel1)

    -- add items
    local listnum = #listData
    for i=1, listnum do
        local data = listData[i]
        local item = self.collectGiftsList:newItem()
        local cell = CollectGiftCell.new(data)
        --cell:setPositionX(60)
        local itemsize = cell:getContentSize()
        item:addContent(cell)
        item:setItemSize(itemsize.width, itemsize.height + 15)
        self.collectGiftsList:addItem(item)
    end
    self.collectGiftsList:reload()
end

function View:onCollectListener(event)
    if self.isAnimation then return end
    
    if "clicked" == event.name and event.item then
        local cell = event.item:getContent()
        local isclick = cell:checkClick(cc.p(event.x, event.y))
        --print("cell.data.id:", cell.data.id)
        if isclick then
            net.GiftsCS:receiveGift(cell.data.id,function( msg )
                if msg.result == 1 then
                    self.isAnimation = true
                    local handle = audio.playSound(RES_AUDIO.fly_coins, false)
                    local callback = function()
                        audio.stopSound(handle) 
                        self.isAnimation = false
                        local totalCoins = app:getUserModel():getCoins() + msg.rewardCoins
                        app:getUserModel():setCoins(totalCoins)

                        EventMgr:dispatchEvent({name  = EventMgr.UPDATE_LOBBYUI_EVENT})
                        self.collectGiftsList:removeItem(event.item,true)

                    end
                    --AnimationUtil.MoveTo("gold.png",10,cell.descText, app.coinSprite,callback)
                    AnimationUtil.flyTo("gold.png",10,cell.descText, app.coinSprite)
                    self:performWithDelay(callback, 1.5)
                end
            end)
        end
    elseif "moved" == event.name then
        self.bListViewMove = true
    elseif "ended" == event.name then
        self.bListViewMove = false
    else
        --print("event name:" .. event.name)
    end
end


return View