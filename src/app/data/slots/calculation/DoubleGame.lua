module("app.data.slots.calculation.DoubleGame", package.seeall)

local DoubleGame = app.data.slots.calculation.DoubleGame

local DoubleResult=import("app.data.slots.beans.DoubleResult")


function DoubleGame.getDoubleResult(doubleType)
    local doubleResult=DoubleGame.randomDoubleResult(doubleType)
    if doubleType==DOUBLE_TYPE.Spade then
        if doubleResult:getCardType()==CARD_TYPE.Spade then
            doubleResult:setIsWin(IS_WIN.WIN)
        end
    elseif doubleType==DOUBLE_TYPE.heart then
        if doubleResult:getCardType()==CARD_TYPE.heart then
            doubleResult:setIsWin(IS_WIN.WIN)
        end
    elseif doubleType==DOUBLE_TYPE.club then
        if doubleResult:getCardType()==CARD_TYPE.club then
            doubleResult:setIsWin(IS_WIN.WIN)
        end
    elseif doubleType==DOUBLE_TYPE.diamond then
        if doubleResult:getCardType()==CARD_TYPE.diamond then
            doubleResult:setIsWin(IS_WIN.WIN)
        end
    elseif doubleType==DOUBLE_TYPE.red then
        if doubleResult:getCardType()==CARD_TYPE.heart or doubleResult:getCardType()==CARD_TYPE.diamond then
            doubleResult:setIsWin(IS_WIN.WIN)
        end
    elseif doubleType==DOUBLE_TYPE.black then
        if doubleResult:getCardType()==CARD_TYPE.Spade or doubleResult:getCardType()==CARD_TYPE.club then
            doubleResult:setIsWin(IS_WIN.WIN)
        end
    end
    
    return doubleResult
end

function DoubleGame.randomDoubleResult(doubleType)
    local doubleResult=DoubleResult.new(doubleType)
    math.random(#CARD_NUM)
    local cardNum=CARD_NUM[math.random(#CARD_NUM)]
    
    local cc=table.nums(CARD_TYPE)
    --print("#CARD_TYPE:"..cc)
    math.random(cc)
    local cardTypeIdx=math.random(cc)
    local cardType=0
    
    local count=1
    for key,type in pairs(CARD_TYPE) do
        if cardTypeIdx==count then
            cardType=type
            print("cardTypeIdx:"..cardTypeIdx..",type:"..cardType)
            break
        end
        count=count+1
    end
    
    doubleResult:setCardType(cardType)
    doubleResult:setCardNum(cardNum)
    
    return doubleResult
end