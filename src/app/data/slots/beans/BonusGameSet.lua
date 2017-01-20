local BonusGameSet = class("BonusGameSet")

function BonusGameSet:ctor(bonusId,bet)
    self.bet= bet
    self.usedItems={}
    self.bonusId=bonusId
end

function BonusGameSet:getBet()
    return self.bet
end

function BonusGameSet:getBonusId()
    return self.bonusId
end

function BonusGameSet:getUsedItems()
    return self.usedItems
end

function BonusGameSet:setUsedItems(usedItems)
    self.usedItems=usedItems
end

function BonusGameSet:addUsedItem(itemId,num)
    if self.usedItems[itemId]==nil then
       self.usedItems[itemId]=0
    end
    self.usedItems[itemId]=num+self.usedItems[itemId]
end

return BonusGameSet