local BonusGameSet=import("app.data.slots.beans.BonusGameSet")

local nodeStr = "node"
local viewNode = nil

local MachineApi = data.slots.MachineApi

--声明 BonusBox3LifeScene 类
local BonusBox3LifeScene = class("BonusBox3LifeScene", function()
    return display.newNode()
end)

function BonusBox3LifeScene:ctor(bonusidx, initData, gameType)

   -- bonusidx = 10

    self.callback = initData.callback
    self.userModel = app:getObject("UserModel")

    --print("bonusidx:", bonusidx)

    self.dict = DICT_BONUS_CONFIG[tostring(bonusidx)]
    local ccbiFile = self.dict.ccbi

    viewNode = CCBuilderReaderLoad(ccbiFile, self)
    
    self.bonusIdx = bonusidx
    self.initData = initData
    self.bonusResult = MachineApi.getBonusBoxLife3Display(self.bonusIdx)
    -- table.dump(self.bonusResult,"DICT_MATCH5")
    -- puts("----------self.bonusResult----------")
    -- puts(self.bonusResult)

    self.bet = self.initData.bet
    self.basebet = self.initData.rewardItems[ITEM_TYPE.BONUS_MULITIPLE]
    self.bonusGameSet = BonusGameSet.new(self.bonusIdx, self.initData.bet)

    self:setNodeEventEnabled(true)
    self:setTouchEnabled(true)
    self:setTouchSwallowEnabled(true)
    self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        self:onTouch(event.name, event.x, event.y)
        if event.name == "began" then
            -- print("0000")
            return true
        end
    end)

    self:addChild(viewNode)


    if display.width >= 1024 and display.height >= 768 then
        viewNode:setScale(1)
    else
        viewNode:setScale(0.9)
    end

    self:init()
    
    self:Layout()

end

function BonusBox3LifeScene:init()

    self.gameover = false
    self.totalMoney = 0
    self.deadlifecount = 0
    self.selectBox = {}
    self.totalGade:setString("0")

    for idx=1, 20 do
        local cellccbi = self.dict.cell.ccbi

        local cell = CCBuilderReaderLoad(cellccbi, self)
        local node = self[nodeStr..tostring(idx)]
        node:addChild(cell)
        node:setContentSize(cell:getContentSize())
        node.badimage = self.badimage
        node.rewardsimage = self.rewardsimage
        node.coinsnumber = self.coinsnumber
        node.cell = cell

        node.flip   = false

        node.type   = self.bonusResult[idx].type
        node.id     = self.bonusResult[idx].id
        node.value  = self.bonusResult[idx].value
        node.flag   = self.bonusResult[idx].flag

        local backImage = self.dict.cell.back_image..'.png'
        local frontImage =nil
        
        if tonumber(node.flag) == 1 then
            frontImage = self.dict.cell.gameover_image..'.png'
        else
            frontImage = self.dict.cell.front_image..'.png'
        end

        if cc.SpriteFrameCache:getInstance():getSpriteFrame(backImage) then
            node.badimage:setSpriteFrame(display.newSpriteFrame(backImage))
        end
        if cc.SpriteFrameCache:getInstance():getSpriteFrame(frontImage) then
            node.rewardsimage:setSpriteFrame(display.newSpriteFrame(frontImage))
        end

        node.coinsnumber:setString(tostring(node.value * self.basebet))

    end

end

function BonusBox3LifeScene:checkNode(x, y)
    local pos = cc.p(x, y)
    for i=1, #self.bonusResult do
        local node = self[nodeStr..tostring(i)]
        if node.rewardsimage:getCascadeBoundingBox():containsPoint(pos) then
            return node
        end
    end
    return nil
end

function BonusBox3LifeScene:onTouch(event, x, y)

    if event == "began" then
    
        if self.gameover == true then return true end

        local node = self:checkNode(x, y)

        if node and node.flip == false then
            
            local x,y = node:getPosition()
            node.grade =node.value
            
            if tonumber(node.flag) == 1 then
                self.deadlifecount = self.deadlifecount + 1
                self:runAnimationByName(node.cell, "unmatch")
            else
                self.totalMoney = self.totalMoney + node.value * self.basebet
                self.totalGade:setString(tostring(self.totalMoney))
                self:runAnimationByName(node.cell, "match")
                table.insert(self.selectBox, { type=node.type, id=node.id, value=node.value, flag=node.flag} )
            end

            local onComplete = function()

                if self.gameover == false then
                    self:checkGameOver()
                    if self.gameover == true then
            
                        for i=1, 20 do
                            local node = self[nodeStr..tostring(i)]
                            if node and node.flip == false then
                                if tonumber(node.flag) == 1 then
                                    self:runAnimationByName(node.cell, "unmatch")
                                else
                                    self:runAnimationByName(node.cell, "match")
                                end
                            end
                        end
                        
                        local animationComplete = function()
                            
                            for i=1, 20 do
                                local node = self[nodeStr..tostring(i)]
                                
                                if node and node.flip == false then
                                    if tonumber(node.flag) == 1 then
                                        self:runAnimationByName(node.cell, "unmatch_darken")
                                    else
                                        self:runAnimationByName(node.cell, "match_darken")
                                    end
                                end

                            end

                            local backScene = function()
                                
                                self.bonusGameSet:setUsedItems(self.initData.rewardItems)
                                local wincoin = MachineApi.calculatBoxes(self.bonusGameSet,self.selectBox)
                                local coins = wincoin[ITEM_TYPE.NORMAL_MULITIPLE]

                                local ttcoins = self.userModel:getCoins()
                                self.userModel:setCoins(ttcoins + coins)

                                local args = {numexpress=wincoin["numExpression"], strexpress=wincoin["strExpression"],totalcoins=coins,
                                    onComplete=function()
                                        self.callback(coins)
                                        self:removeFromParent(true)
                                    end
                                }
                                
                                local winView = require("app.scenes.slots.views.BonusWinView").new(args)

                                self:addChild(winView)

                            end

                            self:performWithDelay(backScene, 1)

                        end

                        local array = {}
                        local delay = cc.DelayTime:create(1)
                        array[#array+1] = delay
                        array[#array+1] = cc.CallFunc:create(animationComplete)
                        local sqe = transition.sequence(array)
                        self:runAction(sqe)
                    end

                end
            end

            local array = {}
            local delay = cc.DelayTime:create(1)
            array[#array+1] = delay
            array[#array+1] = cc.CallFunc:create(onComplete)

            local sqe = transition.sequence(array)
            self:runAction(sqe)

            node.flip = true
        end

        return true
        
    elseif event == "moved" then

    elseif event == "ended" then

    else -- cancelled

    end

end

function BonusBox3LifeScene:checkGameOver()
    if self.deadlifecount >= 3 then
        self.gameover = true
    end
end

function BonusBox3LifeScene:onOpenComplete()
end

function BonusBox3LifeScene:onExplore()
end

function BonusBox3LifeScene:onEnter()
    -- audio.playMusic( self.dict.cell.bg_music, true)
end

function BonusBox3LifeScene:onExit()
    -- audio.stopMusic(true)
    -- audio.unloadSound( self.dict.cell.bg_music )
end

function BonusBox3LifeScene:runAnimationByName(target, name)
    if target.animationManager:getRunningSequenceName() == name then
        return
    end
    target.animationManager:runAnimationsForSequenceNamed(name)
end

return BonusBox3LifeScene
