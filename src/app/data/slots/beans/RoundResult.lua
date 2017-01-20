
local RoundResult = class("RoundResult")

--每回合返回结果的bean对象
function RoundResult:ctor(gameSet)
    self.uniqueId=0
    self.gameSet = gameSet
    self.stopIdxs={}
    self.linePattern={}
    self.roundMode=ROUND_MODE.NORMAL
    self.isWin=IS_WIN.FAIL
    self.rewardCoins=0
    self.rewardExp=0
    self.rewardItems={}
    self.winSymbols={}
    self.costCoins=0
    self.replaceWilds={}
    self.fiveWin=0
    self.holdWilds={}
    self.serialWilds={}
    self.speedUpReelIdxs={}
end

function RoundResult:getGameSet()
    return self.gameSet
end

function RoundResult:setUniqueId(uniqueId)
    self.uniqueId=uniqueId
end

function RoundResult:getUniqueId()
    return self.uniqueId
end

--获得运行时的machine_id,正常模式就是初始值，freespin时是freespin的machine_id
function RoundResult:getRunMachineId()
    self.runMachineId=self:getGameSet():getMachineId()
    --[[
    if self:getRoundMode()==ROUND_MODE.FREESPIN then
        local tmp_machine=DICT_MACHINE[tostring(self.runMachineId)]
        self.runMachineId=tmp_machine["f_machine_id"]
    end
    ]]
    return self.runMachineId
end

--游戏模式
function RoundResult:setRoundMode(roundMode)
    self.roundMode=roundMode
end

function RoundResult:getRoundMode()
    return self.roundMode
end

--轴停止得位置
function RoundResult:setReelStopIdxs(stopIdxs)
    --print("     "..sz_T2S(stopIdxs))
    self.stopIdxs=stopIdxs
end

function RoundResult:getReelStopIdxs()
    return self.stopIdxs
end
--轴的矩阵table
function RoundResult:setStopMatrix(stopMatrix)
    self.stopMatrix=stopMatrix
end

function RoundResult:getStopMatrix()
    return self.stopMatrix
end

--轴上点的key-value对应
function RoundResult:setStopPosMatrix(stopPosMatrix)
    self.stopPosMatrix=stopPosMatrix
end

function RoundResult:getStopPosMatrix()
    return self.stopPosMatrix
end

--是否赢
function RoundResult:setIsWin(isWin)
    self.isWin=isWin
end

function RoundResult:getIsWin()
    return self.isWin
end

--[[
奖励道具
1000 普通奖励倍数
1001 bonus奖励倍数
3001 freespin次数
]]
function RoundResult:setRewardItems(rewardItems)
    self.rewardItems=rewardItems
end

--增加一个道具数量
function RoundResult:addRewardItems(itemId,count)
    if self.rewardItems[itemId]==nil then
        self.rewardItems[itemId]=0
    end
    self.rewardItems[itemId]=self.rewardItems[itemId]+count
end

function RoundResult:getRewardItems()
    return self.rewardItems
end

--奖励金币
function RoundResult:getRewardCoins()
    local count=self.rewardItems[ITEM_TYPE.NORMAL_MULITIPLE]
    if count==nil then
       count=0
    end
    --原始赢得的钱
    local coins=self.gameSet:getBet()*count
    --下落式的倍率
    local dropMultiple=self.rewardItems[ITEM_TYPE.DROP_MULITIPLE]
    if dropMultiple~=nil then
       coins=coins*dropMultiple
    end
    
    local usedItems=self.gameSet:getUsedItems()
    --booster乘2
    local boosterMultiple2=usedItems[ITEM_TYPE.BOOSTER_MULITIPLE2]
    if boosterMultiple2~=nil then
       coins=coins*2*boosterMultiple2
    end
    --booster乘5
    local boosterMultiple5=usedItems[ITEM_TYPE.BOOSTER_MULITIPLE5]
    if boosterMultiple5~=nil then
       coins=coins*5*boosterMultiple5
    end

    return coins
end

--每条线得获奖明细
function RoundResult:setLinePattern(linePattern)
    self.linePattern=linePattern
end

function RoundResult:addLinePattern(lineCalculation)
    self.linePattern[lineCalculation:getLineNum()]=lineCalculation
    if table.nums(lineCalculation:getWinSymbols())>4 then
        self.fiveWin=1
    end
end

function RoundResult:getLinePattern()
    return self.linePattern
end

function RoundResult:fetchLinePattern(lineNum)
    return self.linePattern[lineNum]
end

function RoundResult:setCostCoins(costCoins)
    self.costCoins=costCoins
end

function RoundResult:getCostCoins()
    return self.costCoins
end

--奖励经验
function RoundResult:setRewardExp(rewardExp)
    self.rewardExp=rewardExp
end

function RoundResult:getRewardExp()
    return self.rewardExp
end

--所有图标中奖坐标集合
function RoundResult:setAllWinSymbols(winSymbols)
    self.winSymbols=winSymbols
end

function RoundResult:addAllWinSymbol(matrixSymbol)
    self.winSymbols[matrixSymbol:getCoordinate()]=matrixSymbol
end

function RoundResult:addAllWinSymbols(matrixSymbols)
    for i=1,#matrixSymbols do
        self.winSymbols[matrixSymbols[i]:getCoordinate()]=matrixSymbols[i]
    end
end

function RoundResult:getAllWinSymbols()
    return self.winSymbols
end

--wildreel的替换集合
function RoundResult:setReplaceWilds(replaceWilds)
    self.replaceWilds=replaceWilds
end

function RoundResult:getReplaceWilds()
    return self.replaceWilds
end

function RoundResult:setHoldWilds(holdWilds)
    self.holdWilds=holdWilds
end

function RoundResult:getHoldWilds()
    return self.holdWilds
end

function RoundResult:getFiveWin()
    return self.fiveWin
end

function RoundResult:setSerialWilds(serialWilds)
    self.serialWilds=serialWilds
end

function RoundResult:getSerialWilds()
    return self.serialWilds
end

function RoundResult:setSpeedUpReelIdxs(reelIdxs)
    self.speedUpReelIdxs=reelIdxs
end

function RoundResult:getSpeedUpReelIdxs()
    return self.speedUpReelIdxs
end

--打印回合结果
function RoundResult:print()
    print("===================================")
    print("游戏设置:")
    print("     machineId:"..self:getGameSet():getMachineId())
    print("     bet:"..self:getGameSet():getBet())
    print("     lineNum:"..self:getGameSet():getLineNum())
    print("     usedItems:"..sz_T2S(self:getGameSet():getUsedItems()))
    print("     holdReels:"..sz_T2S(self:getGameSet():getHoldReels()))
    print("     runMachineId:"..self:getRunMachineId())
    print("     roundMode:"..self:getRoundMode())
    print("     UniqueId:"..self:getUniqueId())
    print("     holdWilds:")
         for i=1,#self:getGameSet():getHoldWilds() do
              print("         "..self:getGameSet():getHoldWilds()[i]:toString())
         end
    print("停止位置:")
    print("     "..sz_T2S(self:getReelStopIdxs()))
    print("矩阵:")
    local machine=DICT_MACHINE[tostring(self:getRunMachineId())]
    for j=1,tonumber(machine.max_row) do
        local str=""
        for i=1,#self:getStopMatrix() do
            str=str.."  "..self:getStopMatrix()[i][j]:toString()
        end
        print(str)
    end
    print("IsWin:"..self:getIsWin())
    print("RewardCoins:"..self:getRewardCoins())
    print("CostCoins:"..self:getCostCoins())
    print("RewardItems:")
        for itemId, count in pairs(self:getRewardItems()) do
            print("     item_id:"..itemId.."|count:"..count)
        end
    print("AllWinSymbols:")
        local str=""
        for key,value in pairs(self:getAllWinSymbols()) do
            str=str.." "..value:toString()
        end
        print("  "..str)
    print("ReplaceWilds:")
        for key,value in pairs(self.replaceWilds) do
            print("  "..value:toString())
        end
        
    print("holdWilds:")
        for i=1,#self.holdWilds do
            print("  "..self.holdWilds[i]:toString())
        end
    
    print("serialWilds:")
        for i=1,#self.serialWilds do
            print("  "..self.serialWilds[i]:toString())
        end
    print("speedUpReelIdxs:")
        print("     "..sz_T2S(self.speedUpReelIdxs))
    print("线中奖明细:")
        for lineNum,pattern in pairs(self:getLinePattern()) do
            print("     lineNum:"..lineNum)
            print("     side:"..pattern:getSide())
            print("     winSymbols:")
            local str=""
            for i=1,#pattern:getWinSymbols() do
                str=str.."   "..pattern:getWinSymbols()[i]:toString()
            end
            print("         "..str)
            
            print("     winItems:")
            for itemId, count in pairs(pattern:getWinItems()) do
                print("             item_id:"..itemId.."|count:"..count)
            end
        end
end


return RoundResult
