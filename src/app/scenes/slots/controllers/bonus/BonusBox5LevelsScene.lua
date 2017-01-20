local BonusGameSet=import("app.data.slots.beans.BonusGameSet")

--声明 BonusBox5LevelsScene 类
local BonusBox5LevelsScene = class("BonusBox5LevelsScene", function()
    return display.newNode()
end)

local obj = nil
local MachineApi = data.slots.MachineApi

function BonusBox5LevelsScene:ctor(bonusidx, initData, gameType)
    --print("BonusBox5LevelsScene:ctor")
    --bonusidx = 2

    self.callback = initData.callback
    self.userModel = app:getObject("UserModel")

    self.dict = DICT_BONUS_CONFIG[tostring(bonusidx)]

    local ccbiFile = self.dict.ccbi

    -- print("ccbiFile:", ccbiFile)

    self.ccbNode = CCBuilderReaderLoad(ccbiFile, self)
    
    self.bonusIdx = bonusidx
    self.bonusResult = MachineApi.getBonusBox5LevelsDisplay(self.bonusIdx)
    
    -- print("self.bonusResult:", self.bonusResult, self.bonusIdx)
    
    -- table.dump(self.bonusResult,"DICT_MATCH5")
    
    self.initData = initData

    self.bet = initData.bet
    self.basebet = self.initData.rewardItems[ITEM_TYPE.BONUS_MULITIPLE]
    self.bonusGameSet = BonusGameSet.new(self.bonusIdx, self.initData.bet)

    --effect = CCBuilderReaderLoad(GAME_CCBI.effect_bingbaopo, self)
    --effect:setPosition(3000, 3000)

    --self.bet = 10
    --self.bonusGameSet = BonusGameSet.new(self.bonusIdx, 10)
    --self.basebet = 5

    
    obj = self
    -- self.view = display.newLayer()
    -- self:addChild(self.view)

    self.gameover = false
    self.finished = false

    self.totalMoney = 0
    self.buttons = {}
    self.selectBox = {}
    self.level = 1
    self.deadlifecount = 0
   
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

    -- self.view:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
    --     return self:onTouch(event.name, event.x, event.y)
    -- end)
    -- self.view:setTouchEnabled(true)
    self:addChild(self.ccbNode)


    if display.width >= 1024 and display.height >= 768 then
        self.ccbNode:setScale(1)
    else
        self.ccbNode:setScale(0.9)
    end

    self:init()
    self:Layout()
end

function BonusBox5LevelsScene:init()
    self.onceover = false
    self.stepCount = 0
    self.touched = false

    self.onceResult = self.bonusResult[self.level]

    local index = 1;
    local nodenum = 6
    local ccbiFile = self.dict.cell.ccbi
        
    for idx = 1, nodenum do

        local node = self["node"..tostring(idx)]
        
        if node.cell ~= nil then
            node.cell:stopAllActions()
            self:runAnimationByName(node.cell,"idle")
        else
            local cell = CCBuilderReaderLoad(ccbiFile, self)
            node.cell = cell
            node:addChild(cell)
            node.back = self.back
            node.front = self.front
            node.coinsnumber = self.coinsnumber
        end

        node.flip = false
        node.match = false

        node.type   = self.onceResult[index].type
        node.id     = self.onceResult[index].id
        node.value  = self.onceResult[index].value
        node.flag   = self.onceResult[index].flag
        
        local backimage = self.dict.cell.back_image[self.level]..'.png'
        local frontimage = self.dict.cell.front_image[self.level]..'.png'

        if tonumber(node.flag) == 1 then
            frontimage = self.dict.cell.gameover_image..'.png'
        end

        if cc.SpriteFrameCache:getInstance():getSpriteFrame(backimage) then
            node.back:setSpriteFrame(display.newSpriteFrame(backimage))
        end
        if cc.SpriteFrameCache:getInstance():getSpriteFrame(frontimage) then
            node.front:setSpriteFrame(display.newSpriteFrame(frontimage))
        end
        
        if tonumber(node.value) == 0 then
            node.coinsnumber:setString("")
        else
            node.coinsnumber:setString(tostring(node.value*self.basebet))
        end

        index = index + 1
        
    end

    self.level = self.level + 1

end


function BonusBox5LevelsScene:checkButton(x, y)
    local pos = cc.p(x, y)
    for i = 1, 6 do
        local node = self["node"..tostring(i)]
        if node.back:getCascadeBoundingBox():containsPoint(pos) then
            return node
        end
    end
    return nil
end

function BonusBox5LevelsScene:stepTo(idx)
    local step = self["part"..tostring(idx)]
    if step ~= nil then
        step:setVisible(true)
    else
        if self.expressNum ~= nil then
            local str = tostring(idx).."/5"
            self.expressNum:setString(str)
        end
    end
end

function BonusBox5LevelsScene:onTouch(event, x, y)

    local touchcallback = function()

        local oncecallback = function()

            if self.onceover == true and self.finished == false then
            
                if self.stepCount == 0 then

                    if self.deadlifecount >= 1 then
                        self.gameover = true
                    end
        
                    if self.level == 6 then
                        self.gameover = true
                    end
        
                    if self.gameover == false then
                        self:init()
                    else
                
                        self.finished = true

                        local backScene = function()
                            obj.bonusGameSet:setUsedItems(self.initData.rewardItems)
                            local wincoin = MachineApi.calculatBoxes(self.bonusGameSet, self.selectBox)
                            puts("-------backScene----------")
                            puts(wincoin)
                            local coins = wincoin[ITEM_TYPE.NORMAL_MULITIPLE]

                            -- local ttcoins = User.getProperty(User.KEY_TOTALCOINS)
                            -- User.setProperty(User.KEY_TOTALCOINS, ttcoins + coins,true)
                        
                            -- SCNM.popView("BonusWinView",{numexpress=wincoin["numExpression"], strexpress=wincoin["strExpression"],totalcoins=coins,
                            --     onComplete=function()
                            --         SCNM.backToLastScene(coins, "bonus")
                            --     end
                            --     }
                            -- )
    
                            -- print("coins:", coins)

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

                        self:performWithDelay(backScene, 0.5)

                    end

                else
                    self.stepCount = self.stepCount + 1
                end
            end
        end

 
        for i = 1, 6 do
            local node = self["node"..tostring(i)]
            if node and node.flip == false then
                node.flip = true
                if tonumber(node.flag) == 1 then
                    self:runAnimationByName(node.cell,"open1")
                else
                    self:runAnimationByName(node.cell,"open")
                end
            end
        end
    
        local hasallflip = true
        for i = 1, 6 do
            local node = self["node"..tostring(i)]
            if node and node.flip == false then
                hasallflip = false
            end
        end
    
        if hasallflip == true then
            for i = 1, 6 do
                local node = self["node"..tostring(i)]

                if node.match == true and self.onceover == false then
                    self.onceover = true
                    self.stepCount = 0
                    self:runAnimationByName(node.cell,"matched")
                    self.totalGade:setString(tostring(self.totalMoney))

                    self:performWithDelay(oncecallback, 2)

                else
                    self:runAnimationByName(node.cell,"darken")
                end
            end
        end

    end

    if event == "began" and self.touched == false then

        local node = self:checkButton(x, y)

        if node and node.flip == false then
            
            node.grade = node.value
            
            self:stepTo(self.level-1)

            self.onceResult = self.bonusResult[self.level]

            if tonumber(node.flag) == 1 then
                self.deadlifecount = self.deadlifecount + 1
                node.grade = 0
            else
                table.insert(self.selectBox, {type=node.type,id=node.id,value=node.value,flag=nodeflag})
            end

            self.onceover = false
            node.match = true

            self.totalMoney = self.totalMoney + node.grade*self.basebet
            node.flip = true
            
            if tonumber(node.flag) == 1 then
                self:runAnimationByName(node.cell,"open1")
            else
                self:runAnimationByName(node.cell,"open")
            end
            
            self:runGodAnimation()

            self:performWithDelay(touchcallback, 1.5)

            self.touched = true

        end
        
        return true
    elseif event == "moved" then

    elseif event == "ended" then

    else -- cancelled

    end


end

function BonusBox5LevelsScene:onEnter()
    -- audio.playMusic( self.dict.cell.bg_music, true)
end

function BonusBox5LevelsScene:onExit()
    -- audio.stopMusic(true)
    -- audio.unloadSound( self.dict.cell.bg_music)
end

function BonusBox5LevelsScene:onExplore()
end

function BonusBox5LevelsScene:onOpenComplete()

    --if 1 then return end

end

function BonusBox5LevelsScene:runAnimationByName(target, name)
    if target.animationManager:getRunningSequenceName() == name then
        return
    end
    target.animationManager:runAnimationsForSequenceNamed(name)
end

--------------------------------------
-- runWinAnimation 
--------------------------------------
function BonusBox5LevelsScene:runGodAnimation()


    local animationMgr = self.ccbNode.animationManager

    local flag = animationMgr:getSequenceId('appear')

    -- print("flag:", flag)

    if flag == -1 then
        return
    end

    animationMgr:runAnimationsForSequenceNamed('appear')

end


return BonusBox5LevelsScene
