
local WheelBonusOK = class("WheelBonusOK", function()
    return core.displayEX.newSwallowEnabledNode()
end)

function WheelBonusOK:ctor(args)
    self:addChild(cc.LayerColor:create(cc.c4b(0, 0, 0, 200)))
    self.viewNode  = CCBuilderReaderLoad(RES_CCBI.wheelbonus_tb, self)
    self:addChild(self.viewNode)
    self:setTouchEnabled(true)
    self:setNodeEventEnabled(true)
    self:setTouchSwallowEnabled(true)
    self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        return true
    end)

    if args.coins ~= nil then
        --self.coinsLabel:setString(tostring(args.coins))
    end
    
    if args.vipbet ~= nil then
        --self.vipLabel:setString(tostring(args.vipbet))
    end

    if args.callback ~= nil then
        self.callback = args.callback
    end

    local winCount = args.coins*args.vipbet
    
    --self.totalLabel:setString(tostring(winCount))

    app:getUserModel():setCoins(app:getUserModel():getCoins() + winCount)

    self.isAnimation = false
    self.totalLabel:setString("")
    self:performWithDelay(function()
        SlotsMgr.setLabelStepCounter(self.totalLabel, 0, winCount, 1.5)
        local handle = audio.playSound(RES_AUDIO.number, false)
        self:performWithDelay(function() 
            audio.stopSound(handle) 
            self.okBtn:setVisible(true)
            end,1.5)
    end,0.5)

    self:registerUIEvent()

end

function WheelBonusOK:registerUIEvent()
    core.displayEX.newButton(self.okBtn) 
        :onButtonClicked(function(event)
            if self.isAnimation then return end
            -- body
            self:flyCoins()
        end)

    self.okBtn:setVisible(false)

end

function WheelBonusOK:flyCoins()
    self.isAnimation = true
    local handle = audio.playSound(RES_AUDIO.fly_coins, false)
    local callback = function()
        audio.stopSound(handle)
        EventMgr:dispatchEvent({name  = EventMgr.UPDATE_LOBBYUI_EVENT})

        if self.callback ~= nil then
            self.callback()
        end

        scn.ScnMgr.removeView(self)
    end
    --AnimationUtil.MoveTo("gold.png",10,self.totalLabel, app.coinSprite,callback)
    AnimationUtil.flyTo("gold.png",10,self.totalLabel, app.coinSprite)
    self:performWithDelay(callback, 1.5)
end



function WheelBonusOK:onEnter()
end

function WheelBonusOK:onExit()
end

return WheelBonusOK
