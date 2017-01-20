
local ScrollView = import(".AdScrollView")
local AdPageControl = class("AdPageControl", ScrollView)

function AdPageControl:onTouchEndedWithoutTap(x, y)
    local offsetX, offsetY = self.offsetX, self.offsetY
    local index = 0
    local count = #self.cells
    if self.direction == ScrollView.DIRECTION_HORIZONTAL then
        offsetX = -offsetX
        local x = 0
        local i = 1

        while i <= count do
            local cell = self.cells[i]
            local size = cell:getContentSize()

            if self.moveDirection == ScrollView.MOVETO_LEFT then
                if offsetX * 2.7 < x + size.width / 2 / 1.5 then
                    index = i
                    break
                end
            else
                if offsetX < x + size.width / 2 / 1.5 * 2.7 then
                    index = i
                    break
                end
            end
            x = x + size.width / 1.5
            i = i + 1
        end
        if i > count then index = count end
    else
        local y = 0
        local i = 1
        while i <= count do
            local cell = self.cells[i]
            local size = cell:getContentSize()
            if offsetY < y + size.height / 2 then
                index = i
                break
            end
            y = y + size.height
            i = i + 1
        end
        if i > count then index = count end
    end

    -- self.cells[index]:setPositionX(0)
    self:scrollToCell(index, true)
end

return AdPageControl
