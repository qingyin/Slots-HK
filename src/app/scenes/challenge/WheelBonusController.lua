local WheelBonus = class("WheelBonusController", function()
    return display.newScene("WheelBonusController")
end)


function WheelBonus:ctor(cell)

    self.viewNode  = CCBReaderLoad(RES_CCBI.wheelbonus, self)
    self:addChild(self.viewNode)

    --self:setTouchEnabled(true)

    self.cell = cell
    self.onspin = false
    self.spined = false
    self.hasspined = false

    local level = app:getUserModel():getVipLevel()

    if level > 0 then
        --self.vipstatusLabel:setString(DICT_VIP[tostring(level)].alias)
    else
        --self.vipstatusLabel:setString('')
    end

    local count = app:getUserModel():getProperty(scn.models.UserModel.wheelcount)
    --self.spinCountLabel:setString(tostring(count))

    self.vipbet = {2,3,5,10}
    self.coins = {300,600,200,300,1000,200,300,2000,200,300,400,200}
    self.weight = {10,5,20,10,2,20,10,1,20,10,8,20}

    self.totalWeight = 0
    for idx=1, #self.weight do
        --print(self.totalWeight)
        self.totalWeight = self.totalWeight + self.weight[idx]
    end

    local userlevel = app:getUserModel():getLevel()
    local lx = math.ceil( userlevel / 5 )

    for i=1, #self.coins do
        local coins = self.coins[i]
        coins = coins * lx
        self.coins[i] = coins
        self["number"..tostring(i)]:setString(tostring(coins))
    end

    for i=2, 5 do
        if i <= level then
            self["lock"..tostring(i-1)]:setVisible(false)
        else
            self.vipbet[i-1] = 1
        end
    end

    self:registerUIEvent()
end

function WheelBonus:randomWheelIdx()

    local weight = math.random(self.totalWeight)
    local totalW = 0

    for idx=1, #self.weight do

        local wval = self.weight[idx]

        if weight > totalW and weight <= (totalW + wval) then
            return idx
        end

        totalW = totalW + wval
    end

    return nil
end

function WheelBonus:onSpin()

    if self.onspin == true then return end

    local spinCount = 0


    if self.cell.state == 1 then
        spinCount = 1
    else
         spinCount = app:getUserModel():getProperty(scn.models.UserModel.wheelcount)
         if spinCount == 1 then
             app:getUserModel():setProperty(scn.models.UserModel.wheelcount, 0)
         end
    end

    if spinCount <= 0 then

         self.onspin = false

         local gems = app:getUserModel():getGems()
         if gems >= 2 then
             scn.ScnMgr.addView("CommonView", {title="Buy Bonus!", content="Buy one Bonus Spin!!!!", delayPopCall=function()
                 app:getUserModel():setGems(gems - 2)
                 app:getUserModel():setProperty(scn.models.UserModel.wheelcount, 1)
                 EventMgr:dispatchEvent({name  = EventMgr.UPDATE_LOBBYUI_EVENT})
                 self:onSpin()
             end} )
         else
             net.PurchaseCS:GetProductList(function(lists)
                 --body
                 scn.ScnMgr.addView("ProductsView",{productList=lists,tabidx=2})
             end)
         end

         return

    end

    if spinCount <= 0 then return end

    self.hasspined = true
    self.spined = true

    local wheelIdx = nil

    while wheelIdx == nil do
        wheelIdx = self:randomWheelIdx()
    end

    self.angle = 30 * wheelIdx
    self.angle = self.angle + 360 - math.random(18) + 360 * math.random(2)

    self.greySprite:setRotation(30-30 * wheelIdx)

    local function step(dealt)

        if self.roteAngle >= self.angle then

            local rote1 = self.wheelSprite1:getRotation()
            self.wheelSprite1:setRotation(rote1 - 360 * math.floor(rote1 / 360))

            local rote2 = self.wheelSprite2:getRotation()
            self.wheelSprite2:setRotation(rote2 - 360 * math.floor(rote2 / 360))

            local endrote1 = self.wheelSprite1:getRotation()-5
            if math.abs( endrote1 - 30 * math.floor(endrote1 / 30) ) < 5 then
                endrote1 = endrote1 + 3
            end

            local endrote2 = self.wheelSprite2:getRotation()+5
            if math.abs( endrote2 - 90 * math.floor(endrote2 / 90) ) < 5 then
                endrote2 = endrote2 + 3
            end

            self:performWithDelay(function()
            --audio.playSound(GAME_SFX.wheelrote, false)
            end,
                0.3)

            self:runAnimationByName(self.viewNode, "win")

            transition.rotateTo(self.wheelSprite1, {rotate=endrote1,time=1.5, delay=0.18, easing = "ELASTICOUT"})
            transition.rotateTo(self.wheelSprite2, {rotate=endrote2,time=1.5, delay=0.18, easing = "ELASTICOUT"})
            transition.rotateTo(self.spinIndicator,{rotate=0,time=1.5, delay=0.18, easing = "ELASTICOUT",onComplete=function()


                self.onspin = false
                self.hasspined = false

                local rotew2 = self.wheelSprite1:getRotation()
                local cellidx2 = rotew2 - 360 * math.floor(rotew2 / 360)
                cellidx2 = math.floor(cellidx2 / 90) + 1

                self:runAnimationByName(self.viewNode, "idle")

                local wincoins = self.coins[wheelIdx] * self.vipbet[cellidx2]

                if self.cell.state == 1 then

                    local callfunction = function(msg)

                       -- self.cell:initReward(msg)

                        scn.ScnMgr.addView("WheelBonusOK",{coins=self.coins[wheelIdx],vipbet=self.vipbet[cellidx2]} )
                    end

                    net.TimingRewardCS:pickTimingReward(callfunction, wincoins)
                else
                    scn.ScnMgr.addView("WheelBonusOK",{coins=self.coins[wheelIdx],vipbet=self.vipbet[cellidx2]} )
                end


            end})

            scheduler.unscheduleGlobal(self.schedulerEntry)
            self.schedulerEntry = nil
        end

        if self.needrandom == true and self.roteAngle >= self.startChangeRoteSpeed then
            self.needrandom = false
            self.times = 0
        end

        if self.needrandom == false then

            self.times = self.times + dealt

            if self.roteSpeed1 > self.stopspeed then
                self.roteSpeed1 = self.roteSpeed1 - dealt * 100
            elseif self.roteSpeed1 < self.stopspeed then
                self.roteSpeed1 = self.stopspeed
            end

            if self.roteSpeed2 > self.stopspeed then
                self.roteSpeed2 = self.roteSpeed2 - dealt * 100
            elseif self.roteSpeed2 < self.stopspeed then
                self.roteSpeed2 = self.stopspeed
            end
        else
            self.times = self.times + dealt
        end

        self.roteAngle = self.roteAngle + dealt*self.roteSpeed1
        self.onspinsound = self.onspinsound + dealt*self.roteSpeed1

        if self.onspinsound > 15 then
            self.onspinsound = 0
            --audio.playSound(GAME_SFX.wheelrote, false)
        end

        local rote1 = self.wheelSprite1:getRotation()
        self.wheelSprite1:setRotation(rote1+dealt*self.roteSpeed1)

        local rote2 = self.wheelSprite2:getRotation()
        self.wheelSprite2:setRotation(rote2-dealt*self.roteSpeed2)

        local r1 = rote1 - 360 * math.floor(rote1/360)
        local r2 = rote2 - 360 * math.floor(rote2/360)

        local rote3 = self.spinIndicator:getRotation()

        if self.direct == 0 then
            rote3 = rote3-dealt*100/self.times
        elseif self.direct == 1 then
            rote3 = rote3+dealt*100/self.times
        end

        if rote3 > 10 then
            self.direct = 0
            rote3 = 10
        elseif rote3  < 4 then
            self.direct = 1
            rote3 = 4
        end
        self.spinIndicator:setRotation(rote3)

    end

    self.onspin = true
    self.onspinsound = 0
    self.times = 0
    self.roteAngle = 0
    self.stopspeed = 50
    self.direct = 1
    self.needrandom = true
    self.startChangeRoteSpeed = self.angle - 480
    self.roteSpeed1 = 300
    self.roteSpeed2 = 300
    self.spinIndicator:setRotation(4)
    self.wheelSprite1:setRotation(0)
    self.wheelSprite2:setRotation(0)

    self.schedulerEntry = scheduler.scheduleGlobal(step, 0)

end

function WheelBonus:registerUIEvent()

    core.displayEX.newButton(self.btn_exit)
    :onButtonClicked(function(event)
    -- body
        if self.hasspined == true then return end
        scn.ScnMgr.replaceScene("lobby.LobbyScene")
    end)

    core.displayEX.newButton(self.spinBtn)
    :onButtonClicked(function(event)
    -- body
        self:onSpin()
    end)
end

function WheelBonus:onEnter()
    audio.playMusic(RES_AUDIO.wheel_bg)
end

function WheelBonus:onExit()
    if self.schedulerEntry ~= nil then
        scheduler.unscheduleGlobal(self.schedulerEntry)
    end
end



function WheelBonus:runAnimationByName(target, name)
    if target == nil then
        return false
    end
    if target.animationManager:getRunningSequenceName() == name then
        return false
    end
    target.animationManager:runAnimationsForSequenceNamed(name)

    return true
end

return WheelBonus