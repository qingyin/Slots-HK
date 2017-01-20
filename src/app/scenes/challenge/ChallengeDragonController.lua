local Controller = class("ChallengeDragonController", function()
    return display.newScene("ChallengeDragonController")
end)
local ccb = {
    main = "lobby/challengegame/machine_boss_bonus.ccbi",
    girl = "lobby/challengegame/machine_boss_girl.ccbi",
    dragon = "lobby/challengegame/machine_boss_loong.ccbi",
    chest = "lobby/challengegame/machine_boss_chest.ccbi",
    coin = "lobby/challengegame/machine_boss_coin.ccbi",
    fireball = "lobby/challengegame/machine_bonus_boss_fireball.ccbi",
    hit = "lobby/challengegame/machine_bonus_boss_Hit.ccbi",
}

function Controller:ctor(unit)

    local scene = CCBReaderLoad(ccb.main, self)
    self:addChild(scene)

    self.girl = CCBReaderLoad(ccb.girl, self)
    self.actorNode:addChild(self.girl)

    self.dragon = CCBReaderLoad(ccb.dragon, self)
    self:addChild(self.dragon)

    self.totalMoney = 0
    self.rewards = {3000, 10000, 50000, 1000000}
    self.lifeNumber = 2
    self.step = 2

    self.gameover = false
    self.going = false
    self:init()
end

function Controller:init()
    self["text1"]:setString("1")
    self["text1"].number = 1

    local reward = self["rewardNode"..1]
    local parent = reward:getParent()
    local pt = parent:convertToWorldSpace(cc.p(reward:getPosition()))
    self.dragon:setPosition(pt.x+80, pt.y+80)

    local fpX, fpY = self.fireEffect:getPosition()
    self.fireEffect:setPosition(fpX, pt.y-50)

    local nodenum,upNumber,preNumber = 24,49,1
    for idx = self.step, nodenum do
        local txt = self["text"..idx]
        txt:setVisible(false)

        local rnumber = 0
        if idx == nodenum-1 or idx == nodenum-2 then-- the last step not win
            rnumber = math.random(21,  29)
        else
            rnumber = math.random(upNumber)
        end

        while preNumber == rnumber do
            if idx == nodenum-1 or idx == nodenum-2 then-- the last step not win
                rnumber = math.random(21,  29)
            else
                rnumber = math.random(upNumber)
            end
        end
        txt.number = rnumber
        txt:setString(txt.number)
        preNumber = rnumber
    end

    for idx = 1, 4 do
        local reward = self["rewardNode"..idx]
        self["rewardCoin"..idx] = {}
        if idx==4 then
            self["rewardCoin"..idx].node = CCBReaderLoad(ccb.chest, self)
        else
            self["rewardCoin"..idx].node = CCBReaderLoad(ccb.coin, self)
        end
        self.rewardNumber:setString(self.rewards[idx])
        self["rewardCoin"..idx].rewardNumber = self.rewardNumber
        reward:addChild(self["rewardCoin"..idx].node)
    end

    local txt2 = self["text2"]
    local parent = txt2:getParent()
    local pt = parent:convertToWorldSpace(cc.p(txt2:getPosition()))

    self.upDwon:setPosition(pt.x,pt.y)

    core.displayEX.newButton(self.upBtn)
    core.displayEX.newButton(self.downBtn)
    core.displayEX.newButton(self.questionmarkBtn)

    self.upBtn.clickedCall = function(event)
        if self.going == true or self.gameover == true or self.lifeNumber < 1 then return end
        self.going = true
        --audio.playSound(GAME_SFX.btnClick, false)
        self:guess(1)
    end

    self.downBtn.clickedCall = function(event)
        if self.going == true or self.gameover == true or self.lifeNumber < 1 then return end
        self.going = true
        --audio.playSound(GAME_SFX.btnClick, false)
        self:guess(2)
    end
end

function Controller:reset()
    self.lifeNumber = 2
    for idx = 1, 2 do
        self["shield"..idx]:setVisible(true)
    end
end

function Controller:guess(type)
    local val = self:checkNumber(type)
    local txt = self["text"..self.step]
    txt:setVisible(true)
    self.wenhaoLabel:setVisible(false)

    if val == true then
        txt:setColor(display.COLOR_GREEN)
        --audio.playSound(GAME_SFX.dragon_fail, false)
        self:stepTo(val)
    else
        txt:setColor(display.COLOR_RED)
        --audio.playSound(GAME_SFX.dragon_go, false)
        self:runAnimationByName(self.dragon, "attack")
        local delaytime = self:hitDragon()

        local finishedHit = function()
            self["shield"..self.lifeNumber]:setVisible(false)
            self.lifeNumber = self.lifeNumber - 1

            if self.lifeNumber < 1 or self.step == 24 then
                self:runAnimationByName(self.girl, "death")
                self:performWithDelay(function()
                    self:gameOver(false)
                end, 1)
            else
                self:stepTo(val)
            end
        end
        self:performWithDelay(finishedHit, delaytime)
    end
end

function Controller:changeResult(type)

end

function Controller:checkNumber(type)
    local pretxt = self["text"..(self.step-1)]
    local txt = self["text"..self.step]

    if type == 1 then
        if txt.number > pretxt.number then
            if self.step == 23 or self.step == 24 then -- the last step not win
                txt.number = pretxt.number - math.random(3)
                txt:setString(txt.number)
                return false
            end
            return true
        end
    elseif type ==2 then
        if txt.number < pretxt.number then
            if self.step == 23 or self.step == 24 then -- the last step not win
                local upNumber = 49
                txt.number = pretxt.number + math.random(3)
                txt:setString(tostring(txt.number))
                return false
            end
            return true
        end
    end
    return false
end

function Controller:stepTo(val)
    self.upBtn:setVisible(false)
    self.downBtn:setVisible(false)
    self:runAnimationByName(self.girl, "walk")

    if self.step == 6 or self.step == 12 or self.step == 18 or self.step == 24 then

        local txt = self["text"..self.step]
        local parent = txt:getParent()
        local pt = parent:convertToWorldSpace(cc.p(txt:getPosition()))
        local index = self.step/6

        local coins = tonumber(self["rewardCoin"..index].rewardNumber:getString())
        self.totalMoney = self.totalMoney + coins

        if index > 4 then index = 4 end

        transition.moveTo(self.upDwon, {
            x     =  pt.x+500,
            y     =  pt.y,
            time  =  0.8,

            onComplete = function()

                local rewardCoin = self["rewardCoin"..index].node
                self:runAnimationByName(rewardCoin, "disappear")

                local animationCall = function()
                    local from = tonumber(self.totalCoins:getString())
                    local to = self.totalMoney
                    AnimationUtil.animateNumber(self.totalCoins, from, to, 1.0, "totalCoins")
                end

                AnimationUtil.MoveTo("#gold.png", 15, self["rewardCoin"..index].node, self.totalCoins, animationCall)

                local appearActor = function()
                    self["text"..(self.step + 1)]:setVisible(true)
                    self.step = self.step + 2
                    local txt = self["text"..self.step]
                    local parent = txt:getParent()
                    local pt = parent:convertToWorldSpace(cc.p(txt:getPosition()))
                    self:moveEffect(index+1)
                    self.upDwon:setPosition(pt.x-300, pt.y)

                    transition.moveTo(self.upDwon, {
                        x     =  pt.x,
                        y     =  pt.y,
                        time  =  0.8,
                        onComplete = function()
                            self.going = false
                            self.upBtn:setVisible(true)
                            self.downBtn:setVisible(true)
                            self.wenhaoLabel:setVisible(true)
                            self:runAnimationByName(self.girl, "idle")
                            self:moveDrogn(index+1)
                        end
                    })
                end

                if self.step < 24 then
                    self:performWithDelay(appearActor, 1)
                else
                    local rewardCoin = self["rewardCoin4"].node
                    self:runAnimationByName(rewardCoin, "disappear")

                    self:performWithDelay(function()
                        self:gameOver(true)
                    end,1.5)
                end
            end
        })
    else
        self.step = self.step + 1
        local txt = self["text"..self.step]
        local parent = txt:getParent()
        local pt = parent:convertToWorldSpace(cc.p(txt:getPosition()))

        transition.moveTo(self.upDwon, {
            x     =  pt.x,
            y     =  pt.y,
            time  =  0.5,
            onComplete = function()
                self.going = false
                self.upBtn:setVisible(true)
                self.downBtn:setVisible(true)
                self.wenhaoLabel:setVisible(true)
                self:runAnimationByName(self.girl, "idle")
            end
        })
    end
end

function Controller:gameOver(val)
    self.gameover = true
    local userModel = app:getObject("UserModel")
    local coins = userModel:getCoins()
    userModel:setCoins(coins + self.totalMoney)

    if self.totalMoney > 0 then
        scn.ScnMgr.addView("WheelBonusOK",{coins=self.totalMoney,vipbet=0,callback = function()
            scn.ScnMgr.replaceScene("lobby.LobbyScene")
        end} )
    else
        scn.ScnMgr.replaceScene("lobby.LobbyScene")
    end
end

function Controller:hitDragon()

    local parent = self.dragon:getParent()
    local ptStart = parent:convertToWorldSpace(cc.p(self.dragon:getPosition()))

    local parent = self.girl:getParent()
    local ptEnd = parent:convertToWorldSpace(cc.p(self.girl:getPosition()))

    local sp = CCBReaderLoad(ccb.fireball,{})
    sp:setPosition(ptStart.x-100, ptStart.y-30)
    self:addChild(sp)

    local movetime = (ptStart.x - ptEnd.x)/1000

    transition.moveTo(sp, {
        x     =  ptEnd.x,
        y     =  ptEnd.y,
        time  =  movetime,
        delay = 0.3,
        onComplete = function()
            sp:removeSelf(true)

            local eff = CCBReaderLoad(ccb.hit,{})
            eff:setPosition(ptEnd.x, ptEnd.y)
            self:addChild(eff)
            local removeEffect = function()
                eff:removeSelf(true)
            end

            self:performWithDelay(removeEffect, 0.8)

        end
    })

    return movetime + 0.8
end

function Controller:moveEffect(idx)
    local reward = self["rewardNode"..idx]
    local parent = reward:getParent()
    local pt = parent:convertToWorldSpace(cc.p(reward:getPosition()))

    self.fireEffect:setVisible(fasle)
    local x, y = self.fireEffect:getPosition()
    self.fireEffect:setPosition(x, pt.y-50)
end

function Controller:moveDrogn(idx)

    local reward = self["rewardNode"..idx]
    local parent = reward:getParent()
    local pt = parent:convertToWorldSpace(cc.p(reward:getPosition()))

    transition.moveTo(self.dragon, {
        x     =  pt.x + 80,
        y     =  pt.y + 80,
        time  =  0.2,
        onComplete=function()
            self.fireEffect:setVisible(true)
        end
    })

end

function Controller:onEnter()

    --[[AnimationUtil.EnterScale(self, 0.3,function()
        audio.playMusic( GAME_SFX.dragon_bg, true)
    end)]]
end

function Controller:onExit()
   -- audio.stopMusic(true)
   -- audio.unloadSound(GAME_SFX.dragon_bg)
end

function Controller:runAnimationByName(target, name)
    if target.animationManager:getRunningSequenceName() == name then
        return
    end
    target.animationManager:runAnimationsForSequenceNamed(name)
end


return Controller
