

local LUV = class("VipExtraCoinsView",function()
    return display.newNode()
end)

function LUV:ctor(args)
    self:addChild(cc.LayerColor:create(cc.c4b(0, 0, 0, 200)))
    self:setNodeEventEnabled(true)
    self:setTouchEnabled(true)
    self:setTouchSwallowEnabled(true)

    local viewNode = CCBReaderLoad("view/vip_extracoinspack.ccbi",self)
    self:addChild(viewNode)


    AnimationUtil.setContentSizeAndScale(viewNode)

    self.vipCount = args.vipCount
    self.callback = args.callback

    self:initUI()
    self:registerUIEvent()

    self.coins_number:setString("")
    
    self:performWithDelay(function()
        SlotsMgr.setLabelStepCounter(self.coins_number, 0, self.vipCount, 1.5)
        local handle = audio.playSound(RES_AUDIO.number, false)
        self:performWithDelay(function() 
            audio.stopSound(handle) 
            self.btn_ok:setVisible(true)
            end,1.5)
    end,0.5)
end

function LUV:registerUIEvent()

    core.displayEX.newButton(self.btn_ok)
        :onButtonClicked(function() 
            if self.isAnimation then return end
            self:flyCoins()
        end)

    self.btn_ok:setVisible(false)
end

function LUV:initUI()
    local model = app:getUserModel()
    local vipLevel = model:getVipLevel()

    model:setCoins(model:getCoins() + self.vipCount)

    --self.coins_number:setString(tostring(self.vipCount))

    local item = DICT_VIP[tostring(vipLevel)]
    if item ~= nil and cc.SpriteFrameCache:getInstance():getSpriteFrame(item.picture) then
        self.vipSprite:setSpriteFrame(item.picture)
    end

end

function LUV:flyCoins()
    self.isAnimation = true
    local handle = audio.playSound(RES_AUDIO.fly_coins, false)
    local callback = function()
        audio.stopSound(handle) 
        EventMgr:dispatchEvent({name = EventMgr.UPDATE_LOBBYUI_EVENT})

        if self.callback ~= nil then
            self.callback()
        end
        scn.ScnMgr.removeView(self)
    end
    --AnimationUtil.MoveTo("gold.png",10,self.coins_number, app.coinSprite,callback)
    AnimationUtil.flyTo("gold.png",10,self.coins_number, app.coinSprite)
    self:performWithDelay(callback, 1.5)
end

function LUV:onEnter()

end

function LUV:onExit()
    self:removeAllNodeEventListeners()
end

return LUV