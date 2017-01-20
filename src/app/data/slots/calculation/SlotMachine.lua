
local SlotMachine = class("SlotMachine")

local CalculationUtil = require("app.data.slots.calculation.CalculationUtil")
local MatrixUtil = require("app.data.slots.calculation.MatrixUtil")
local WildReelUtil = require("app.data.slots.calculation.WildReelUtil")
local MatrixSymbol=import("app.data.slots.beans.MatrixSymbol")
local RoundResult=import("app.data.slots.beans.RoundResult")
local WildHoldUtil = require("app.data.slots.calculation.WildHoldUtil")
local SerialWildUtil = require("app.data.slots.calculation.SerialWildUtil")

local dicMachine=DICT_MACHINE
local dicReels=DICT_REELS

function SlotMachine:ctor(gameSet)
	self.gameSet=gameSet
end

--正常获得回合结果
function SlotMachine:playRoundResult(roundResult)
    local runMachineId=roundResult:getRunMachineId()
    local machine=dicMachine[tostring(runMachineId)]
    local stopIdx,stopMatrix,stopPosMatrix=MatrixUtil.getReelStops(runMachineId,self.gameSet)
    
    
    --[[debug
    local newSymbol=stopMatrix[2][2]:clone()
    newSymbol:setSymbolId(31)
    stopMatrix[2][2]=newSymbol
    stopPosMatrix[newSymbol:getCoordinate()]=newSymbol]]
    

    --设置轴的停止位置
    roundResult:setReelStopIdxs(stopIdx)
    
    print("矩阵处理前:")
    local machine=DICT_MACHINE[tostring(runMachineId)]
    for j=1,tonumber(machine.max_row) do
        local str=""
        for i=1,#stopMatrix do
            str=str.." "..stopMatrix[i][j]:toString()
        end
        print(str)
    end
    
    --处理wildreel的情况
    local replaceWilds = WildReelUtil.handleWildReel(stopMatrix,stopPosMatrix)
    roundResult:setReplaceWilds(replaceWilds)
    
    --处理wildHold
    local holdWildResults = WildHoldUtil.handleWildHold(self.gameSet,stopMatrix,stopPosMatrix)
    roundResult:setHoldWilds(holdWildResults)
    
    --处理连续wild图标
    local serialWilds=SerialWildUtil.handleSerialWild(self.gameSet,stopIdx,stopMatrix,stopPosMatrix)
    roundResult:setSerialWilds(serialWilds)

    roundResult:setStopMatrix(stopMatrix)
    roundResult:setStopPosMatrix(stopPosMatrix)
    
    self:calculatRoundResult(roundResult)
    
    if table.isEmpty(roundResult:getRewardItems())==false then
        roundResult:setIsWin(IS_WIN.WIN)
    end
end

--下落式消除式的回合结果
function SlotMachine:playDropRoundResult(lastRoundResult,roundResult)
    local runMachineId=roundResult:getRunMachineId()
    local stopIdx,stopMatrix,stopPosMatrix=MatrixUtil.getDropReelStops(runMachineId,self.gameSet,lastRoundResult)

    --[[
    print("矩阵dddddd:")
    local machine=DICT_MACHINE[tostring(runMachineId)]
    for j=1,tonumber(machine.max_row) do
        local str=""
        for i=1,#stopMatrix do
            str=str.." "..stopMatrix[i][j]:toString()
        end
        print(str)
    end
    ]]
    
    --设置轴的停止位置
    roundResult:setReelStopIdxs(stopIdx)
    roundResult:setStopMatrix(stopMatrix)
    roundResult:setStopPosMatrix(stopPosMatrix)
    
    self:calculatRoundResult(roundResult)
    
    if table.isEmpty(roundResult:getRewardItems())==false then
        roundResult:setIsWin(IS_WIN.WIN)
    end

end

--结算
function SlotMachine:calculatRoundResult(roundResult)
    local machineId=roundResult:getRunMachineId()
    local calculatLine=CalculationUtil.buildCalculatLine(roundResult)
    --结算Bonus
    CalculationUtil.calculatBonus(roundResult,calculatLine)
    --结算freespin
    CalculationUtil.calculatFreeSpin(roundResult,calculatLine)
    --结算普通图标
    CalculationUtil.calculatNormalSymbol(roundResult,calculatLine)
    --计算加速转的轴
    CalculationUtil.calculatSpeedUpReelIdxs(roundResult)
end


--[[
    处理drop时需要配置倍率的情况
]]
function SlotMachine:handleDropMultiple(roundResult,index)
    local dropMultiple=DICT_MACHINE[tostring(roundResult:getRunMachineId())].drop_multiple
    
    if table.isEmpty(dropMultiple)==true then
        return
    end

    local baseMultiple=1
    local itemMultiple=roundResult:getGameSet():getUsedItems()[ITEM_TYPE.DROP_MULITIPLE]
    if itemMultiple~=nil then
        baseMultiple=itemMultiple
    end
    
    --暂时主场景下落倍率不带入freespin倍率
    baseMultiple=1

    local roundMubtiple=dropMultiple[index]
    
    if roundMubtiple==nil and index>#dropMultiple then
        roundMubtiple=dropMultiple[#dropMultiple]
    end
    
    roundResult:addRewardItems(ITEM_TYPE.DROP_MULITIPLE,tonumber(baseMultiple)*tonumber(roundMubtiple))

end

return SlotMachine


