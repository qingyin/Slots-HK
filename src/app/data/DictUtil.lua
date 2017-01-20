DictUtil = DictUtil or {}

DictUtil.getChipsByValue = function(value)
    if DictUtil.chipValues == nil then
        DictUtil.chipValues = {}
        local len = table.nums(dict_chip)
        for i = 1,len do
            local v = dict_chip[tostring(i)].amount
            local av = tonumber(v)
            table.insert(DictUtil.chipValues,av)
        end
    end
    local chips = {}
    local getItem
    getItem = function(v)
        local amount = DictUtil.getMaxChip(v)
        local i,f = math.modf(v/amount)
        chips[amount] = i
        v = v - amount * i
        if v > 1 then
            getItem(v)
        end
    end
    getItem(value)
    return chips
end

DictUtil.getMaxChip = function(v)
    local max = 0
    for i = #DictUtil.chipValues, 1, -1 do
        max = DictUtil.chipValues[i]
        if v >= max then
            return max
        end
    end
    return max
end

DictUtil.getChipItem = function(value)
    local len = table.nums(dict_chip)
    for i = 1,len do
        local item = dict_chip[tostring(i)]
        local v = item.amount
        if value == tonumber(v) then
            return item
        end
    end
end