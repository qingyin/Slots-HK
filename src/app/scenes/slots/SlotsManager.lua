
local SlotsManager = class("SlotsManager")
local sm = SlotsManager

sm.sceInitDataStack = {}
sm.scheduler = require(cc.PACKAGE_NAME .. ".scheduler")

local initDataTpl = {
    frWinCoin       = 0,
    ttWinCoin       = 0,
    machineId       = 0,
    usedbstItem     = 0,
    frSpinCount     = 0,
    roundResult     = {},
    isDoSpinCk      = true,
    isFreeSpin      = false,
    hasPlayBouble   = false,  
}

-----------------------------------------------
-- PopInitDate
-----------------------------------------------
function sm.popInitDate()
    local rt = clone(sm.sceInitDataStack[1])
    table.remove(sm.sceInitDataStack, 1)
    return rt
end

-----------------------------------------------
-- BuildInitData
-----------------------------------------------
function sm.buildInitData()
    return clone(initDataTpl)
end

-----------------------------------------------
-- PushInitData:
-----------------------------------------------
function sm.pushInitData( initData )

    initData = clone(initData)    
    table.insert(sm.sceInitDataStack, 1, initData)

end

-----------------------------------------------
-- EnterMachine:
-----------------------------------------------
function sm.enterMachine( initData )
    scn.ScnMgr.replaceScene("slots.SlotsScene", {initData})
end

-----------------------------------------------
-- EnterMachine:
-----------------------------------------------
function sm.enterMachineById( machineId )
    
    local initData = sm.buildInitData()
    initData.machineId = machineId
    sm.enterMachine(initData)

end

-----------------------------------------------
-- EnterMachine:
-----------------------------------------------
function sm.joinSlotMachine( machineId, homeinfo )

    local coin = app:getObject("UserModel"):getCoins()
    local minBet = DICT_MACHINE[tostring(machineId)].bet_list[1]

    -- if coin < minBet then
    --     scn.ScnMgr.popView("ShortCoinsView", {callback = nil})
    --     return
    -- end
    
    local initData = sm.buildInitData()
    initData.machineId = machineId
    scn.ScnMgr.replaceScene("slots.SlotsScene", {initData, homeinfo},false)

end

-----------------------------------------------
-- @BackToLastMachine:
-- args.winCoins
-----------------------------------------------
function sm.backToLastMachine( args )
    local initData = sm.popInitDate()
    initData.ttWinCoin = initData.ttWinCoin + args.winCoins
    sm.enterMachine(initData)
end

-----------------------------------------------------
-- stopLabelStepCounter 
-----------------------------------------------------
function sm.stopLabelStepCounter(label)

    if label and label.counterEntry then
        sm.scheduler.unscheduleGlobal(label.counterEntry)
        label.counterEntry = nil
    end

end

-----------------------------------------------------
-- setLabelStepCounter 
-----------------------------------------------------
function sm.setLabelStepCounter(label, frNum, toNum, stepTime)

    local rTime = 1.5 
    local counterEntry   

    if stepTime then
        rTime = stepTime
    end

    if label.counterEntry then
        sm.scheduler.unscheduleGlobal(label.counterEntry)
        label.counterEntry = nil
    end

    local flag  = toNum - frNum
    local dtNum = math.abs(flag)

    if flag == 0 then
        return
    end
    
    local tick = function(dt)

        if not label then
            sm.scheduler.unscheduleGlobal(counterEntry)
            return
        end

        local dtNum_ = (dtNum/rTime) * dt 
        
        if flag > 0 then
            if frNum >= toNum then
                sm.scheduler.unscheduleGlobal(counterEntry)
                return
            end                 
            frNum = frNum + dtNum_
            frNum = frNum >= toNum and toNum or frNum
        else
            if frNum <= toNum then
                sm.scheduler.unscheduleGlobal(counterEntry)
                return
            end                    
            frNum = frNum - dtNum_
            frNum = frNum <= toNum and toNum or frNum
        end

        label:setString(number.commaSeperate((math.floor(frNum))))

    end

    counterEntry = sm.scheduler.scheduleGlobal(tick , 0)
    label.counterEntry = counterEntry

end

--------------------------------------
-- setAllChildrensZorder 
--------------------------------------
function sm.setAllChildrensZorder(target, var)
    target:setGlobalZOrder(var)
    local childrens = target:getChildren()
    for i=1, table.getn(childrens) do
        if childrens[i]:getChildrenCount() > 0 then
            childrens[i]:setGlobalZOrder(var)
            sm.setAllChildrensZorder(childrens[i], var)
        else
            childrens[i]:setGlobalZOrder(var)
        end
    end
end


return SlotsManager
