local BonusGameSet=import("app.data.slots.beans.BonusGameSet")

local nodeStr = "node"
local viewNode = nil

local MachineApi = data.slots.MachineApi

--声明 BonusMatch3Scene 类
local BonusMatch3Scene = class("BonusMatch3Scene", function()
    return display.newNode()
end)

function BonusMatch3Scene:ctor(bonusidx, initData, gameType)

    --bonusidx = 9

    self.callback = initData.callback
    self.userModel = app:getObject("UserModel")

    self.dict = DICT_BONUS_CONFIG[tostring(bonusidx)]
    local ccbiFile = self.dict.ccbi

    viewNode = CCBuilderReaderLoad(ccbiFile, self)
    
    self.bonusIdx = bonusidx
    self.initData = initData
    self.bonusResult = MachineApi.getBonusMatch3Display(self.bonusIdx)

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

    self:init()
    
    self:Layout()

end

function BonusMatch3Scene:init()

    self.gameover = false
    self.totalMoney = 0
    self.check = {}
    self.selectBox = {}
    self.matchValue = 0

    for idx=1, 18 do
        local cellccbi = self.dict.cell.ccbi

        local cell = CCBuilderReaderLoad(cellccbi, self)
        local node = self[nodeStr..tostring(idx)]
        node:addChild(cell)
        node:setContentSize(cell:getContentSize())
        node.stone = self.stone
        node.rewards = self.rewards
        node.coinsnumber = self.coinsnumber
        node.cell = cell

        local index = math.random(#self.dict.cell.back_image)
        local backImage = self.dict.cell.back_image[index]..'.png'
        local frontImage = self.dict.cell.front_image[tostring(self.bonusResult[idx].id)]..'.png'

        if cc.SpriteFrameCache:getInstance():getSpriteFrame(backImage) then
            node.stone:setSpriteFrame(display.newSpriteFrame(backImage))
        end
        if cc.SpriteFrameCache:getInstance():getSpriteFrame(frontImage) then
            node.rewards:setSpriteFrame(display.newSpriteFrame(frontImage))
        end

        node.flip   = false
        node.type   = self.bonusResult[idx].type
        node.id     = self.bonusResult[idx].id
        node.value  = self.bonusResult[idx].value
        node.flag   = self.bonusResult[idx].flag
            
        self.check[node.value] = {}
        self.check[node.value].count = 0
        self.check[node.value].btns = {}
        
        node.coinsnumber:setString(tostring(node.value * self.basebet))

    end

    -- viewNode:addTouchEventListener(function(event, x, y)
    --     return self:onTouch(event, x, y)
    -- end)
    -- viewNode:setTouchEnabled(true)
end

function BonusMatch3Scene:checkNode(x, y)
    local pos = cc.p(x, y)
    for i = 1, 18 do
        local node = self[nodeStr..tostring(i)]
        if node.rewards:getCascadeBoundingBox():containsPoint(pos) then
            return node
        end
    end
    return nil
end

function BonusMatch3Scene:onTouch(event, x, y)

    if event == "began" then

        local node = self:checkNode(x, y)

        if node and node.flip == false then
            
            local x,y = node:getPosition()
            node.grade =node.value

            self.check[node.grade].count = self.check[node.grade].count + 1
            self.check[node.grade].type  = node.type
            self.check[node.grade].value = node.value
            self.check[node.grade].id    = node.id
            self.check[node.grade].flag  = node.flag
            self.check[node.grade].btns[#self.check[node.grade].btns + 1] = node

            self:runAnimationByName(node.cell, "open")

            local onComplete = function()
                if self.gameover == false then
                    self:checkGameOver()
                    if self.gameover == true then
            
                        for i = 1, 18 do
                            local node = self[nodeStr..tostring(i)]
                            if node and node.flip == false then
                                self:runAnimationByName(node.cell, "open")
                            end
                        end
                        
                        local animationComplete = function()
                            
                            for i = 1, 18 do
                                local node = self[nodeStr..tostring(i)]
                                if self.matchValue == node.value then
                                    self:runAnimationByName(node.cell, "matched")
                                else
                                    self:runAnimationByName(node.cell, "darken")
                                end
                            end

                            local backScene = function()
                                
                                self.bonusGameSet:setUsedItems(self.initData.rewardItems)
                                local wincoin = MachineApi.calculatBoxes(self.bonusGameSet,self.selectBox)
                                local coins = wincoin[ITEM_TYPE.NORMAL_MULITIPLE]

                                -- local ttcoins = User.getProperty(User.KEY_TOTALCOINS)
                                -- User.setProperty(User.KEY_TOTALCOINS, ttcoins + coins,true)

                                -- SCNM.popView("BonusWinView",{numexpress=wincoin["numExpression"], strexpress=wincoin["strExpression"],totalcoins=coins,
                                --     onComplete=function()
                                --         SCNM.backToLastScene(coins,"bonus")
                                --     end
                                --     }
                                -- )

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

function BonusMatch3Scene:checkGameOver()
    for key, val in pairs(self.check) do
        if val.count >= 3 then
            self.gameover = true
            -- viewNode:removeTouchEventListener()
            self:removeAllNodeEventListeners()
            self.matchValue = val.value
            self.totalMoney = val.value

            table.insert(self.selectBox, {
                type=self.check[key].type,
                id=self.check[key].id,
                value=self.check[key].value,
                flag=self.check[key].flag}
            )

        end
    end
end

function BonusMatch3Scene:onOpenComplete()
end

function BonusMatch3Scene:onExplore()
end

function BonusMatch3Scene:onEnter()
    -- audio.playMusic(self.dict.cell.bg_music, true)
end

function BonusMatch3Scene:onExit()
    -- audio.stopMusic(true)
    -- audio.unloadSound(self.dict.cell.bg_music)
end

function BonusMatch3Scene:runAnimationByName(target, name)
    if target.animationManager:getRunningSequenceName() == name then
        return
    end
    target.animationManager:runAnimationsForSequenceNamed(name)
end

return BonusMatch3Scene
