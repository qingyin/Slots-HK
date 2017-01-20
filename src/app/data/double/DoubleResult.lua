local DoubleResult = class("DoubleResult")


function DoubleResult:ctor(doubleType)
    self.doubleType=doubleType
    self.cardType=DB.CARD_TYPE.Spade
    self.cardNum=1
    self.isWin=0
    self.multiple=2
end

function DoubleResult:setCardType(cardType)
    self.cardType=cardType
end

function DoubleResult:getCardType()
    return self.cardType
end

function DoubleResult:setCardNum(cardNum)
    self.cardNum=cardNum
end

function DoubleResult:getCardNum()
    return self.cardNum
end

function DoubleResult:setIsWin(isWin)
    self.isWin=isWin
end

function DoubleResult:getIsWin()
    return self.isWin
end

function DoubleResult:getMultiple()
    if self.doubleType==DB.DOUBLE_TYPE.red or self.doubleType==DB.DOUBLE_TYPE.black then
        self.multiple=2
    else
        self.multiple=4
    end
    return self.multiple
end

function DoubleResult:toString()
    local str=string.format("DoubleResult[doubleType=%s,cardType=%s,cardNum=%s,multiple=%s,isWin=%s]",tostring(self.doubleType),tostring(self.cardType),tostring(self.cardNum),tostring(self.multiple),tostring(self.isWin))
    return str
end

return DoubleResult