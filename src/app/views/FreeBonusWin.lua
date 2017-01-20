
local FreeBonusWin = class("FreeBonusWin", function()
    return core.displayEX.newSwallowEnabledNode()
end)

function FreeBonusWin:ctor(args)
    self.viewNode  = CCBuilderReaderLoad(RES_CCBI.freebonusWin, self)
    self:addChild(self.viewNode)

    if args.delayCall ~= nil then
        self.delayCall = args.delayCall
    end
    self.isAnimation = false
    self.totalLabel:setString("")
    self:performWithDelay(function()

        SlotsMgr.setLabelStepCounter(self.totalLabel, 0, args.coins, 1.0)
        
        local handle = audio.playSound(RES_AUDIO.number, false)
        
        self:performWithDelay(function() 
            audio.stopSound(handle) 
            self.okBtn:setVisible(true) 
            end,1.0)

    end,0.3)

    self:registerUIEvent()


end

function FreeBonusWin:registerUIEvent()

    self.okBtn = core.displayEX.newButton(self.okBtn)
        :onButtonClicked(function(event)
            -- body
            if self.isAnimation then return end
            
            self:flyCoins()
        end)

    self.okBtn:setVisible(false)

end

function FreeBonusWin:flyCoins()
    self.isAnimation = true
    
    local handle = audio.playSound(RES_AUDIO.fly_coins, false)
    local callback = function()
        audio.stopSound(handle) 
        self.delayCall()

        scn.ScnMgr.removeView(self)
    end
    --AnimationUtil.MoveTo("gold.png",10,self.totalLabel, app.coinSprite,callback)
    AnimationUtil.flyTo("gold.png",10,self.totalLabel, app.coinSprite)
    self:performWithDelay(callback, 1.5)
end

function FreeBonusWin:onEnter()
end

function FreeBonusWin:onExit()
end

return FreeBonusWin
