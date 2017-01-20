local SerialWild = class("SerialWild")

function SerialWild:ctor(reelId)
    self.reelId=reelId
    self.reelIdx = 0
    self.stopIdx=0
    self.newStopIdx=0
    self.moveSymbos= {}
    self.moveDirection=0
    self.middleSymbol=nil
end

function SerialWild:getReelId()
    return self.reelId
end

function SerialWild:getReelIdx()
    return self.reelIdx
end

function SerialWild:setReelIdx(reelIdx)
    self.reelIdx = reelIdx
end

function SerialWild:getStopIdx()
    return self.stopIdx
end

function SerialWild:setStopIdx(stopIdx)
    self.stopIdx = stopIdx
end

function SerialWild:getNewStopIdx()
    return self.newStopIdx
end

function SerialWild:setNewStopIdx(newStopIdx)
    self.newStopIdx = newStopIdx
end

function SerialWild:getMoveSymbos()
    return self.moveSymbos
end

function SerialWild:setMoveSymbos(moveSymbos)
    self.moveSymbos = moveSymbos
end

function SerialWild:insertMoveSymbol(moveSymbo)
    table.insert(self.moveSymbos,moveSymbo)
end

function SerialWild:setMoveDirection(moveDirection)
    self.moveDirection = moveDirection
end

function SerialWild:getMoveDirection()
    return self.moveDirection
end

function SerialWild:setMiddleSymbol(middleSymbol)
    self.middleSymbol = middleSymbol
end

function SerialWild:getMiddleSymbol()
    return self.middleSymbol
end

function SerialWild:toString()
    local str=string.format("reelId=%s,reelIdx=%s,stopIdx=%s,newStopIdx=%s,#moveSymbos=%s,moveDirection=%s]",tostring(self.reelId),tostring(self.reelIdx),tostring(self.stopIdx),tostring(self.newStopIdx),tostring(#self.moveSymbos),tostring(self.moveDirection))
    return str
end

return SerialWild