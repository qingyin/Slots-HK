--声明 WheelBonus 类
local WheelBonus = class("WheelBonus", function()
    return core.displayEX.newSwallowEnabledNode()
end)

function WheelBonus:ctor(cell)

    self:addChild(cc.LayerColor:create(cc.c4b(0, 0, 0, 200)))
    self.viewNode  = CCBReaderLoad(RES_CCBI.wheelbonus, self)
    self:addChild(self.viewNode)


    AnimationUtil.setContentSizeAndScale(self.viewNode)

    self:setTouchEnabled(true)

    self.cell = cell
    self.onspin = false
    self.spined = false
    self.hasspined = false
    
    local vipLevel = app:getUserModel():getVipLevel()
    local vipImage = "vip_0"..(vipLevel + 1)..".png"
    if cc.SpriteFrameCache:getInstance():getSpriteFrame(vipImage) then
        self.vip_sp:setSpriteFrame(vipImage)
    end

    self.costTip:setVisible(false)
    
    --local count = app:getUserModel():getProperty(scn.models.UserModel.wheelcount)
    --print("wheelcount: ", count)
    --self.spinCountLabel:setString(tostring(count))
    
    self.vipbet = {2,3,5,10}
    --self.coins = {300,600,200,300,1000,200,300,2000,200,300,400,200}
    self.coins = {2000,5000,1000,2000,8000,1000,2000,10000,1000,2000,3000,1000}
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
        if i <= vipLevel then
            self["lock"..tostring(i-1)]:setVisible(false)
        else
            self.vipbet[i-1] = 1
        end
    end
    
    self:registerUIEvent()

    self:loadSpriteFrame()
end

-- -----------------------------------------------------------
-- -- loadSpriteFrame
-- -----------------------------------------------------------
function WheelBonus:loadSpriteFrame()
    --display.addSpriteFrames("lobby/hk_bigwheel.plist","lobby/hk_bigwheel.pvr.ccz")

    local resPath = "lobby/hk_bigwheel.pvr.ccz"
    local plist = "lobby/hk_bigwheel.plist"

    display.addSpriteFrames(plist,resPath)
    
    local fullPath = cc.FileUtils:getInstance():fullPathForFilename(plist)
    local dict = cc.FileUtils:getInstance():getValueMapFromFile(fullPath)

    local spFrame
    for k,v in pairs(dict.frames) do
        spFrame = display.newSpriteFrame(k)
        spFrame:retain()
    end
end

-- -----------------------------------------------------------
-- -- unLoadSpriteFrame
-- -----------------------------------------------------------
function WheelBonus:unLoadSpriteFrame()

    local resPath = "lobby/hk_bigwheel.pvr.ccz"
    local plist = string.gsub(resPath, "pvr.ccz", "plist")
    
    local fullPath = cc.FileUtils:getInstance():fullPathForFilename(plist)
    local dict = cc.FileUtils:getInstance():getValueMapFromFile(fullPath)

    local spFrame
    for k,v in pairs(dict.frames) do
        spFrame = display.newSpriteFrame(k)
        spFrame:release()
    end
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
    print("self.cell.state : ", self.cell.state)
    print("spinCount : ",spinCount)

    if spinCount <= 0 then

        self.onspin = false
        net.PurchaseCS:GetProductList(function(lists)
            scn.ScnMgr.addView("AddWheelSpinsView",{productList=lists, buyCallback = function()
                    app:getUserModel():setProperty(scn.models.UserModel.wheelcount, 1)
                    self.timesArrows:setVisible(false)
                    self:changeBtnState(false)
                end})
        end)

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
                        --app.freeBonusData = msg
                        print("freeBonusData: ",tostring(msg))
                        if msg.result == 1 then
                            app.freeBonusData = {}
                            
                            app.freeBonusData.index = msg.index
                            app.freeBonusData.timeLeft = msg.timeLeft
                            app.freeBonusData.totalTime = msg.totalTime
                            app.freeBonusData.rewardCoins = msg.rewardCoins
                            app.freeBonusData.state = 0

                            self.cell:initReward(app.freeBonusData)  
                            self.cell.state = 0 

                            ------------------------------------------------------------------------      
                            local callback = function()
                                self.btn_exit:setVisible(true)
                                self:changeBtnState(true)
                                self:updateCoinsValue()
                                self.timesArrows:setVisible(true)
                                
                            end                      
                            scn.ScnMgr.addView("WheelBonusOK",{coins=self.coins[wheelIdx],vipbet=self.vipbet[cellidx2],callback = callback} )
                            ------------------------------------------------------------------------  
                        end
                    end

                    net.TimingRewardCS:pickTimingReward(callfunction, wincoins)
                else
                    ------------------------------------------------------------------------      
                    local callback = function()
                        self:removeView()
                    end
                    ------------------------------------------------------------------------ 
                    scn.ScnMgr.addView("WheelBonusOK",{coins=self.coins[wheelIdx],vipbet=self.vipbet[cellidx2],callback = callback} )
                end


            end})

            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerEntry)
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
    
    self.schedulerEntry = cc.Director:getInstance():getScheduler():scheduleScriptFunc(step, 0, false)

end

function WheelBonus:changeBtnState(flag)
    local images = {}
    if flag then
        images.n="btn_spin_199_n.png"
        images.s="btn_spin_199_s.png"
        images.d="btn_spin_199_d.png"
    else
        images.n="btn_spin_bingwell_n.png"
        images.s="btn_spin_bingwell_s.png"
        images.d="btn_spin_bingwell_d.png"
    end
    if cc.SpriteFrameCache:getInstance():getSpriteFrame(images.n) then
        --print("images.n:", images.n)
        core.displayEX.setButtonImages(self.spinBtn, images)
    end
end

function WheelBonus:updateCoinsValue()
    for i = 1, #self.coins do
        self.coins[i] = self.coins[i]*2
    end

    local userlevel = app:getUserModel():getLevel()
    local lx = math.ceil( userlevel / 5 )
    
    for i=1, #self.coins do
        local coins = self.coins[i]
        coins = coins * lx
        self.coins[i] = coins
        self["number"..tostring(i)]:setString(tostring(coins))
    end 
end


function WheelBonus:registerUIEvent()

    core.displayEX.newSmallButton(self.btn_exit)
        :onButtonClicked(function(event)
            -- body
            if self.hasspined == true then return end

            self:removeView()
        end)
    self.btn_exit:setVisible(false)

    core.displayEX.newButton(self.spinBtn, RES_AUDIO.wheel_spin)
        :onButtonClicked(function(event)
            -- body
            self:onSpin()
        end)
end

function WheelBonus:removeView()
    self:unLoadSpriteFrame()

    if self.schedulerEntry ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerEntry)
    end

    scn.ScnMgr.removeView(self)
end

function WheelBonus:onEnter()
end

function WheelBonus:onExit()
    if self.schedulerEntry ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerEntry)
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