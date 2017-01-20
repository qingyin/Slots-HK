module("app.data.slots.calculation.SerialWildUtil", package.seeall)

local SerialWildUtil = app.data.slots.calculation.SerialWildUtil
local MatrixUtil = require("app.data.slots.calculation.MatrixUtil")
local MatrixSymbol=import("app.data.slots.beans.MatrixSymbol")
local SerialWild=import("app.data.slots.beans.SerialWild")

function SerialWildUtil.handleSerialWild(gameSet,stopIdx,stopMatrix,stopPosMatrix)
    local serialWilds={}
    local dic_reels=DICT_MACHINE[tostring(gameSet:getMachineId())].reels
    
    for reelIdx=1,#stopMatrix do
        local reelId=dic_reels[reelIdx]
        local reel_symbols=stopMatrix[reelIdx]
        --轴对象
        local dic_reel=DICT_REELS[tostring(reelId)]
        --轴上的图标table
        local dic_symbols=dic_reel["symbol_ids"]
        --图标table停止的位置
        local reel_size=#dic_symbols
        local firstWild,lastWild=SerialWildUtil.pickSerialWild(reel_symbols)
        local tmp_stop_idx=stopIdx[reelIdx]
        if firstWild~=nil and lastWild~=nil then
            --三个图标均显示在轴上
            if lastWild:getY()-firstWild:getY()==2 then
                local serialWild = SerialWild.new(reelId)
                serialWild:setReelIdx(reelIdx)
                serialWild:setStopIdx(tmp_stop_idx)
                serialWild:setNewStopIdx(tmp_stop_idx)
                --[[
                serialWild:insertWildSymbol(firstWild)
                serialWild:insertWildSymbol(reel_symbols[firstWild:getY()+2])
                serialWild:insertWildSymbol(lastWild)
                ]]
                serialWild:setMiddleSymbol(reel_symbols[firstWild:getY()+2])
                serialWild:setMoveDirection(MOVE_DIRECTION.NONE)
                
                stopPosMatrix[firstWild:getCoordinate()]=firstWild
                stopPosMatrix[lastWild:getCoordinate()]=lastWild
                table.insert(serialWilds,serialWild)
            else
                local newStopIdx=0
                local reelStep=lastWild:getY()-firstWild:getY()
                local step=3-reelStep-1
                local reelMatrix ={}
                local direction=0
                --往下面加图标,轴往上移动
                if firstWild:getY()==reel_symbols[1]:getY() then
                    if tmp_stop_idx-step>0 then
                        newStopIdx=tmp_stop_idx-step
                    else
                        newStopIdx=reel_size+(tmp_stop_idx-step)
                    end
                    direction=MOVE_DIRECTION.DOWN
                elseif lastWild:getY()==reel_symbols[#reel_symbols]:getY() then
                --往上面加图标,轴往下移动
                    if tmp_stop_idx+step <= reel_size then
                        newStopIdx=tmp_stop_idx+step
                    else
                        newStopIdx=tmp_stop_idx+step-reel_size
                    end
                    direction=MOVE_DIRECTION.UP
                end
                reelMatrix = MatrixUtil.getReelMatrix(gameSet,reelIdx,reelId,newStopIdx)
                
                local fWild,lWild=SerialWildUtil.pickSerialWild(reelMatrix)
                local serialWild = SerialWild.new(reelId)
                serialWild:setReelIdx(reelIdx)
                serialWild:setStopIdx(tmp_stop_idx)
                serialWild:setNewStopIdx(newStopIdx)
                
                serialWild:setMiddleSymbol(reelMatrix[fWild:getY()+2])
                --print("lizpstep:",step)
                if direction == MOVE_DIRECTION.DOWN then
                    serialWild:setMoveDirection(MOVE_DIRECTION.DOWN)
                    for i=1,step do
                       serialWild:insertMoveSymbol(reelMatrix[i])
                    end
                elseif direction == MOVE_DIRECTION.UP then
                    serialWild:setMoveDirection(MOVE_DIRECTION.UP)
                    for i=#reelMatrix-step+1,#reelMatrix do
                       serialWild:insertMoveSymbol(reelMatrix[i])
                    end
                end

                for k=1,#reelMatrix do
                    stopPosMatrix[reelMatrix[k]:getCoordinate()]=reelMatrix[k]
                end
                
                table.insert(serialWilds,serialWild)
            end
            for key, val in pairs(stopPosMatrix) do
                stopMatrix[val:getX()+1][val:getY()+1]=val
            end
        end
    end
    return serialWilds
end

function SerialWildUtil.pickSerialWild(reel_symbols)
    local firstWild=nil
    local lastWild=nil
    
    for k=1,#reel_symbols do
        local matrixSymbol=reel_symbols[k]
        local wildReelSymbol=DICT_WILD_REEL[tostring(matrixSymbol:getSymbolId())]
        if wildReelSymbol~=nil then
            local wildReelType=wildReelSymbol.wild_reel_type
            if SerialWildUtil.isSerialWild(wildReelType)==true  then
                firstWild=matrixSymbol
                break
            end
        end
    end
    
    local desc_symbols=table.reverse(reel_symbols)
    
    for k=1,#desc_symbols do
        local matrixSymbol=desc_symbols[k]
        local wildReelSymbol=DICT_WILD_REEL[tostring(matrixSymbol:getSymbolId())]
        if wildReelSymbol~=nil then
            local wildReelType=wildReelSymbol.wild_reel_type
            if SerialWildUtil.isSerialWild(wildReelType)==true then
                lastWild=matrixSymbol
                break
            end
        end
    end

    return firstWild,lastWild
end

function SerialWildUtil.isSerialWild(wildReelType)
    if wildReelType==WILD_REEL_TYPE.SerialWild or wildReelType==WILD_REEL_TYPE.SerialWildSide then
        return true
    end
    return false
end