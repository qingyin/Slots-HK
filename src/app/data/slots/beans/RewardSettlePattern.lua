
local RewardSettlePattern = class("RewardSettlePattern")

function RewardSettlePattern:ctor(settleType)
    self.settleType = settleType
    self.maxCnt=0
    self.wildMultiple=1
    self.totalMultiple=0
    self.side=0
    self.symbolId=0
end

function RewardSettlePattern:getSettleType()
    return self.settleType
end

function RewardSettlePattern:setMaxCnt(maxCnt)
    self.maxCnt=maxCnt
end

function RewardSettlePattern:getMaxCnt()
    return self.maxCnt
end

function RewardSettlePattern:setWildMultiple(wildMultiple)
    self.wildMultiple=wildMultiple
end

function RewardSettlePattern:getWildMultiple()
    return self.wildMultiple
end

function RewardSettlePattern:getTotalMultiple()
    return self.totalMultiple
end

function RewardSettlePattern:seTotalMultiple(paytableMultiple)
    self.totalMultiple=tonumber(paytableMultiple)*self.wildMultiple
end

function RewardSettlePattern:setSide(side)
    self.side=side
end

function RewardSettlePattern:getSide()
    return self.side
end

function RewardSettlePattern:getWinSymbolId()
    return self.symbolId
end

function RewardSettlePattern:setWinSymbolId(symbolId)
    self.symbolId=symbolId
end

return RewardSettlePattern