

local LUV = class("LevelUpView",function()
    return display.newNode()
end)

function LUV:ctor(args)
    --print("LevelUpView:ctor")
    self:addChild(cc.LayerColor:create(cc.c4b(0, 0, 0, 200)))
    self:setNodeEventEnabled(true)
    self:setTouchEnabled(true)
    self:setTouchSwallowEnabled(true)

    local viewNode = CCBReaderLoad("view/LevelUpView.ccbi",self)
    self:addChild(viewNode)

    AnimationUtil.setContentSizeAndScale(viewNode)

    self.level = args.level
    self.pastLevel = args.pastLevel
    self.isAnimation = false

    self:initUI()
    self:registerUIEvent()
end

function LUV:registerUIEvent()
    core.displayEX.newButton(self.btn_ok)
    self.btn_ok.clickedCall = function()
        if self.isAnimation then return end
        
        self:flyCoins()
    end
end

function LUV:initUI()
    local info = DICT_LEVEL[tostring(self.level)]
    local awardInfo = DICT_REWARD[tostring(info.reward_id)]
    self.coin = awardInfo.reward_coins
    self.vipPoint = info.vip_point

    self.levelLabel:setString(self.level)
    self.coinLabel:setString(number.commaSeperate(self.coin))
    self.vippoints:setString(number.commaSeperate(self.vipPoint))

    self.coinLabel:enableShadow(cc.c4b(23, 252, 255, 255), cc.size(2,-2))
    self.vippoints:enableShadow(cc.c4b(23, 252, 255, 255), cc.size(2,-2))

    app:getObject("ReportModel"):levelUP(tonumber(self.pastLevel), tonumber(self.coin), tonumber(self.vipPoint))



--    local call = function() end
--    local stepDelay = cc.DelayTime:create(0.6)
--    local callStepfunc = cc.CallFunc:create(call)
--    local acSequence = cc.Sequence:create(stepDelay, callStepfunc)
--    self:runAction(acSequence)

end

function LUV:unlockMachineByLevel()
    local userModel = app:getUserModel()
    local unLockMachine = userModel:getUnLockMachine()
    --print("unLockMachine:", unLockMachine)
    --print(self.level)
    local machine = nil

    local lobbyLayout = DICT_LAYOUT["1"]
    local cells = lobbyLayout.contain_unit
    local cols = #cells

    local machineList = {}

    for i=1, cols do
        local colcells = cells[i]

        local numCells = #colcells
        for cellidx = 1, numCells do

            local unitidx = colcells[cellidx]
            local unit = DICT_UNIT[tostring(unitidx)]
            if unit.type == "Slots" then
                machineList[#machineList + 1] = unit
            end
        end
    end

    local sortFunc = function(a, b)
        return tonumber(a.unlock_condition) < tonumber(b.unlock_condition)
    end
    table.sort(machineList, sortFunc)

    local num = #machineList
    if unLockMachine ~= machineList[num].unit_id then
        for i = num, 2, -1 do
            local level = tonumber(machineList[i].unlock_condition)
            if (self.level >= level) and (tonumber(machineList[i].unit_id) > tonumber(unLockMachine))then
                machine = machineList[i]

                userModel:setUnLockMachine(machineList[i].unit_id)

                break
            end
        end
    end

    return machine

end


function LUV:runAnimationByName(target, name)
    if target.animationManager:getRunningSequenceName() == name then
        return
    end
    target.animationManager:runAnimationsForSequenceNamed(name)
end

function LUV:flyCoins()

    self.isAnimation = true
    local handle = audio.playSound(RES_AUDIO.fly_coins, false)
    local callback = function()
        audio.stopSound(handle)
        local userModel = app:getUserModel()
        userModel:setCoins(userModel:getCoins() + self.coin)
        
        local unit = self:unlockMachineByLevel()
        if unit ~= nil then
            local machineIcon = unit.icon
            scn.ScnMgr.popView("UnLockMachineView", {machineIcon = machineIcon, vipPoint = self.vipPoint})
        else
            local viplevelup = userModel:setVipPoint(userModel:getVipPoint() + self.vipPoint)
            if viplevelup == true then
                scn.ScnMgr.popView("VipLevelUpView")
            end
        end

        EventMgr:dispatchEvent({name=EventMgr.UPDATE_LOBBYUI_EVENT})

        scn.ScnMgr.removeView(self)
    end

    AnimationUtil.flyTo("gold.png",10,self.coinLabel, app.coinSprite)
    self:performWithDelay(callback, 1.5)
end



function LUV:onEnter()

end

function LUV:onExit()
    self:removeAllNodeEventListeners()
end

return LUV