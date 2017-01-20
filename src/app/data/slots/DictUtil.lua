
local RewardSettlePattern=import("app.data.slots.beans.RewardSettlePattern")

--从字典表里寻找最高的结算配置，未找到返回nil
function fetchBonusPaytable(settleType,count)
    --print("---------fetchBonusPaytable---start--------------:")
    local settleTable={}
    for key, val in pairs(DICT_BONUS_PAYTABLE) do
        if tonumber(val.settle_type)==settleType then
            table.insert(settleTable,val)
        end
    end
    --降序排列
    local sortFunc = function(a, b) return b.symbol_cnt < a.symbol_cnt end
    table.sort(settleTable,sortFunc)

    local p_key=settleType.."|"..count
    for i=1,#settleTable do
        local tmp_count=tonumber(settleTable[i].symbol_cnt)
        if count>=tmp_count then
            p_key=settleTable[i].key
            break
        end
    end
    --print("找到结果:"..p_key)
    --print("--------fetchBonusPaytable----end--------------:")
    return DICT_BONUS_PAYTABLE[p_key]
end

--从字典表里寻找最高的结算配置，未找到返回nil
function fetchScatterPaytable(settleType,count)
    --print("---------fetchScatterPaytable---start--------------:")
    local settleTable={}
    for key, val in pairs(DICT_FREESPIN_PAYTABLE) do
        if tonumber(val.settle_type)==settleType then
            table.insert(settleTable,val)
        end
    end
    --降序排列
    local sortFunc = function(a, b) return b.symbol_cnt < a.symbol_cnt end
    table.sort(settleTable,sortFunc)

    local p_key=settleType.."|"..count
    for i=1,#settleTable do
        local tmp_count=tonumber(settleTable[i].symbol_cnt)
        if count>=tmp_count then
            p_key=settleTable[i].key
            break
        end
    end
    --print("找到结果:"..p_key)
    --print("--------fetchScatterPaytable----end--------------:")
    return DICT_FREESPIN_PAYTABLE[p_key]
end

--从字典表里寻找最高的结算配置，未找到返回nil
function fetchMachinePaytable(settleType,count,machineId)
    local settleTable={}
    local machinePayTable=getMachinePaytable(machineId)
    for key, val in pairs(machinePayTable) do
        if tonumber(val.settle_type)==settleType then
            table.insert(settleTable,val)
        end
    end
    --降序排列
    local sortFunc = function(a, b) return b.symbol_cnt < a.symbol_cnt end
    table.sort(settleTable,sortFunc)

    local p_key=settleType.."|"..count
    for i=1,#settleTable do
        --print(settleTable[i].key)
        local tmp_count=tonumber(settleTable[i].symbol_cnt)
        if count>=tmp_count then
            p_key=settleTable[i].key
            break
        end
    end
    return machinePayTable[p_key]
end

function containsCoordinate(x,y,ignoreGrid)
    for i=1,#ignoreGrid do
        local coordinate=ignoreGrid[i]
        if x==coordinate.k and y==coordinate.v then
            return true
        end
    end
    return false
end

--获得被比较的图标
function getCompareSymbol(singleLine)
    local compareSymbol=nil
    for i=1,#singleLine do
        compareSymbol=singleLine[i]
        local dicSymbol=DICT_SYMBOL[tostring(compareSymbol:getSymbolId())]
        --取得图标类型
        local symbolType=dicSymbol["symbol_type"]
        
        --如果Symbol为Scatter或者Bonus时，被比较对象为null
        if symbolType==SYMBOL_TYPE.Scatter or symbolType==SYMBOL_TYPE.Bonus then
            return nil
        end
        
        if symbolType==SYMBOL_TYPE.Normal then
            return compareSymbol
        end
    end
    return compareSymbol
end

--获得结算类型
function getCalculateType(compareSymbol)

    --如果从左边起第一个不是Normal或者Wild，则不用计算
    if compareSymbol==nil then
        return CALCULATE_TYPE.NONE
    end
    
    local dicSymbol=DICT_SYMBOL[tostring(compareSymbol:getSymbolId())]
    --取得图标类型
    local symbolType=dicSymbol["symbol_type"]
    if symbolType==SYMBOL_TYPE.Wild then
        return CALCULATE_TYPE.WILD
    end
    
    if symbolType==SYMBOL_TYPE.Normal then
        return CALCULATE_TYPE.NORMAL
    end

    return CALCULATE_TYPE.NONE
end

--获得可能的paytable
function getPossibleSettles(machineId,singleLine)
    local possibleSettles={}
    local compareSymbol=getCompareSymbol(singleLine)
    local calculateType=getCalculateType(compareSymbol)
    if calculateType==CALCULATE_TYPE.NONE then

    elseif calculateType==CALCULATE_TYPE.NORMAL then
        local dicSymbol=DICT_SYMBOL[tostring(compareSymbol:getSymbolId())]
        local compareSettleType=tonumber(dicSymbol.settle_type)
        local rewardSettle=getMaxRewardSettle(compareSettleType,singleLine,compareSymbol:getSymbolId())
        if rewardSettle~=nil then
            table.insert(possibleSettles,rewardSettle)
            --[[
            print("compareSymbol:"..compareSymbol:toString())
            for i=1,#singleLine do
                print("     singleLine:"..singleLine[i]:toString())
            end
            ]]
        end
    elseif calculateType==CALCULATE_TYPE.WILD then
        local machinePayTable=getMachinePaytable(machineId)
        for key, val in pairs(machinePayTable) do
            local rewardSettle=getMaxRewardSettle(tonumber(val.settle_type),singleLine,compareSymbol:getSymbolId())
            table.insert(possibleSettles,rewardSettle)
        end
    end
    --[[
    for i=1,#possibleSettles do
        print("possibleSettles[i]:getSettleType()"..possibleSettles[i]:getSettleType()..",cnt:"..possibleSettles[i]:getMaxCnt())
    end
    ]]
    return possibleSettles
end

--从每条线左侧开始，计算能达到最小连续数目的图案和数目
function getMaxRewardSettle(compareSettleType,singleLine,symbolId)
    local maxCnt = 0
    local settleType = 0
    local wildMultiple = 1
    
    for i=1,#singleLine do
        local matrixSymbol=singleLine[i]
        local dicSymbol=DICT_SYMBOL[tostring(matrixSymbol:getSymbolId())]
        settleType=tonumber(dicSymbol.settle_type)
        
        if settleType==compareSettleType then
            maxCnt=maxCnt+1
        elseif dicSymbol.symbol_type==SYMBOL_TYPE.Wild then
            maxCnt=maxCnt+1
            local multiple=DICT_WILD_PAYTABLE[tostring(settleType)].multiple
            --[[
            if tonumber(multiple)>wildMultiple then
                wildMultiple=tonumber(multiple)
            end
            ]]
            wildMultiple = wildMultiple * tonumber(multiple)
        else
            break
        end
    end
    
    if maxCnt >= MinCalculateNumber then
        local rewardSettle=RewardSettlePattern.new(compareSettleType)
        rewardSettle:setMaxCnt(maxCnt)
        rewardSettle:setWildMultiple(wildMultiple)
        rewardSettle:setWinSymbolId(symbolId)
        return rewardSettle
    end
    
    return nil
end

DIC_MACHINE_PAYTABLE={}
function getMachinePaytable(machineId)
    if DIC_MACHINE_PAYTABLE[machineId] ~= nil then
        return DIC_MACHINE_PAYTABLE[machineId]
    end
    print(string.format("DictUtil.getMachinePaytable(%s)",tostring(machineId)))
    local machinePaytable={}
    local machine=DICT_MACHINE[tostring(machineId)]
    local usedSymbols=machine["used_symbols"]
    usedSymbols=table.unique(usedSymbols)

    
    local settleTypes={}
    for i=1,#usedSymbols do
        local dicSymbol=DICT_SYMBOL[tostring(usedSymbols[i])]
        local settleType=dicSymbol["settle_type"]
        settleTypes[settleType]="xx"
    end
    
    for key, val in pairs(DICT_PAYTABLE) do
        if settleTypes[val.settle_type] ~= nil then
            machinePaytable[val.key]=val
        end
    end
    DIC_MACHINE_PAYTABLE[machineId]=machinePaytable
    return machinePaytable
end

function getBetList(level,machineId)

    -- for key, val in pairs(DICT_BET) do
    --     local machineList = val.unlock_machine
    --     for i=1,#machineList do
    --         if tonumber(machineId) == machineList[i] then
    --             return { default=val.default_bet, list=val.bet_list }
    --         end
    --     end
    -- end
    
    local prekey = nil
    local maxlv = 0
    local result = nil

    for key, val in pairs(DICT_BET) do

        local lv = tonumber(val.unlock_level)

        if level >= lv and lv >= maxlv then

            maxlv = lv
            result = val

        end
        
    end
    
    return { default=result.default_bet, list=result.bet_list }

end

--获得玩家下注的最大totalbet
function getMaxTotalBet(level,machineId)
    local betList=getBetList(level,machineId).list
    local maxBet=betList[#betList]
    local tmp_machine=DICT_MACHINE[tostring(machineId)]
    local lineNums=table.nums(tmp_machine.used_lines)
    return tonumber(maxBet)*lineNums
end

function getLevelByExp(totalexp)

    local num = table.nums( DICT_LEVEL )
    
    for i=1,num do
        
        local Level1 = DICT_LEVEL[tostring(i)]
       
        if Level1 ~= nil and totalexp < tonumber(Level1.need_total_bets) then
            local Level2 = DICT_LEVEL[tostring(i-1)]

            if Level2 ~= nil then
                return tonumber(Level2.level)
            else
                return 1
            end
        end
    end
    
    return tonumber(DICT_LEVEL[tostring(num)].level)
end

function getVipLevelByVipPoint(totalpt)

    local num = table.nums( DICT_VIP )
    
    for i=1,num do
        local vipLevel1 = DICT_VIP[tostring(i)]

        if vipLevel1 ~= nil and totalpt < tonumber(vipLevel1.vip_point)  then
            local vipLevel2 = DICT_VIP[tostring(i-1)]
            
            if vipLevel2 ~= nil then
                return tonumber(vipLevel2.level)
            else
                return 0
            end
        end
    end
    
    return tonumber(DICT_VIP[tostring(num)].level)
end

function getVipPointsByLevel(level)
    local num = table.nums( DICT_VIP )

    if  DICT_VIP[tostring(level)] ~= nil then
        return DICT_VIP[tostring(level)].vip_point
    elseif level > num then
        return DICT_VIP[tostring(num)].vip_point
    else
        return 0
    end
end

function getNeedVipPointByLevel(level)
    if level < 2 then return getVipPointsByLevel(1) end
    return getVipPointsByLevel(level) - getVipPointsByLevel(level-1)
end


function getLevelExpByLevel(level)
    return DICT_LEVEL[tostring(level)].need_total_bets
end

function getNeedExpByLevel(level)
    if level < 2 then return 0 end
    return getLevelExpByLevel(level) - getLevelExpByLevel(level-1)
end

function getProductAmount(productId)
    local price="0"
    for key, val in pairs(DICT_IAP_PRODUCT) do
        if val.product_id == productId then
            price=val.amount
            break
        end
    end
    return price
end
