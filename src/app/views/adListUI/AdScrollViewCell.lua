
local AdScrollViewCell = class("AdScrollViewCell", function(contentSize)
    local node = display.newNode()
    if contentSize then node:setContentSize(contentSize) end
    node:setNodeEventEnabled(true)
    cc(node):addComponent("components.behavior.EventProtocol"):exportMethods()
    return node
end)

function AdScrollViewCell:onTouch(event, x, y)
end

function AdScrollViewCell:onTap(x, y)
end

function AdScrollViewCell:onExit()
    self:removeAllEventListeners()
end

return AdScrollViewCell
