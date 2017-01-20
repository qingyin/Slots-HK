local WinChip = class("WinChip", function()
    return display.newNode()
end)

function WinChip:ctor(value)
    local arr = {}
    local x,y = 0,0
    local items = DictUtil.getChipsByValue(value)
    for k, v in pairs(items) do
        local item = DictUtil.getChipItem(k)
        for i = 1, v do
            local sp = display.newSprite("#"..item.picture)
            table.insert(arr,sp)
            local len = #arr
            if len > 15 then len = 15 end
            local ty = y+(len-1)*2
            sp:setPosition(x-len%2* (-5),ty-len%2* (-5))
            self:addChild(sp)
        end
    end
--[[
    local label = display.newTTFLabel({
        text = value,
        font = "Arial",
        color = cc.c3b(255, 0, 0),
        size = 20,
        align = cc.TEXT_ALIGNMENT_CENTER
    })
    label:setPositionY(-40)
    self:addChild(label)
    self.text = label]]
    self:setNodeEventEnabled(true)
end


function WinChip:onExit()
    self:removeAllNodeEventListeners()
end

return WinChip

