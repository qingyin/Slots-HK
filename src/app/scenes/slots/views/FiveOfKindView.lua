
-----------------------------------------------------------
-- FiveOfKindView 
-----------------------------------------------------------
local FiveOfKindView = class("FiveOfKindView", function()
    return display.newNode()
end)

-----------------------------------------------------------
-- Construct 
-----------------------------------------------------------
function FiveOfKindView:ctor() 

    local ccb = "slots/of_a_kind.ccbi"
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


    local time = 2

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
function FiveOfKindView:onExit()
    self:removeAllNodeEventListeners()
end

return FiveOfKindView
