module("app.data.slots.calculation.WildHoldUtil", package.seeall)

local WildHoldUtil = app.data.slots.calculation.WildHoldUtil
local MatrixUtil = require("app.data.slots.calculation.MatrixUtil")
local MatrixSymbol=import("app.data.slots.beans.MatrixSymbol")
local CalculationUtil = require("app.data.slots.calculation.CalculationUtil")


--处理wildreel图标出现的各种情况
function WildHoldUtil.handleWildHold(gameSet,stopMatrix,stopPosMatrix)
    local holdWildResults={}
    local sourceWilds={}
    local holdWilds=gameSet:getHoldWilds()

    for pos, matrixSymbol in pairs(stopPosMatrix) do
        local wildReelSymbol=DICT_WILD_REEL[tostring(matrixSymbol:getSymbolId())]
        if wildReelSymbol~=nil then
           sourceWilds[pos]=matrixSymbol:clone()
           --print("原始图标:"..matrixSymbol:toString())
        end
    end

    --首先处理矩阵图标中为wildhold的情况,自动剔除已经hold的
    for pos, matrixSymbol in pairs(sourceWilds) do
        local wildReelSymbol=DICT_WILD_REEL[tostring(matrixSymbol:getSymbolId())]
        local wildReelType=wildReelSymbol.wild_reel_type
    
        if wildReelType==WILD_REEL_TYPE.WildHoldA then
            local isInHold=MatrixUtil.symbolInArray(matrixSymbol,holdWilds)
            if isInHold == false then
                WildHoldUtil.handleWildHoldA(matrixSymbol,holdWildResults,stopPosMatrix)
            end
        elseif wildReelType==WILD_REEL_TYPE.WildHoldB then
            local isInHold=MatrixUtil.symbolInArray(matrixSymbol,holdWilds)
            if isInHold == false then
                table.insert(holdWildResults,matrixSymbol)
                stopPosMatrix[matrixSymbol:getCoordinate()]=matrixSymbol
            end
        elseif wildReelType==WILD_REEL_TYPE.WildHoldC then
        
        end
        
    end

    for k=1,#holdWilds do
        local tmpSymbol=holdWilds[k]:clone()
        local wildReelSymbol=DICT_WILD_REEL[tostring(tmpSymbol:getSymbolId())]
        local wildReelType=wildReelSymbol.wild_reel_type
        if wildReelType==WILD_REEL_TYPE.WildHoldA then
            tmpSymbol:setStayRounds(tmpSymbol:getStayRounds()-1)
            table.insert(holdWildResults,tmpSymbol)
            stopPosMatrix[tmpSymbol:getCoordinate()]=tmpSymbol
        elseif wildReelType==WILD_REEL_TYPE.WildHoldB then
            local sourceSymbol=stopPosMatrix[tmpSymbol:getCoordinate()]
            if sourceSymbol~=nil then
                local hsymbol=sourceSymbol:clone()
                hsymbol:setSymbolId(tmpSymbol:getSymbolId())
                table.insert(holdWildResults,hsymbol)
                stopPosMatrix[hsymbol:getCoordinate()]=hsymbol
            end
        elseif wildReelType==WILD_REEL_TYPE.WildHoldC then
        
        end
    end
    
    for key, val in pairs(stopPosMatrix) do
        stopMatrix[val:getX()+1][val:getY()+1]=val
    end
    
    return holdWildResults
end

--处理wildHold图标
function WildHoldUtil.handleWildHoldA(matrixSymbol,holdWildResults,stopPosMatrix)
    local stayRounds=WildConfig[WILD_REEL_TYPE.WildHoldA].stay_rounds
    math.random(#stayRounds)
    matrixSymbol:setStayRounds(stayRounds[math.random(#stayRounds)])
    table.insert(holdWildResults,matrixSymbol)
    stopPosMatrix[matrixSymbol:getCoordinate()]=matrixSymbol
end
