
local MatrixSymbol = class("MatrixSymbol")

local CalculationUtil = require("app.data.slots.calculation.CalculationUtil")

function MatrixSymbol:ctor(x,y,symbolId,symbolIdx)
    self.x = x
    self.y= y
    self.symbolId=symbolId
    self.symbolIdx=symbolIdx
    self.stayRounds=0
end

function MatrixSymbol:getX()
    return self.x
end

function MatrixSymbol:getY()
    return self.y
end

--获得坐标x|y 格式
function MatrixSymbol:getCoordinate()
    return CalculationUtil.buildCoordinate(self.x,self.y)
end

function MatrixSymbol:getSymbolId()
    return self.symbolId
end

function MatrixSymbol:setSymbolId(symbolId)
    self.symbolId=symbolId
end

function MatrixSymbol:getSymbolIdx()
    return self.symbolIdx
end

function MatrixSymbol:setSymbolIdx(symbolIdx)
    self.symbolIdx=symbolIdx
end

function MatrixSymbol:getStayRounds()
    return self.stayRounds
end

function MatrixSymbol:setStayRounds(stayRounds)
    self.stayRounds=stayRounds
end


function MatrixSymbol:toString()
    local dicSymbol=DICT_SYMBOL[tostring(self.symbolId)]
    local type=""
    if dicSymbol ~= nil then
        type=dicSymbol.symbol_type
    end
    local str=string.format("[%s%s,%s,%s,%s,%s]",tostring(self.x),tostring(self.y),tostring(self.symbolId),tostring(self.symbolIdx),type,tostring(self.stayRounds))
    return str
end

function MatrixSymbol:clone()
    local matrixSymbol=MatrixSymbol.new(self.x,self.y,self.symbolId,self.symbolIdx)
    matrixSymbol:setStayRounds(self.stayRounds)
    return matrixSymbol
end

return MatrixSymbol