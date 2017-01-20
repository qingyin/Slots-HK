
local AdScrollView = class("app.views.adListUI.AdScrollView", function(rect)
    if not rect then rect = cc.rect(0, 0, 0, 0) end
    local node = display.newClippingRegionNode(rect)
    node:setNodeEventEnabled(true)
    cc(node):addComponent("components.behavior.EventProtocol"):exportMethods()
    return node
end)

AdScrollView.DIRECTION_VERTICAL   = 1
AdScrollView.DIRECTION_HORIZONTAL = 2

AdScrollView.MOVETO_LEFT  = 1
AdScrollView.MOVETO_RIGHT = 2


function AdScrollView:ctor(rect, direction)

    -- print("AdScrollView rect:",rect,direction)

    assert(direction == AdScrollView.DIRECTION_VERTICAL or direction == AdScrollView.DIRECTION_HORIZONTAL,
           "AdScrollView:ctor() - invalid direction")

    self.dragThreshold = 40
    self.bouncThreshold = 140
    self.defaultAnimateTime = 0.4
    self.defaultAnimateEasing = "backOut"

    self.direction = direction
    self.touchRect = rect
    self.offsetX = 0
    self.offsetY = 0
    self.cells = {}
    self.currentIndex = 0
    self.moveDirection = AdScrollView.MOVETO_LEFT

    self:addNodeEventListener(cc.NODE_EVENT, function(event)
        if event.name == "enter" then
            self:onEnter()
        elseif event.name == "exit" then
            self:onExit()
        end
    end)
    
    -- create container layer
    self.view = display.newLayer()
    self:addChild(self.view)

    self.view:setTouchSwallowEnabled(false)
    self.view:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        -- print("onTouch---")
        return self:onTouch(event.name, event.x, event.y)
    end)
    
end

function AdScrollView:getCurrentCell()
    if self.currentIndex > 0 then
        return self.cells[self.currentIndex]
    else
        return nil
    end
end

function AdScrollView:getCurrentIndex()
    return self.currentIndex
end

function AdScrollView:setCurrentIndex(index)
    self:scrollToCell(index)
end

function AdScrollView:addCell(cell)
    self.view:addChild(cell)
    self.cells[#self.cells + 1] = cell
    self:reorderAllCells()
    self:dispatchEvent({name = "addCell", count = #self.cells})
end

function AdScrollView:insertCellAtIndex(cell, index)
    self.view:addChild(cell)
    table.insert(self.cells, index, cell)
    self:reorderAllCells()
    self:dispatchEvent({name = "insertCellAtIndex", index = index, count = #self.cells})
end

function AdScrollView:removeCellAtIndex(index)
    local cell = self.cells[index]
    cell:removeSelf()
    table.remove(self.cells, index)
    self:reorderAllCells()
    self:dispatchEvent({name = "removeCellAtIndex", index = index, count = #self.cells})
end

function AdScrollView:getView()
    return self.view
end

function AdScrollView:getTouchRect()
    return self.touchRect
end

function AdScrollView:setTouchRect(rect)
    self.touchRect = rect
    self:dispatchEvent({name = "setTouchRect", rect = rect})
end

function AdScrollView:getClippingRect()
    return self:getClippingRegion()
end

function AdScrollView:setClippingRect(rect)
    self:setClippingRegion(rect)
    self:dispatchEvent({name = "setClippingRect", rect = rect})
end

function AdScrollView:scrollToCell(index, animated, time, easing)
    local count = #self.cells
    if count < 1 then
        self.currentIndex = 0
        return
    end

    if index < 1 then
        index = 1
    elseif index > count then
        index = count
    end
    self.currentIndex = index

    local offset = 0
    for i = 2, index do
        local cell = self.cells[i - 1]
        local size = cell:getContentSize()
        if self.direction == AdScrollView.DIRECTION_HORIZONTAL then
            offset = offset - size.width/1.5
        else
            offset = offset + size.height
        end
    end

    self:setContentOffset(offset, animated, time, easing)
    self:dispatchEvent({name = "scrollToCell", animated = animated, time = time, easing = easing})
end

function AdScrollView:isTouchEnabled()
    return self.view:isTouchEnabled()
end

function AdScrollView:setTouchEnabled(enabled)
    self.view:setTouchEnabled(enabled)
    self:dispatchEvent({name = "setTouchEnabled", enabled = enabled})
end

---- events

function AdScrollView:onTouchBegan(x, y)
    self.drag = {
        currentOffsetX = self.offsetX,
        currentOffsetY = self.offsetY,
        startX = x,
        startY = y,
        isTap = true,
    }

    local cell = self:getCurrentCell()
    cell:onTouch(event, x, y)

    return true
end

function AdScrollView:onTouchMoved(x, y)
    local cell = self:getCurrentCell()
    if self.direction == AdScrollView.DIRECTION_HORIZONTAL then
        if self.drag.isTap and math.abs(x - self.drag.startX) >= self.dragThreshold then
            self.drag.isTap = false
            cell:onTouch("cancelled", x, y)
        end

        if not self.drag.isTap then
            --print("=========AdScrollView:onTouchMoved(x, y)---",x , self.drag.startX)
            if x - self.drag.startX < 0 then
                self.moveDirection = AdScrollView.MOVETO_LEFT
            else
                self.moveDirection = AdScrollView.MOVETO_RIGHT
            end
            self:setContentOffset(x - self.drag.startX + self.drag.currentOffsetX)
        else
            cell:onTouch(event, x, y)
        end
    else
        if self.drag.isTap and math.abs(y - self.drag.startY) >= self.dragThreshold then
            self.drag.isTap = false
            cell:onTouch("cancelled", x, y)
        end

        if not self.drag.isTap then
            self:setContentOffset(y - self.drag.startY + self.drag.currentOffsetY)
        else
            cell:onTouch(event, x, y)
        end
    end
end

function AdScrollView:onTouchEnded(x, y)
    if self.drag.isTap then
        self:onTouchEndedWithTap(x, y)
    else
        self:onTouchEndedWithoutTap(x, y)
    end
    self.drag = nil
end

function AdScrollView:onTouchEndedWithTap(x, y)
    local cell = self:getCurrentCell()
    cell:onTouch(event, x, y)
    cell:onTap(x, y)
end

function AdScrollView:onTouchEndedWithoutTap(x, y)
    error("AdScrollView:onTouchEndedWithoutTap() - inherited class must override this method")
end

function AdScrollView:onTouchCancelled(x, y)
    self.drag = nil
end

function AdScrollView:onTouch(event, x, y)
    
    -- print("AdScrollView:onTouch--")
    if self.currentIndex < 1 then return end

    if event == "began" then
        if not cc.rectContainsPoint(self.touchRect, cc.p(x, y)) then return false end
        return self:onTouchBegan(x, y)
    elseif event == "moved" then
        self:onTouchMoved(x, y)
    elseif event == "ended" then
        self:onTouchEnded(x, y)
    else -- cancelled
        self:onTouchCancelled(x, y)
    end
end

---- private methods

function AdScrollView:reorderAllCells()
    local count = #self.cells
    local x, y = 0, 0
    local maxWidth, maxHeight = 0, 0
    for i = 1, count do
        local cell = self.cells[i]
        cell:setPosition(x, y)
        cell.initPos.posx = x
        if self.direction == AdScrollView.DIRECTION_HORIZONTAL then
            local width = cell:getContentSize().width
            if width > maxWidth then maxWidth = width end
            x = x + width/1.5
        else
            local height = cell:getContentSize().height
            if height > maxHeight then maxHeight = height end
            y = y - height
        end
    end

    if count > 0 then
        if self.currentIndex < 1 then
            self.currentIndex = 1
        elseif self.currentIndex > count then
            self.currentIndex = count
        end
    else
        self.currentIndex = 0
    end

    local size
    x = x + (self.cells[count]:getContentSize()).width/1.5
    if self.direction == AdScrollView.DIRECTION_HORIZONTAL then
        size = cc.size(x, maxHeight)
    else
        size = cc.size(maxWidth, math.abs(y))
    end
    self.view:setContentSize(size)
end

function AdScrollView:setContentOffset(offset, animated, time, easing)
    local ox, oy = self.offsetX, self.offsetY
    local x, y = ox, oy
    if self.direction == AdScrollView.DIRECTION_HORIZONTAL then
        self.offsetX = offset
        x = offset

        local maxX = self.bouncThreshold
        local minX = -self.view:getContentSize().width - self.bouncThreshold + self.touchRect.width
        if x > maxX then
            x = maxX
        elseif x < minX then
            x = minX
        end
    else
        self.offsetY = offset
        y = offset

        local maxY = self.view:getContentSize().height + self.bouncThreshold - self.touchRect.height
        local minY = -self.bouncThreshold
        if y > maxY then
            y = maxY
        elseif y < minY then
            y = minY
        end
    end

    if animated then
        transition.stopTarget(self.view)
        transition.moveTo(self.view, {
            x = x,
            y = y,
            time = time or self.defaultAnimateTime,
            easing = easing or self.defaultAnimateEasing
        })
    else
        self.view:setPosition(x, y)
    end
end

function AdScrollView:onExit()
    self:removeAllEventListeners()
end

return AdScrollView
