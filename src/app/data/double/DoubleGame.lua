module("app.data.double.DoubleGame", package.seeall)

local DoubleGame = app.data.double.DoubleGame

local DoubleResult=import("app.data.double.DoubleResult")


function DoubleGame.getDoubleResult(doubleType)
    local doubleResult=DoubleGame.randomDoubleResult(doubleType)
    if doubleType==DB.DOUBLE_TYPE.Spade then
        if doubleResult:getCardType()==DB.CARD_TYPE.Spade then
            doubleResult:setIsWin(1)
        end
    elseif doubleType==DB.DOUBLE_TYPE.heart then
        if doubleResult:getCardType()==DB.CARD_TYPE.heart then
            doubleResult:setIsWin(1)
        end
    elseif doubleType==DB.DOUBLE_TYPE.club then
        if doubleResult:getCardType()==DB.CARD_TYPE.club then
            doubleResult:setIsWin(1)
        end
    elseif doubleType==DB.DOUBLE_TYPE.diamond then
        if doubleResult:getCardType()==DB.CARD_TYPE.diamond then
            doubleResult:setIsWin(1)
        end
    elseif doubleType==DB.DOUBLE_TYPE.red then
        if doubleResult:getCardType()==DB.CARD_TYPE.heart or doubleResult:getCardType()==DB.CARD_TYPE.diamond then
            doubleResult:setIsWin(1)
        end
    elseif doubleType==DB.DOUBLE_TYPE.black then
        if doubleResult:getCardType()==DB.CARD_TYPE.Spade or doubleResult:getCardType()==DB.CARD_TYPE.club then
            doubleResult:setIsWin(1)
        end
    end
    
    return doubleResult
end

function DoubleGame.randomDoubleResult(doubleType)
    local doubleResult=DoubleResult.new(doubleType)
    math.random(#DB.CARD_NUM)
    local cardNum=DB.CARD_NUM[math.random(#DB.CARD_NUM)]
    
    local cc=table.nums(DB.CARD_TYPE)
    --print("#DB.CARD_TYPE:"..cc)
    math.random(cc)
    local cardTypeIdx=math.random(cc)
    local cardType=0
    
    local count=1
    for key,type in pairs(DB.CARD_TYPE) do
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