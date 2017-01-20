
-----------------------------------------------------------
-- MegaWinView 
-----------------------------------------------------------
local MegaWinView = class("MegaWinView", function()
    return display.newNode()
end)

-----------------------------------------------------------
-- Construct 
-- args.winCoin
-----------------------------------------------------------
function MegaWinView:ctor(args) 

    local ccb = "view/megawin.ccbi"
    self.ccbNode = CCBuilderReaderLoad(ccb, self)
    self:addChild(self.ccbNode)
    self:setNodeEventEnabled(true)
    self:setTouchEnabled(true)
    self:setTouchSwallowEnabled(true)
    self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        if event.name == "began" then
            return true
        end
    end)


    self.coinLabel:setString("")

    local time = 4.5
    local setLabelStep = function()
        SlotsMgr.setLabelStepCounter(self.coinLabel, 0, args.winCoin, 2.5)
        local handle = audio.playSound(RES_AUDIO.number, false)
        self:performWithDelay(function() audio.stopSound(handle) end,2.5)
    end

    local stepDelay = cc.DelayTime:create(0.6)
    local callStepfunc = cc.CallFunc:create(setLabelStep)
    local acSequence = cc.Sequence:create(stepDelay, callStepfunc)
    self:runAction(acSequence)
   
    local func = function()
        self:removeFromParent(true)
    end

    local delay = cc.DelayTime:create(time)
    local callfunc = cc.CallFunc:create(func)
    local sequence = cc.Sequence:create(delay, callfunc)
    self:runAction(sequence)

    SlotsMgr.setAllChildrensZorder(self, 15)

end

-----------------------------------------------------------
-- onExit 
-----------------------------------------------------------
function MegaWinView:onExit()
    self:removeAllNodeEventListeners()
end

return MegaWinView
