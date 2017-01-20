
local LineCalculation = class("LineCalculation")

function LineCalculation:ctor(lineNum,roundResult)
	self.lineNum = lineNum
    self.winSymbols={}
    self.winItems={}
    self.side=0
    self.roundResult = roundResult
    self.symbolId=0
end

function LineCalculation:getLineNum()
    return self.lineNum
end

function LineCalculation:getGameSet()
    return self.gameSet
end

--普通图标中奖坐标集合
function LineCalculation:setWinSymbols(winSymbols)
    self.winSymbols=winSymbols
end

function LineCalculation:addWinSymbols(matrixSymbol)
    table.insert(self.winSymbols,matrixSymbol)
end

function LineCalculation:getWinSymbols()
    return self.winSymbols
end

function LineCalculation:setWinItems(winItems)
    self.winItems=winItems
end

function LineCalculation:addWinItem(itemId,count)
    if self.winItems[itemId]==nil then
        self.winItems[itemId]=0
    end
    self.winItems[itemId]=self.winItems[itemId]+count
end

function LineCalculation:getWinItems()
    return self.winItems
end

function LineCalculation:setSide(side)
    self.side=side
end

function LineCalculation:getSide()
    return self.side
end

function LineCalculation:getWinSymbolId()
    return self.symbolId
end

function LineCalculation:setWinSymbolId(symbolId)
    self.symbolId=symbolId
end

function LineCalculation:getLineCoins()
    local count=self.winItems[ITEM_TYPE.NORMAL_MULITIPLE]
    if count==nil then
       count=0
    end
    
    local gameSet=self.roundResult:getGameSet()
    --原始赢得的钱
    local coins=gameSet:getBet()*count
    --下落式的倍率
    local dropMultiple=self.rewardItems[ITEM_TYPE.DROP_MULITIPLE]
    if dropMultiple~=nil then
       coins=coins*dropMultiple
    end
    
    local usedItems=gameSet:getUsedItems()
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

return LineCalculation
