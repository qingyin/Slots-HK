module("app.data.slots.calculation.ResultPoolUtil", package.seeall)

local ResultPoolUtil = app.data.slots.calculation.ResultPoolUtil

local dicResultPool = DICT_RESULT_POOL

function ResultPoolUtil.getResult(machineId, poolId)
  local poolKey = machineId .. "_" .. poolId
  local pool = dicResultPool[poolKey]
  if pool==nil then 
     print("poolKey not found:"..poolKey)
     return nil
  end

  math.random(#pool)
  local index = math.random(#pool)
  return pool[index]
end

--[[
require "app.core.util.TableUtil"

local function main()
  local t = ResultPoolUtil.getResult("1", 1)
  table.dump(t, 'RR')
end

main()
]]--