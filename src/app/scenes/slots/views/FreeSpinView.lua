
-----------------------------------------------------------
-- FreeSpinView 
-----------------------------------------------------------
local FreeSpinView = class("FreeSpinView", function()
    return display.newNode()
end)

-----------------------------------------------------------
-- Construct 
-- args.machineId
-----------------------------------------------------------
function FreeSpinView:ctor() 

    local ccb = "slots/FreeSpinView.ccbi"

    self.ccbNode = CCBuilderReaderLoad(ccb, self)
    self:addChild(self.ccbNode)
    self:setNodeEventEnabled(true)

    self:init()

    
    self:setTouchEnabled(true)
    self:setTouchSwallowEnabled(true)
    self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        if event.name == "began" then
            return true
        end
    end)

end

-----------------------------------------------------------
-- init 
-----------------------------------------------------------
function FreeSpinView:init()


end



-----------------------------------------------------------
-- onExit 
-----------------------------------------------------------
function FreeSpinView:onExit()
    self:removeAllNodeEventListeners()
end

return FreeSpinView
