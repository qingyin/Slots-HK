module("app.data.slots.calculation.BonusGame", package.seeall)

local BonusGame = app.data.slots.calculation.BonusGame

local BonusValueUtil = require("app.data.slots.calculation.BonusValueUtil")

--根据一个groupId获得乱序的value数组
function BonusGame.generateGroupValuesBak(groupId)
    local values={}

    --[[
    local size=#groups
    math.random(size)
    local groupId=groups[math.random(size)]
    ]]

    local bg=DICT_BONUS_GROUP[tostring(groupId)]
    local elements=bg.elements
    for i=1,#elements do
        local tmp_vn=elements[i]
        local tmp_value=DICT_BONUS_VALUE[tostring(tmp_vn.x)]
        for k=1,tmp_vn.y do
            table.insert(values, clone(tmp_value))
        end
    end
    
    if table.isEmpty(values) ~= true then
       table.RandShuffle(values)
    end
    
    return values
end

function BonusGame.generateGroupValues(groupId)
    local values = {}

    local bg = DICT_BONUS_GROUP[tostring(groupId)]
    local elements = bg.elements
    for i = 1, #elements do
        local tmp_vn = elements[i]
        for k = 1, tmp_vn.y do
            table.insert(values, BonusValueUtil.getBonusValue(tmp_vn.x))
        end
    end
    
    if table.isEmpty(values) ~= true then
       table.RandShuffle(values)
    end
    
    return values
end

--适用于从多个group取出一个的box情况
function BonusGame.getBoxDisplay(bonusId)
    local bonus_config=DICT_BONUS_CONFIG[tostring(bonusId)]
    local groups=bonus_config.reward_config.groups
    
    if groups==nil then
       return nil
    end
    
    local size=#groups
    math.random(size)
    local groupId=groups[math.random(size)]
    print("BonusGame.getBoxDisplay groupId="..groupId)
    local result=BonusGame.generateGroupValues(groupId)
    return result
end

--对match3特殊处理
function BonusGame.getMatch3BoxDisplay(bonusId)
    local result = {}
    local values = BonusGame.getBoxDisplay(bonusId)
    for key, var in pairs(values) do
        for i = 1, 3 do
            table.insert(result, clone(var))
        end	
    end
    if table.isEmpty(result) ~= true then
       table.RandShuffle(result)
    end
    return result
end

--适用于多回合的情况
function BonusGame.getRoundDisplay(bonusId)
    local bonus_config=DICT_BONUS_CONFIG[tostring(bonusId)]
    local round=bonus_config.reward_config.round

    if round==nil then
       return nil
    end
    local rounds={}
    for i=1,#round do
        local groups=round[i]
        local size=#groups
        math.random(size)
        local groupId=groups[math.random(size)]
        local result=BonusGame.generateGroupValues(groupId)
        table.insert(rounds,result)
    end
    return rounds
end

function BonusGame.calculatBoxes(bonusGameSet,boxes)
    local settleItems={}
    local usedItems=bonusGameSet:getUsedItems()
    local bet=bonusGameSet:getBet()
    local baseMultiple=usedItems[ITEM_TYPE.BONUS_MULITIPLE]
    if baseMultiple==nil then
       baseMultiple=1
    end
    local dropMultiple=usedItems[ITEM_TYPE.DROP_MULITIPLE]
    if dropMultiple==nil then
        dropMultiple=1
    end
    
    --暂时把下落式倍率设置为1
    dropMultiple=1
    
    for i=1,#boxes do
        local box=boxes[i]
        local itemId=tonumber(box.type)
        local count=tonumber(box.value)
        local tmp_val=settleItems[itemId]
        if tmp_val==nil then
            settleItems[itemId]=0
        end
        settleItems[itemId]=settleItems[itemId]+tonumber(count)
    end
    
    local boosterMultiple=1
    --booster乘2
    local boosterMultiple2=usedItems[ITEM_TYPE.BOOSTER_MULITIPLE2]
    if boosterMultiple2 ~= nil then
       boosterMultiple=boosterMultiple*2*boosterMultiple2
    end
    --booster乘5
    local boosterMultiple5=usedItems[ITEM_TYPE.BOOSTER_MULITIPLE5]
    if boosterMultiple5 ~= nil then
       boosterMultiple=boosterMultiple*5*boosterMultiple5
    end
    print("boosterMultiple:"..boosterMultiple)
    local boxScore=1
    for itemId,count in pairs(settleItems) do
        if itemId==ITEM_TYPE.NORMAL_MULITIPLE then
            settleItems[itemId]=count*baseMultiple*dropMultiple*bet*boosterMultiple
            boxScore=count
        end
    end
    
    local totalCoins=settleItems[ITEM_TYPE.NORMAL_MULITIPLE]
    local bonusScore=baseMultiple*boxScore
    --local numExpression=string.format("%s = %sx%sx%s",tostring(totalCoins),tostring(bonusScore),tostring(bet),tostring(boosterMultiple))
    --local strExpression="COINS WIN = BONUS SCORE x BET x BOOSTER"
    local numExpression=string.format("%s = %sx%s",tostring(totalCoins),tostring(bonusScore),tostring(bet))
    local strExpression="COINS WIN = BONUS SCORE x BET"
    settleItems["numExpression"]=numExpression
    settleItems["strExpression"]=strExpression
    return settleItems
end

