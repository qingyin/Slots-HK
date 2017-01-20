local TopBarClass = require("app.scenes.common.TopBar") 

-----------------------------------------------------------
-- ControlbarView 
-----------------------------------------------------------
local ControlbarView = class("ControlbarView", function()
    return display.newNode()
end)

-----------------------------------------------------------
-- Construct 
-- args.machineId
-----------------------------------------------------------
function ControlbarView:ctor(args) 

    self.machineId  = args.machineId

    local controlbar = DICT_MAC_RES[tostring(self.machineId)].control_bar

    self.controlbar  = CCBuilderReaderLoad(controlbar, self)


    self:addChild(self.controlbar)
    self.topbar = TopBarClass.new({delegate=self})
    self:addChild(self.topbar)

    self:setNodeEventEnabled(true)

    self:hideDouble()
    self:hideFrLabel()
    
    local topScale = display.width/1136
    self.top:setScale(topScale)

    local bottomScale = display.height/768

    if bottomScale > topScale then
        bottomScale = topScale
    end

    self.bottom:setScale(topScale)

    self:Layout(true)

end

-----------------------------------------------------------
-- setFrLabel 
-----------------------------------------------------------
function ControlbarView:setFrLabel( str )
    self.FreeSpinCounterLabel:setString(str)
end

-----------------------------------------------------------
-- showFrLabel 
-----------------------------------------------------------
function ControlbarView:showFrLabel()
    self.FreeSpinCounterLabel:setVisible(true)
end

-----------------------------------------------------------
-- hideFrLabel 
-----------------------------------------------------------
function ControlbarView:hideFrLabel()
    self.FreeSpinCounterLabel:setVisible(false)
end

-----------------------------------------------------------
-- getTopHeight 
-----------------------------------------------------------
function ControlbarView:getTopHeight()
    return self.topBgSprite:getContentSize().height
end

-----------------------------------------------------------
-- getBottomHeight 
-----------------------------------------------------------
function ControlbarView:getBottomHeight()
    return self.bottomBgSprite:getContentSize().height
end

-----------------------------------------------------------
-- UpdateWinCoinLabel 
-----------------------------------------------------------
function ControlbarView:updateWinCoinLabel( value )
    self.winLabel:setString(value)
end

-----------------------------------------------------------
-- updateTTBet 
-----------------------------------------------------------
function ControlbarView:updateTTBet( value )
    self.totalBetLabel:setString(value)
end

-----------------------------------------------------------
-- showDouble 
-----------------------------------------------------------
function ControlbarView:showDouble()
    self.doubleBtn:setVisible(true)
end

-----------------------------------------------------------
-- hideDouble 
-----------------------------------------------------------
function ControlbarView:hideDouble()
    self.doubleBtn:setVisible(false)
end

-----------------------------------------------------------
-- addSmallWinEff 
-----------------------------------------------------------
function ControlbarView:addSmallWinEff(eff)
    self.smallWInNode:addChild(eff)
end

-----------------------------------------------------------
-- upTTCoinsByStep 
-----------------------------------------------------------
function ControlbarView:upTTCoinsByStep(value)
	local frNum = tonumber(number.deleteCommaSepeate(self.coinLabel:getString()))
	SlotsMgr.setLabelStepCounter(self.coinLabel, frNum, value, 0.5)
end

-----------------------------------------------------------
-- setTTCoins 
-----------------------------------------------------------
function ControlbarView:setTTCoins(value)
	SlotsMgr.stopLabelStepCounter(self.coinLabel)
	self.coinLabel:setString(number.commaSeperate(value))
end

-----------------------------------------------------------
-- upWinCoinsByStep 
-----------------------------------------------------------
function ControlbarView:upWinCoinsByStep(value)
    local frNum = tonumber(number.deleteCommaSepeate(self.winLabel:getString()))
	SlotsMgr.setLabelStepCounter(self.winLabel, frNum, value, 0.5)
end

-----------------------------------------------------------
-- setWinCoins 
-----------------------------------------------------------
function ControlbarView:setWinCoins(value)
	SlotsMgr.stopLabelStepCounter(self.winLabel)
	self.winLabel:setString(value)
end

-----------------------------------------------------------
-- onEnter 
-----------------------------------------------------------
function ControlbarView:onEnter()

end

-----------------------------------------------------------
-- onExit 
-----------------------------------------------------------
function ControlbarView:onExit()

    self:removeAllChildren()
    self.controlbar = nil
    collectgarbage("collect")

end

return ControlbarView
