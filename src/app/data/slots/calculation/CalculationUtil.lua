module("app.data.slots.calculation.CalculationUtil", package.seeall)

local CalculationUtil = app.data.slots.calculation.CalculationUtil

local LineCalculation=import("app.data.slots.beans.LineCalculation")

function CalculationUtil.buildCoordinate(x,y)
    return x.."|"..y
end

--将每个坐标点的图标信息散落到线上
function CalculationUtil.buildCalculatLine(roundResult)
    local machineId=roundResult:getRunMachineId()
    local betLineNum=roundResult:getGameSet():getLineNum()
    local calculatLine={}
    --老虎机上定义的线id集合
    local machineLineNums=DICT_MACHINE[tostring(machineId)]["used_lines"]

    --如果开放了玩家自定义线功能，则按玩家定义的线数量来
    if betLineNum < #machineLineNums then
        local tmp_machineLineNums={}
        for k=1,betLineNum do
            table.insert(tmp_machineLineNums,machineLineNums[k])
        end
        machineLineNums=tmp_machineLineNums
    end
    --print("machineLineNums:"..#machineLineNums)
    for i=1,#machineLineNums do
        --线id
        local tmp_lineNum=machineLineNums[i]
        --print("tmp_lineNum:"..tmp_lineNum)
        --取出线的定义
        local tmp_line=DICT_LINE[tostring(tmp_lineNum)]
        --取出线上坐标集合
        local zbs=tmp_line["coordinate"]
        local single_line={}
        --遍历线上每一个坐标
        for j=1,#zbs do
            local zb=zbs[j]
            local key=CalculationUtil.buildCoordinate(zb["x"],zb["y"])
            --print(key)
            local matrixSymbol=roundResult:getStopPosMatrix()[key]
            table.insert(single_line,matrixSymbol)
        end
        calculatLine[tmp_lineNum]=single_line
        --print(single_line[1]:getSymbolId())
    end
    return calculatLine
end

--结算普通图标
function CalculationUtil.calculatNormalSymbol(roundResult,calculatLine)
    local machineId=roundResult:getRunMachineId()
    local roundlinePatterns=roundResult:getLinePattern()
    --对每条线进行普通结算
    for lineNum, singleLine in pairs(calculatLine) do
        local lineResult=CalculationUtil.calculatSingleLine(machineId,singleLine)
        if lineResult ~= nil then
            local lineCalculation=roundResult:fetchLinePattern(lineNum)
            if lineCalculation==nil then
                lineCalculation=LineCalculation.new(lineNum,roundResult)
                lineCalculation:setWinSymbolId(lineResult:getWinSymbolId())
            end
            local multiple=lineResult:getTotalMultiple()
            --增加总的道具奖励
            roundResult:addRewardItems(ITEM_TYPE.NORMAL_MULITIPLE,multiple)
            --增加线的中奖明细
            lineCalculation:addWinItem(ITEM_TYPE.NORMAL_MULITIPLE,multiple)
            lineCalculation:setSide(lineResult:getSide())
            if lineResult:getSide()==CALCULATION_SIDE.LEFT then
                for i=1,lineResult:getMaxCnt() do
                    lineCalculation:addWinSymbols(singleLine[i])
                    roundResult:addAllWinSymbol(singleLine[i])
                end
            elseif lineResult:getSide()==CALCULATION_SIDE.RIGHT then
                local reverseSingleLine=table.reverse(singleLine)
                for i=1,lineResult:getMaxCnt() do
                    lineCalculation:addWinSymbols(reverseSingleLine[i])
                    roundResult:addAllWinSymbol(reverseSingleLine[i])
                end
            end
            roundResult:addLinePattern(lineCalculation)
        end
    end
end
--结算单条线
function CalculationUtil.calculatSingleLine(machineId,singleLine)
    --local machineId=roundResult:getRunMachineId()
    local machine=DICT_MACHINE[tostring(machineId)]
    local leftResult=nil
    local rightResult=nil
    local leftSettles=getPossibleSettles(machineId,singleLine)
    leftResult=CalculationUtil.getMaxSettleMultiple(machineId,leftSettles)
    local rightSettles={}
    if machine.calculation_rule==CALCULATION_RULE.BOTH_SIDE then
        local reverseSingleLine=table.reverse(singleLine)
        rightSettles=getPossibleSettles(machineId,reverseSingleLine)
        rightResult=CalculationUtil.getMaxSettleMultiple(machineId,rightSettles)
    end
    local side=0
    local finalResult=nil
    if leftResult==nil and rightResult==nil then
        return finalResult
    elseif leftResult~=nil and rightResult==nil then
        finalResult=leftResult
        side=CALCULATION_SIDE.LEFT
    elseif leftResult==nil and rightResult~=nil then
        finalResult=rightResult
        side=CALCULATION_SIDE.RIGHT
    elseif leftResult~=nil and rightResult~=nil then
        if leftResult:getTotalMultiple()>=rightResult:getTotalMultiple() then
            finalResult=leftResult
            side=CALCULATION_SIDE.LEFT
        else
            finalResult=rightResult
            side=CALCULATION_SIDE.RIGHT
        end
    end
    finalResult:setSide(side)
    --[[
    for i=1,#singleLine do
        print("     singleLine:"..singleLine[i]:toString())
    end
    ]]
    --print("finalResult:"..finalResult:getSettleType()..","..finalResult:getMaxCnt())

    return finalResult
end

--取出最大结算倍数的奖励类型
function CalculationUtil.getMaxSettleMultiple(machineId,possibleSettles)
    if table.isEmpty(possibleSettles)==true then
        return nil
    end
    local maxSettle=nil
    local tmpSettles={}
    for i=1,#possibleSettles do
        local rewardSettlePattern=possibleSettles[i]
        local settlePayTable=fetchMachinePaytable(rewardSettlePattern:getSettleType(),rewardSettlePattern:getMaxCnt(),machineId)
        if settlePayTable ~= nil then
            --print("getMaxSettleMultiple key:"..settlePayTable.key..",multiple:"..settlePayTable.multiple)
            rewardSettlePattern:seTotalMultiple(settlePayTable.multiple)
            rewardSettlePattern:setMaxCnt(settlePayTable.symbol_cnt)
            table.insert(tmpSettles,rewardSettlePattern)
        end
    end
    
    if table.isEmpty(tmpSettles)==true then
        return nil
    end
    
    --降序排列
    local sortFunc = function(a, b) return b:getTotalMultiple() < a:getTotalMultiple() end
    table.sort(tmpSettles,sortFunc)
    maxSettle=tmpSettles[1]
    
    return maxSettle
end

--结算bonus
function CalculationUtil.calculatBonus(roundResult,calculatLine)
    local machineId=roundResult:getRunMachineId()
    local machine=DICT_MACHINE[tostring(machineId)]
    --根据bonus结算类型选择结算方式
    if machine["bonus_trigger"]==BONUS_TRIGGER.Payline then
        for lineNum, lval in pairs(calculatLine) do
            local lstopPosMatrix={}
            for i=1,#lval do
                local tmp_ms=lval[i]
                lstopPosMatrix[CalculationUtil.buildCoordinate(tmp_ms:getX(),tmp_ms:getY())]=tmp_ms
            end

            local lbonusGroups=CalculationUtil.buildBonusGroups(roundResult:getRunMachineId(),lstopPosMatrix)
            --每条线的结算明细
            local lineCalculation=roundResult:fetchLinePattern(lineNum)
            if lineCalculation==nil then
                lineCalculation=LineCalculation.new(lineNum,roundResult)
            end
            --遍历规整出来的table,进行结算
            for lbkey, lbval in pairs(lbonusGroups) do
                local lsettleBonusDic=fetchBonusPaytable(lbkey,lbval)
                if lsettleBonusDic ~= nil then
                    local multiple=tonumber(lsettleBonusDic.multiple)
                    --增加总的bonus倍数
                    roundResult:addRewardItems(ITEM_TYPE.BONUS_MULITIPLE,multiple)
                    --增加线的中奖明细
                    lineCalculation:addWinItem(ITEM_TYPE.BONUS_MULITIPLE,multiple)
                    roundResult:addLinePattern(lineCalculation)
                    --将中奖图标添加进总的中奖图标集合里
                    local fsymbols=CalculationUtil.filterAllWinSymbols(lval,lsettleBonusDic.symbol_cnt,SYMBOL_TYPE.Bonus)
                    roundResult:addAllWinSymbols(fsymbols)
                    --设置线上中奖图标
                    lineCalculation:setWinSymbols(fsymbols)
                end
            end
        end
    else
        local stopPosMatrix=roundResult:getStopPosMatrix()
        local bonusGroups=CalculationUtil.buildBonusGroups(roundResult:getRunMachineId(),stopPosMatrix)
        --遍历规整出来的table,进行结算
        for bkey, bval in pairs(bonusGroups) do
            local settleBonusDic=fetchBonusPaytable(bkey,bval)
            if settleBonusDic ~= nil then
                local multiple=tonumber(settleBonusDic.multiple)
                --增加总的bonus倍数
                roundResult:addRewardItems(ITEM_TYPE.BONUS_MULITIPLE,multiple)
                --将中奖图标添加进总的中奖图标集合里
                local tmpSymbols= table.values(stopPosMatrix)
                local fsymbols=CalculationUtil.filterAllWinSymbols(tmpSymbols,settleBonusDic.symbol_cnt,SYMBOL_TYPE.Bonus)
                roundResult:addAllWinSymbols(fsymbols)
            end
        end
    end
end

--结算freespin
function CalculationUtil.calculatFreeSpin(roundResult,calculatLine)
    local machineId=roundResult:getRunMachineId()
    local machine=DICT_MACHINE[tostring(machineId)]
    --根据bonus结算类型选择结算方式
    if machine["spin_trigger"]==SPIN_TRIGGER.Payline then
        for lineNum, lval in pairs(calculatLine) do
            local lstopPosMatrix={}
            for i=1,#lval do
                local tmp_ms=lval[i]
                lstopPosMatrix[CalculationUtil.buildCoordinate(tmp_ms:getX(),tmp_ms:getY())]=lval[i]
            end
            local lbonusGroups=CalculationUtil.buildScatterGroups(roundResult:getRunMachineId(),lstopPosMatrix)
            --每条线的结算明细
            local lineCalculation=roundResult:fetchLinePattern(lineNum)
            if lineCalculation==nil then
                lineCalculation=LineCalculation.new(lineNum,roundResult)
            end
            --遍历规整出来的table,进行结算
            for lbkey, lbval in pairs(lbonusGroups) do
                local lsettleBonusDic=fetchScatterPaytable(lbkey,lbval)
                if lsettleBonusDic ~= nil then
                    local multiple=tonumber(lsettleBonusDic.multiple)
                    --增加总的bonus倍数
                    roundResult:addRewardItems(ITEM_TYPE.FREESPIN_MULITIPLE,multiple)
                    --增加线的中奖明细
                    lineCalculation:addWinItem(ITEM_TYPE.FREESPIN_MULITIPLE,multiple)
                    roundResult:addLinePattern(lineCalculation)
                    
                    --将中奖图标添加进总的中奖图标集合里
                    local fsymbols=CalculationUtil.filterAllWinSymbols(lval,lsettleBonusDic.symbol_cnt,SYMBOL_TYPE.Scatter)
                    roundResult:addAllWinSymbols(fsymbols)
                end
            end
        end
    else
        local stopPosMatrix=roundResult:getStopPosMatrix()
        local bonusGroups=CalculationUtil.buildScatterGroups(roundResult:getRunMachineId(),stopPosMatrix)
        --遍历规整出来的table,进行结算
        for bkey, bval in pairs(bonusGroups) do
            local settleBonusDic=fetchScatterPaytable(bkey,bval)
            if settleBonusDic ~= nil then
                local multiple=tonumber(settleBonusDic.multiple)
                --增加总的bonus倍数
                roundResult:addRewardItems(ITEM_TYPE.FREESPIN_MULITIPLE,multiple)
                --将中奖图标添加进总的中奖图标集合里
                local tmpSymbols= table.values(stopPosMatrix)
                local fsymbols=CalculationUtil.filterAllWinSymbols(tmpSymbols,settleBonusDic.symbol_cnt,SYMBOL_TYPE.Scatter)
                roundResult:addAllWinSymbols(fsymbols)
            end
        end
    end

end

function CalculationUtil.filterAllWinSymbols(matrixSymbols,count,symbolType)
    local tmp_count=0
    local fsymbols={}
    for f=1,#matrixSymbols do
         if tmp_count >= tonumber(count) then
               break
         end
         local symbolId=matrixSymbols[f]:getSymbolId()
         local symbol=DICT_SYMBOL[tostring(symbolId)]
         if symbol.symbol_type==symbolType then
                --roundResult:addAllWinSymbols(aval)
                table.insert(fsymbols,matrixSymbols[f])
                tmp_count=tmp_count+1
         end
    end
    return fsymbols
end

--规整出{settleType1=count1,settleType2=count2}
function CalculationUtil.buildSettleGroups(machineId,stopPosMatrix,symbolType)
    local settleGroups={}
    local machine=DICT_MACHINE[tostring(machineId)]
    local ignoreGrid=machine.ignore_grid
    for key, val in pairs(stopPosMatrix) do
        local isIgnore=containsCoordinate(val:getX(),val:getY(),ignoreGrid)
        --如果不在忽略的格子以内
        if isIgnore~=true then
            local symbolId=val:getSymbolId()
            local symbol=DICT_SYMBOL[tostring(symbolId)]
            if symbol==nil then
                print("CalculationUtil.buildSettleGroups#301:"..val:getCoordinate()..",idx="..val:getSymbolIdx())
                os.exit(0)
            end
            if symbol.symbol_type==symbolType then
                local settleType=symbol.settle_type
                    if settleGroups[settleType]==nil then
                        settleGroups[settleType]=0
                    end
                settleGroups[settleType]=settleGroups[settleType]+1
            end
        end
    end
    --[[
     for bkey, bval in pairs(settleGroups) do
        print(bkey,bval)
     end
    ]]
    return settleGroups
end


function CalculationUtil.buildBonusGroups(machineId,stopPosMatrix)
    return CalculationUtil.buildSettleGroups(machineId,stopPosMatrix,SYMBOL_TYPE.Bonus)
end

function CalculationUtil.buildScatterGroups(machineId,stopPosMatrix)
    return CalculationUtil.buildSettleGroups(machineId,stopPosMatrix,SYMBOL_TYPE.Scatter)
end

function CalculationUtil.calculatSpeedUpReelIdxs(roundResult)
    local stopMatrix=roundResult:getStopMatrix()
    local reelIdxs={}
    local bonusCnt=0
    local scatterCnt=0
    local signIdx=0
    local sign=false
    for i=1,#stopMatrix do
        if sign==true then
           break
        end
        local tmp_reel=stopMatrix[i]
        signIdx=i
        for k=1,#tmp_reel do
            if sign==true then
                break
            end
            local matrixSymbol=tmp_reel[k]
            local symbol=DICT_SYMBOL[tostring(matrixSymbol:getSymbolId())]
            if symbol.symbol_type==SYMBOL_TYPE.Bonus then
                bonusCnt=bonusCnt+1
            elseif symbol.symbol_type==SYMBOL_TYPE.Scatter then
                scatterCnt=scatterCnt+1
            end
            if bonusCnt==2 or scatterCnt==2 then
                sign=true
            end
        end
    end
    --::lab2:: --print("signIdx=",signIdx)
    
    
    local tmp_machine=DICT_MACHINE[tostring(roundResult:getRunMachineId())]
    local cols=tonumber(tmp_machine["reel_size"])
    if signIdx<=4 then
        for i=signIdx+1,cols do
            table.insert(reelIdxs,i)
        end
    end
    
    roundResult:setSpeedUpReelIdxs(reelIdxs)
end


