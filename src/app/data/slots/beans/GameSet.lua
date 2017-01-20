
local GameSet = class("GameSet")

function GameSet:ctor(machineId,bet)
	self.machineId = machineId
    self.bet= bet
    self.usedItems={}
    self.holdReels={}
    self.holdWilds={}
    self.poolId = 0
    
    local tmp_machine=DICT_MACHINE[tostring(self.machineId)]
    local used_lines=tmp_machine["used_lines"]
    self.lineNum=#used_lines
end

function GameSet:getMachineId()
    return self.machineId
end

function GameSet:setLineNum(lineNum)
    self.lineNum=lineNum
end

function GameSet:getLineNum()
    return self.lineNum
end

function GameSet:getBet()
    return self.bet
end

function GameSet:getUsedItems()
    return self.usedItems
end

function GameSet:setUsedItems(usedItems)
    self.usedItems=usedItems
end

function GameSet:addUsedItem(itemId,num)
    if self.usedItems[itemId]==nil then
       self.usedItems[itemId]=0
    end
    self.usedItems[itemId]=num+self.usedItems[itemId]
end

--[[
格式如下,代表第一根轴hold idx位置为12;第四根轴hold位置是23
{1=12,
 4=23
}
]]
function GameSet:getHoldReels()
    return self.holdReels
end

function GameSet:setHoldReels(holdReels)
    self.holdReels=holdReels
end

function GameSet:addHoldReel(reelIdx,stopIdx)
    self.holdReels[reelIdx]=stopIdx
end

--[[
wildHold时的hold图标,格式如下:
{MatrixSymbol1,MatrixSymbol2}
]]
function GameSet:getHoldWilds()
    return self.holdWilds
end

function GameSet:setHoldWilds(holdWilds)
    self.holdWilds=holdWilds
end

function GameSet:getPoolId()
    return self.poolId
end

function GameSet:setPoolId(poolId)
    self.poolId = poolId
end

return GameSet