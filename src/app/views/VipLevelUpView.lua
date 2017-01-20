

local LUV = class("VipLevelUpView",function()
    return display.newNode()
end)

function LUV:ctor(args)
    self:addChild(cc.LayerColor:create(cc.c4b(0, 0, 0, 200)))
    self:setNodeEventEnabled(true)
    self:setTouchEnabled(true)
    self:setTouchSwallowEnabled(true)

    local viewNode = CCBReaderLoad("view/VipLevelUpView.ccbi",self)
    self:addChild(viewNode)

    AnimationUtil.setContentSizeAndScale(viewNode)

    local model = app:getUserModel()
    self.vipLevel = model:getVipLevel()

    self:initUI()
    self:registerUIEvent()
end

function LUV:isVipUnlockMachine()
    local lobbyLayout = DICT_LAYOUT["2"]
    if lobbyLayout == nil then
        print("layout idx is null", layoutIdx)
        return
    end

    local userModel = app:getUserModel()
    local unLockVIPMachine = userModel:getUnLockVIPMachine()
    -- print("unLockVIPMachine:", unLockVIPMachine)
    -- print("self.vipLevel:", self.vipLevel)
    if self.vipLevel == 0 then
        unLockVIPMachine = "0"
    end

    local machine = nil

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
    if tonumber(unLockVIPMachine) ~= tonumber(machineList[num].unit_id) then
        for i = num, 1, -1 do
            local level = tonumber(machineList[i].unlock_condition)

            if (self.vipLevel >= level) and (tonumber(machineList[i].unit_id) > tonumber(unLockVIPMachine))then
                machine = machineList[i]

                userModel:setUnLockVIPMachine(machineList[i].unit_id)

                break
            end
        end
    end

    return machine

end

function LUV:registerUIEvent()
    core.displayEX.newButton(self.btn_ok)
    self.btn_ok.clickedCall = function()

        local unit = self:isVipUnlockMachine()
        --print(tostring(unit))
        if unit ~= nil then
            scn.ScnMgr.popView("VipUnLockMachineView", {unit = unit, vipLevel = self.vipLevel})  
        end
        EventMgr:dispatchEvent({name=EventMgr.UPDATE_LOBBYUI_EVENT})
        scn.ScnMgr.removeView(self)
    end

end

function LUV:initUI()

    local item = DICT_VIP[tostring(self.vipLevel)]
    if item ~= nil and cc.SpriteFrameCache:getInstance():getSpriteFrame(item.picture) then
        self.smallVipSprite:setSpriteFrame(item.picture)
    end

    local image = "viplevelup_"..item.alias.."_01.png"
    if item ~= nil and cc.SpriteFrameCache:getInstance():getSpriteFrame(image) then
        self.bigVipSprite:setSpriteFrame(image)
    end

end


function LUV:onEnter()

end

function LUV:onExit()
    self:removeAllNodeEventListeners()
end

return LUV