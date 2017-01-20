
module("app.data.slots.MachineApi", package.seeall)
local MachineApi = app.data.slots.MachineApi

local SlotMachine=import("app.data.slots.calculation.SlotMachine")
local CalculationUtil = require("app.data.slots.calculation.CalculationUtil")
local MatrixSymbol=import("app.data.slots.beans.MatrixSymbol")
local RoundResult=import("app.data.slots.beans.RoundResult")
local DoubleGame=require("app.data.slots.calculation.DoubleGame")
local BonusGame=require("app.data.slots.calculation.BonusGame")

math.randomseed(os.time())
--获得正常回合结果
function MachineApi.getNormalRoundResult(gameSet)
    handleExpGameSet(gameSet)
    local tmp_machine=DICT_MACHINE[tostring(gameSet:getMachineId())]
    local f_mid=tmp_machine.f_machine_id
    
    if f_mid=="" then
        return MachineApi.getRoundResult(ROUND_MODE.FREESPIN,gameSet)
    else
        return MachineApi.getRoundResult(ROUND_MODE.NORMAL,gameSet)
    end
end

--获得消除类正常回合结果
function MachineApi.getNormalDropResult(gameSet)
    handleExpGameSet(gameSet)
    local tmp_machine=DICT_MACHINE[tostring(gameSet:getMachineId())]
    local f_mid=tmp_machine.f_machine_id
    
    if f_mid=="" then
        return MachineApi.getDropResult(ROUND_MODE.FREESPIN,gameSet)
    else
        return MachineApi.getDropResult(ROUND_MODE.NORMAL,gameSet)
    end
end

--获得下落式的结果
function MachineApi.getDropResult(roundMode,gameSet)
    local slotMachine=SlotMachine.new(gameSet)
    local dropResults={}

    local firstRoundResult=RoundResult.new(gameSet)
    local costCoins=gameSet:getBet()*gameSet:getLineNum()
    firstRoundResult:setCostCoins(costCoins)
    if roundMode==ROUND_MODE.FREESPIN then
        firstRoundResult:setCostCoins(0)
    end
    firstRoundResult:setRewardExp(costCoins)
    firstRoundResult:setRoundMode(roundMode)
    slotMachine:playRoundResult(firstRoundResult)
    
    slotMachine:handleDropMultiple(firstRoundResult,1)
    

    --插入第一回合结果
    table.insert(dropResults,firstRoundResult)
    
    local lastRoundResult=firstRoundResult
    local index=1
    while lastRoundResult:getIsWin()==IS_WIN.WIN  and index <100 do
        print("MachineApi:getDropResult#循环:"..index)
        lastRoundResult:print()
        local dropResult=RoundResult.new(gameSet)
        dropResult:setRewardExp(costCoins)
        dropResult:setRoundMode(roundMode)
        slotMachine:playDropRoundResult(lastRoundResult,dropResult)
        --只有赢的情况下才算回合倍率
        if dropResult:getIsWin()==IS_WIN.WIN then
            slotMachine:handleDropMultiple(dropResult,index+1)
        end
        table.insert(dropResults,dropResult)
        lastRoundResult=dropResult
        index=index+1
    end
    lastRoundResult:print()
    return dropResults
end

function MachineApi.getRoundResult(roundMode,gameSet)
    local slotMachine=SlotMachine.new(gameSet)
    local firstRoundResult=RoundResult.new(gameSet)
    local costCoins=gameSet:getBet()*gameSet:getLineNum()
    firstRoundResult:setCostCoins(costCoins)

    ----开始处理holdstep时不扣金币的情况
    local isStep=false
    local holdWilds=gameSet:getHoldWilds()
    for k=1,#holdWilds do
        local tmpSymbol=holdWilds[k]
        local wildReelSymbol=DICT_WILD_REEL[tostring(tmpSymbol:getSymbolId())]
        local wildReelType=wildReelSymbol.wild_reel_type
        if wildReelType==WILD_REEL_TYPE.WildHoldB then
            isStep=true
            break
        end
    end
    ----结束holdstep

    if roundMode==ROUND_MODE.FREESPIN or isStep==true then
        firstRoundResult:setCostCoins(0)
    end
    firstRoundResult:setRewardExp(costCoins)
    if isStep==true then
        firstRoundResult:setRewardExp(0)
    end
    firstRoundResult:setRoundMode(roundMode)
    slotMachine:playRoundResult(firstRoundResult)
    
    firstRoundResult:print()

    return firstRoundResult
end

--[[
   获得double game的游戏结果
]]
function MachineApi.getDoubleResult(doubleType)
    local result=DoubleGame.getDoubleResult(doubleType)
    --print(result:toString())
    return result
end

--BonusBoxLife3展示
function MachineApi.getBonusBoxLife3Display(bonusId)
    local result=BonusGame.getBoxDisplay(bonusId)
    return result
end

--BonusBox5Levels展示
function MachineApi.getBonusBox5LevelsDisplay(bonusId)
    local result=BonusGame.getRoundDisplay(bonusId)
    return result
end

--BonusMatch3展示
function MachineApi.getBonusMatch3Display(bonusId)
    local result=BonusGame.getMatch3BoxDisplay(bonusId)
    return result
end

--BonusJourney展示
function MachineApi.getBonusJourneyDisplay(bonusId)
    local result=BonusGame.getBoxDisplay(bonusId)
    --升序排列
    local sortFunc = function(a, b) return tonumber(a.value) < tonumber(b.value) end
    table.sort(result,sortFunc)
    return result
end

--翻出的箱子进行结算
function MachineApi.calculatBoxes(bonusGameSet,boxes)
    local result=BonusGame.calculatBoxes(bonusGameSet,boxes)
    return result
end

return MachineApi


