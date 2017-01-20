local Controllbar = class("Controllbar", function()
    return display.newNode()
end)


function Controllbar:ctor(info)
    local ccbFile = "view/shared_ctlbtn.ccbi"
    local layer  = CCBReaderLoad(ccbFile, self)
    self:addChild(layer)
    self:setNodeEventEnabled(true)
    self.lists = info.players
    self.info = info.info --roomId gameId mysite

    self:addNodeEventListener(cc.NODE_TOUCH_EVENT,handler(self, self.onTouch_))

    self:Layout(info.animation)
end

function Controllbar:onTouch_(event)

    if event.name == "began" then
        print("GameController began")
    elseif event.name == "ended" then
        
    end

    return true
end

function Controllbar:updateUILabel(event)

    local model = app:getUserModel()
    local cls   =   model.class

    local properties = model:getProperties({
            cls.name, 
            cls.level, 
            cls.exp, 
            cls.vipLevel, 
            cls.vipPoint, 
            cls.coins, 
            cls.gems, 
            cls.pictureId,
            cls.hasnews})

    if properties[cls.hasnews] == 1 then
        self.messageHint:setVisible(true)
    else
        self.messageHint:setVisible(false)
    end

    if properties[cls.name] then
        self.userName:setString(tostring(properties[cls.name]))
    end

    if properties[cls.level] then
        self.levelLabel:setString(tostring(properties[cls.level]))
    end

    if properties[cls.exp] then
        self.expLabel:setString(tostring(properties[cls.exp]))
    end

    local pc1, pc2, levelup = self:getTwoPercentage(properties[cls.exp], properties[cls.level])

    if pc1 ~= pc2 and event then
        self:setExpProgress(pc1, pc2, levelup, 1)
    end


    local images = {}
    local image=HEAD_IMAGE[properties[cls.pictureId]]

    print("imageimageimage", image)

    images.n=image
    images.s=image
    images.d=image
    
    core.displayEX.setButtonImages(self.btn_headImage, images)
end

function Controllbar:initButton()

    -- on menus
    core.displayEX.newButton(self.btn_menus) 
        :onButtonClicked(function(event)
            if self.menus_node:isVisible() == true then
                self.menus_node:setVisible(false)
            else
                self.menus_node:setVisible(true)
            end
        end)

    -- on message
    core.displayEX.newButton(self.btn_message) 
        :onButtonClicked(function(event)
            net.MessageCS:getMessageList(function(body)
                scn.ScnMgr.popView("MessageView",body)
            end)

        end)

    -- on lobby
    core.displayEX.newButton(self.btn_lobby) 
        :onButtonClicked(function(event)
            scn.ScnMgr.replaceScene("lobby.LobbyScene", nil, true)

        end)

    -- on setting
    core.displayEX.newButton(self.btn_option)
        :onButtonClicked(function(event)
            scn.ScnMgr.popView("SettingView")
        end)

    -- on achievement
    core.displayEX.newButton(self.btn_achievement) 
        :onButtonClicked(function(event)
            scn.ScnMgr.popView("FriendInforView",{tabidx=4})
        end)

    -- on head
    core.displayEX.newButton(self.btn_headImage) 
        :onButtonClicked(function(event)
            scn.ScnMgr.popView("FriendInforView")
        end)

    core.displayEX.newButton(self.btn_vip) 
        :onButtonClicked(function(event)

            scn.ScnMgr.popView("VipView")

        end)

    core.displayEX.newButton(self.btn_shop_coin) 
        :onButtonClicked(function(event)

            net.PurchaseCS:GetProductList(function(lists)
               scn.ScnMgr.popView("ProductsView",{productList=lists,tabidx=1})
            end)

        end)

    core.displayEX.newButton(self.btn_shop_gem) 
        :onButtonClicked(function(event)

            net.PurchaseCS:GetProductList(function(lists)
               scn.ScnMgr.popView("ProductsView",{productList=lists,tabidx=2})
            end)

        end)
        
    -- on chat
    core.displayEX.newButton(self.chatbtn) 
        :onButtonClicked(function(event)
            scn.ScnMgr.popView("ChatView")
        end)   


    -- on allplayer
    core.displayEX.newButton(self.btn_allplayer) 
        :onButtonClicked(function(event)

            if self.left_pnode:isVisible() == true then
                self.left_pnode:setVisible(false)
            else
                self.left_pnode:setVisible(true)
            end

            if self.right_pnode:isVisible() == true then
                self.right_pnode:setVisible(false)
            else
                self.right_pnode:setVisible(true)
            end

        end)

end

function Controllbar:initExp()
    local model = app:getUserModel()

    local exp = model:getExp()
    local lvl = model:getLevel()

    -- expProgress
    local expX,expY = self.expSprite:getPosition()
    local parent = self.expSprite:getParent()
    
    self.expSprite:removeFromParent(false)

    self.expProgress = display.newProgressTimer(self.expSprite, display.PROGRESS_TIMER_BAR)
        :pos(expX, expY)
        :addTo(parent)

    self.expProgress:setMidpoint(cc.p(0, 0))
    self.expProgress:setBarChangeRate(cc.p(1, 0))

    local pc1, pc2, levelup= self:getTwoPercentage(exp, lvl)
    self.expProgress:setPercentage(pc2)

end

function Controllbar:setExpProgress( from, to, levelup, time)
    
    if time == nil then time = 1 end

    if levelup == true then

        local fromTo1 = cca.progressFromTo(time, from, 100)
        local fromTo2 = cca.progressFromTo(time, 0, to)

        local complete = function()
            self.expProgress:setPercentage(0)
        end
        local callfun = cc.CallFunc:create(complete)

        local seq = cc.Sequence:create(fromTo1, callfun, fromTo2)

        self.expProgress:runAction(seq)

        print(from, 100, to)

    else

        local fromTo = cca.progressFromTo(time, from, to)
        local seq = cc.Sequence:create(fromTo)
        self.expProgress:runAction(seq)

    end

end

function Controllbar:getTwoPercentage(exp, lvl)

    local nextlvl = lvl + 1

    local pc1 = self.expProgress:getPercentage()
    local lexp = tonumber(getLevelExpByLevel(nextlvl))

    local pc2 = 100 * exp / lexp

    local pastlevel = tonumber(self.levelLabel:getString())
    local levelup = false

    if lvl > pastlevel then levelup = true end

    return pc1, pc2, levelup
end

function Controllbar:initPlayers()
    -- body

    local getPlayer = function(idx)
        -- body
        for i=1,#self.lists do
            local player = self.lists[i]
            
            local playersiteId = player.siteId
            if playersiteId > self.info.mysite then
                playersiteId = playersiteId - 1
            end

            if idx == playersiteId  then
                return player
            end
        end
        return nil
    end

    for i=1,6 do
        local player = getPlayer(i)
        
        local headnode = self["headportrait_pg_"..tostring(i)]
        local parent = headnode:getParent()
        local x,y = headnode:getPosition()

        local pnode = display.newNode()

        if i > 3 then
            pnode.side = 2
        else
            pnode.side = 1
        end

        if player then
            self["players"..tostring(player.siteId)] = pnode
            pnode.siteId = player.siteId
        end

        pnode:setPosition(cc.p(x,y))

        parent:addChild(pnode)

        self:initPlayerSet(pnode, player)

        headnode:removeFromParent(true)

    end        

end

function Controllbar:initPlayerSet(pnode, player)
    local images = {
            normal = "#btn_invite_tx_n.png",
            pressed = "#btn_invite_tx_s.png",
            disabled = "#btn_invite_tx_d.png",
        }


    local btn = cc.ui.UIPushButton.new(images, {scale9 = false})
        :align(display.CENTER, x, y)
        :addTo(pnode)


    if player ~= nil then

        local cell  = CCBuilderReaderLoad("view/share_head.ccbi", self)
        cell.name = self.name
        cell.head = self.head
        cell.pid = player.pid
        cell.name:setString(player.name)
        cell.head:setSpriteFrame(HEAD_IMAGE[player.pictureId])
        cell:setScale(0.65)
        pnode:addChild(cell)

        btn:onButtonClicked(function(event)

            local function onComplete(infos)                
                scn.ScnMgr.popView("FriendInforView",{info=infos})
            end

            net.UserCS:getPlayerInfo(cell.pid, onComplete)
      
        end)

    else

        btn:onButtonClicked(function(event)

            local function onComplete(lists)
                local gameinfo = {
                    friendlists = lists,
                    gameId = self.info.gameId,
                    roomId = self.info.roomId,
                    siteId = pnode.siteId
                }
                print("invite site:", pnode.siteId)
                scn.ScnMgr.popView("IniteFriendPlayView", gameinfo)
            end
            net.FriendsCS:getFriendsList(onComplete)

        end)

    end
end

function Controllbar:updatePlayersStates(event)
    local playerList = event.playerList
    for i=1,#playerList do
        local player = playerList[i]

        local playersiteId = player.siteId
        if playersiteId > self.info.mysite then
            playersiteId = playersiteId - 1
        end

        print("playersiteId",playersiteId)

        local pnode = self["players"..tostring(playersiteId)]

        pnode:removeAllChildren()
        local x,y = pnode:getPosition()

        if player.notifyType == 1 then
            self:initPlayerSet(pnode, player)
        elseif player.notifyType == 2 then
            self:initPlayerSet(pnode)
        elseif player.notifyType == 3 then
        elseif player.notifyType == 4 then
        end

    end
end

function Controllbar:registChatEvent()

    print("Controllbar:registChatEvent")
    -- body
    core.SocketNet:registEvent(GC_CHAT_MESSAGE, function(body)
        -- body
        local msg = Chat_pb.GCChatMessage()
        msg:ParseFromString(body)

        print(tostring(msg))

        local node = self["players"..tostring(msg.siteId)]

        if node then

            local talign = cc.TEXT_ALIGNMENT_RIGHT
            local anpt = 1.0

            if node.side == 1 then
                anpt = 0
                talign = cc.TEXT_ALIGNMENT_RIGHT
            elseif node.side == 2 then
                anpt = 1
                talign = cc.TEXT_ALIGNMENT_LEFT
            end

            local label = display.newTTFLabel({
                text = value,
                font = "Arial",
                color = cc.c3b(255, 255, 255),
                size = 32,
                align = talign
            })

            label:setAnchorPoint(anpt, 0.5)

            label:setString(msg.content)

            node:addChild(label)

            transition.fadeOut(label, {time = 0.5,delay = 2.0,
                onComplete = function()
                    label:removeFromParent(true)
                end}
            )

        else

            local label = display.newTTFLabel({
                text = value,
                font = "Arial",
                color = cc.c3b(255, 255, 255),
                size = 32,
                align = cc.TEXT_ALIGNMENT_CENTER
            })

            label:setPosition(display.cx, 150)

            label:setString(msg.content)

            self:addChild(label)

            transition.fadeOut(label, {time = 0.5,delay = 2.0,
                onComplete = function()
                    label:removeFromParent(true)
                end}
            )

        end

    end)
end

function Controllbar:updateWinCoinLabel( value )
    self.winCoinsLabel:setString(value)
end


function Controllbar:updateTTBet( value )
    self.totalBetLabel:setString(value)
end


function Controllbar:updateGems( value )
    self.totalGemsLabel:setString(value)
end

function Controllbar:updateNotice(event)
    local model = app:getUserModel()
    local cls = model.class
    local properties = model:getProperties({cls.noticeSign})

    if properties[cls.noticeSign] == 1 then
        self.messageHint:setVisible(event.hasnews)

        model:setProperties({hasnews=tonumber(event.hasnews)})
        model:serializeModel()
    end
end

function Controllbar:showDouble()

end

function Controllbar:hideDouble()

end


function Controllbar:addSmallWinEff(eff)

end


function Controllbar:upTTCoinsByStep(value)
	local frNum = tonumber(self.totalCoinsLabel:getString())
	--SlotsMgr.setLabelStepCounter(self.totalCoinsLabel, frNum, value, 0.5)
end


function Controllbar:setTTCoins(value)
	--SlotsMgr.stopLabelStepCounter(self.totalCoinsLabel)
	self.totalCoinsLabel:setString(value)
end


function Controllbar:upWinCoinsByStep(value)
    local frNum = tonumber(self.winCoinsLabel:getString())
	--SlotsMgr.setLabelStepCounter(self.winCoinsLabel, frNum, value, 0.5)
end

function Controllbar:setWinCoins(value)
	--SlotsMgr.stopLabelStepCounter(self.winCoinsLabel)
	self.winCoinsLabel:setString(value)
end


function Controllbar:onEnter()
    self:initExp()
    self:updateUILabel()
    self:initButton()
    self:initPlayers()
    self:registChatEvent()


    EventMgr:addEventListener(EventMgr.UPDATE_LOBBYUI_EVENT, handler(self, self.updateUILabel))
    EventMgr:addEventListener(EventMgr.SERVER_NOTICE_EVENT, handler(self, self.updateNotice))
    EventMgr:addEventListener(EventMgr.UPDATE_PSTATES_EVENT, handler(self, self.updatePlayersStates))

end


function Controllbar:onExit()
    EventMgr:removeEventListenersByEvent(EventMgr.UPDATE_LOBBYUI_EVENT)
    EventMgr:removeEventListenersByEvent(EventMgr.SERVER_NOTICE_EVENT)
    EventMgr:removeEventListenersByEvent(EventMgr.UPDATE_PSTATES_EVENT)

    core.SocketNet:unregistEvent(GC_GET_ONLINE_PLAYERS)
    self:removeAllChildren()
    collectgarbage("collect")
    net.GameCS:leaveGame()
end

return Controllbar
