
module("app.data.slots.calculation.MatrixUtil", package.seeall)

local CalculationUtil = require("app.data.slots.calculation.CalculationUtil")
local ResultPoolUtil = require("app.data.slots.calculation.ResultPoolUtil")
local MatrixUtil = app.data.slots.calculation.MatrixUtil
local MatrixSymbol=import("app.data.slots.beans.MatrixSymbol")

local dicMachine=DICT_MACHINE
local dicReels=DICT_REELS

--[[
    获得每回合轴停止的位置
    {1,2,3}
    轴的矩阵table
    {
        {MatrixSymbol,MatrixSymbol,MatrixSymbol},
        {MatrixSymbol,MatrixSymbol,MatrixSymbol},
        {MatrixSymbol,MatrixSymbol,MatrixSymbol}
    }
    轴上点的key-value对应
    {
        "1|2"=MatrixSymbol,
        "1|2"=MatrixSymbol,
        "1|2"=MatrixSymbol,
        "1|2"=MatrixSymbol,
        "1|2"=MatrixSymbol,
        "1|2"=MatrixSymbol
    }
]]
function MatrixUtil.getReelStops(machineId,gameSet)
    local stopIdx={}
    local stopMatrix={}
    local stopPosMatrix={}

    local tmp_machine=dicMachine[tostring(machineId)]
    --轴的table
    local m_reels= tmp_machine["reels"]
    --行数
    local rows=tonumber(tmp_machine["max_row"])
    --列数
    local cols=tonumber(tmp_machine["reel_size"])
    
    --如果设定了结果奖池，则从奖池取结果
    -----------奖池-------------
    local presetResult = nil
    if gameSet:getPoolId() > 0 then
        presetResult = ResultPoolUtil.getResult(machineId, gameSet:getPoolId())
        gameSet:setPoolId(0)
    end
    -----------奖池-------------
    
    for i=1,cols do
        --轴Id
        local reelId=m_reels[i]
        --轴对象
        local tmp_reel=dicReels[tostring(reelId)]
        --轴上的图标table
        local tmp_symbols=tmp_reel["symbol_ids"]
        --图标table停止的位置
        local reel_size=#tmp_symbols
        local tmpIdx=math.random(reel_size)
        
        --如果有预设结果，则轴按结果停
        -----------奖池-------------
        if presetResult ~= nil and #presetResult == cols then
            tmpIdx = presetResult[i]
        end
        -----------奖池-------------
        
        --如果设置了holdreel的话，该轴停在制定位置
        local holdReelIdx=gameSet:getHoldReels()[i]
        if holdReelIdx~= nil then
            tmpIdx=holdReelIdx
        end
        
        --插入停止得位置
        table.insert(stopIdx,tmpIdx)
        
        --每一条轴图标和坐标位置存储的table
        local reel_matrix={}
        
        local start_idx=tmpIdx
        local rows=tonumber(tmp_machine["max_row"])
        for j=1,rows do
            local tmp_x=(i-1)*1
            local tmp_y=(j-1)*1
            local tmp_symbolId=tmp_symbols[start_idx]
            local pos=CalculationUtil.buildCoordinate(tmp_x,tmp_y)
            --图标坐标点的信息
            local tmp_matrix=MatrixSymbol.new(tmp_x,tmp_y,tmp_symbolId,start_idx)
            --将矩阵每个点的图标信息以坐标为key存在table中
            stopPosMatrix[pos]=tmp_matrix
            --构建每一条轴的坐标矩阵table
            table.insert(reel_matrix,tmp_matrix)
            
            if start_idx==reel_size then
                start_idx=1
            else
                start_idx=start_idx+1
            end
        end
        --将该条轴的矩阵table插入
        table.insert(stopMatrix,reel_matrix)
    end
    return stopIdx,stopMatrix,stopPosMatrix
end

--获得消除式玩法时的结果，根据前一轮的结果消除产生
function MatrixUtil.getDropReelStops(machineId,gameSet,roundResult)
    local lstopIdx=roundResult:getReelStopIdxs()
    local lstopMatrix=roundResult:getStopMatrix()
    local lstopPosMatrix=roundResult:getStopPosMatrix()
    
    local stopIdx={}
    local stopMatrix={}
    local stopPosMatrix={}
    
    local tmp_machine=dicMachine[tostring(machineId)]
    --配置轴的table
    local m_reels= tmp_machine["reels"]

    local winSymbols=roundResult:getAllWinSymbols()

    for i=1,#lstopMatrix do
        local reelId=m_reels[i]
        --轴对象
        local tmp_reel=dicReels[tostring(reelId)]
        --轴上的图标table
        local tmp_symbols=tmp_reel["symbol_ids"]
        --图标table停止的位置
        local reel_size=#tmp_symbols
        

        --旧的轴图标table
        local reelSymbols=lstopMatrix[i]
        --新的轴图标table
        local stopReelMatrix={}
        local tmp_cnt=0
        for k=1,#reelSymbols do
            local reelSymbol=reelSymbols[k]
            if winSymbols[reelSymbol:getCoordinate()]==nil then
                tmp_cnt=tmp_cnt+1
                local tmp_x=(i-1)*1
                local tmp_y=(tmp_cnt-1)*1
                local tmp_matrix=MatrixSymbol.new(tmp_x,tmp_y,reelSymbol:getSymbolId(),reelSymbol:getSymbolIdx())
                table.insert(stopReelMatrix,tmp_matrix)
                stopPosMatrix[tmp_matrix:getCoordinate()]=tmp_matrix
             end
         end
         local start_idx=reelSymbols[#reelSymbols]:getSymbolIdx()
         while tmp_cnt < #reelSymbols do
             if start_idx==reel_size then
                start_idx=1
             else
                start_idx=start_idx+1
             end
             tmp_cnt=tmp_cnt+1
             local tmp_x=(i-1)*1
             local tmp_y=(tmp_cnt-1)*1
             local tmp_symbolId=tmp_symbols[start_idx]
             local tmp_matrix=MatrixSymbol.new(tmp_x,tmp_y,tmp_symbolId,start_idx)
             table.insert(stopReelMatrix,tmp_matrix)
             stopPosMatrix[tmp_matrix:getCoordinate()]=tmp_matrix
           end
           
           table.insert(stopIdx,stopReelMatrix[1]:getSymbolIdx())
           table.insert(stopMatrix,stopReelMatrix)
    end
    return stopIdx,stopMatrix,stopPosMatrix
end


function MatrixUtil.symbolInArray(matrixSymbol,symbols)
    local flag=false
    for k=1,#symbols do
        local tmp_symbol=symbols[k]
        if tmp_symbol:getCoordinate() == matrixSymbol:getCoordinate() then
            flag=true
            break
        end
    end
    return flag
end


function MatrixUtil.getReelMatrix(gameSet,reelIdx,reelId,stopIdx)
    local reelMatrix={}
    local tmp_machine=DICT_MACHINE[tostring(gameSet:getMachineId())]
    --行数
    local rows=tonumber(tmp_machine["max_row"])

    --轴对象
    local dic_reel=DICT_REELS[tostring(reelId)]
    --轴上的图标table
    local dic_symbols=dic_reel["symbol_ids"]
    --轴长度
    local reel_size=#dic_symbols
    
    local start_idx=stopIdx
    for j=1,rows do
            local tmp_x=reelIdx-1
            local tmp_y=(j-1)*1
            local tmp_symbolId=dic_symbols[start_idx]
            local pos=CalculationUtil.buildCoordinate(tmp_x,tmp_y)
            --图标坐标点的信息
            local tmp_matrix=MatrixSymbol.new(tmp_x,tmp_y,tmp_symbolId,start_idx)
            --构建每一条轴的坐标矩阵table
            table.insert(reelMatrix,tmp_matrix)
            
            if start_idx==reel_size then
                start_idx=1
            else
                start_idx=start_idx+1
            end
    end
    
    return reelMatrix
end