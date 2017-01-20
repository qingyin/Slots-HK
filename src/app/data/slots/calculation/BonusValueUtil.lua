module("app.data.slots.calculation.BonusValueUtil", package.seeall)

local BonusValueUtil = app.data.slots.calculation.BonusValueUtil

require "app.data.slots.DicConstants"

bonusValueConfig = {}

--获得value配置
function getBonusValueConfig(valueId)
    if #bonusValueConfig <= 0 then
        for key, var in pairs(DICT_BONUS_VALUE) do
            local valueConfig = {}
            local weight = 0
            for i, v in ipairs(var.value_config) do
                weight = weight + v.y
                local t = {}
                t.weight = weight
                t.value = v.x
                table.insert(valueConfig, t)
            end
            valueConfig.totalWeight = weight
            valueConfig.id = var.id
            valueConfig.type = var.type
            valueConfig.flag = var.flag
            bonusValueConfig[tonumber(key)] = valueConfig
        end
    end 
    return bonusValueConfig[valueId]
end

--根据id获得一个value
function BonusValueUtil.getBonusValue(valueId)
    local bonusValue = {}

    local valueConfig = getBonusValueConfig(valueId)
    math.random(valueConfig.totalWeight)
    local index = math.random(valueConfig.totalWeight)
    print(valueConfig.totalWeight, index)
    for i, v in ipairs(valueConfig) do
        if index <= v.weight then
            bonusValue.value = tostring(v.value)
            break
        end
    end
    bonusValue.id = valueConfig.id
    bonusValue.type = valueConfig.type
    bonusValue.flag = valueConfig.flag
    return bonusValue
end

--[[
require "functions"
require "app.core.util.TableUtil"

local function main()

    for k, v in ipairs(getBonusValueConfig(1)) do
    	print(k, v.weight, v.value)
    end
  
    table.dump(getBonusValueConfig(1),"DICT_rr")
end
main()
--]]