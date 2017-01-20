
-----------------------------------------------------------
-- CoverView 
-----------------------------------------------------------
local CoverView = class("CoverView", function()
    return display.newNode()
end)

-----------------------------------------------------------
-- Construct 
-----------------------------------------------------------
function CoverView:ctor() 

    self:addChild(cc.LayerColor:create(cc.c4b(0, 0, 0, 200)))
    self:setNodeEventEnabled(true)
    self:setTouchEnabled(true)
    self:setTouchSwallowEnabled(true)
    self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        if event.name == "began" then
            return true
        end
    end)

end


-----------------------------------------------------------
-- onExit 
-----------------------------------------------------------
function CoverView:onExit()
    self:removeAllNodeEventListeners()
end

return CoverView
