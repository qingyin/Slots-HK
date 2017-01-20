
local CoverView = class("CoverView", function()
    return core.displayEX.newSwallowEnabledNode()
end)

function CoverView:ctor()
    self:addChild(display.newColorLayer(cc.c4b(0, 0, 0, 200)))
end

function CoverView:onEnter()

end

function CoverView:onExit()
    self:removeTouchEventListener()
end


return CoverView
