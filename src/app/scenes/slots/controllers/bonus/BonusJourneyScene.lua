local BonusGameSet=import("app.data.slots.beans.BonusGameSet")

--声明 BonusJourneyScene 类
local BonusJourneyScene = class("BonusJourneyScene", function()
    return display.newNode()
end)

function BonusJourneyScene:ctor(bonusidx, initData, gameType)

    --bonusidx = 4

    self.callback = initData.callback
    self.userModel = app:getObject("UserModel")

    self.dict = DICT_BONUS_CONFIG[tostring(bonusidx)]
    local ccbiFile = DICT_BONUS_CONFIG[tostring(bonusidx)].ccbi
                     
    self.cell = DICT_BONUS_CONFIG[tostring(bonusidx)].cell

    self.cellCCB = self.cell.ccbi

    local node = CCBuilderReaderLoad(ccbiFile, self)

    self.bonusIdx = bonusidx
    self.initData = initData
    self.bonusResult = data.slots.MachineApi.getBonusJourneyDisplay(self.bonusIdx)
   
    self.bonusGameSet = BonusGameSet.new(self.bonusIdx, self.initData.bet)
    self.basebet = self.initData.rewardItems[ITEM_TYPE.BONUS_MULITIPLE]

    self.bet = self.initData.bet

    self:setNodeEventEnabled(true)
    self:setTouchEnabled(true)
    self:setTouchSwallowEnabled(true)
    self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        if event.name == "began" then
            -- print("0000")
            return true
        end
    end)


    self:addChild(node)

    self:init()
    self:Layout()
    self:registerEvent()

end

function BonusJourneyScene:init()

    self.gameover = false
    self.totalMoney = 0
    self.buttons = {}
    self.selectBox = {}
    self.ptsnum = 12
    self.ptsIdx = 1
    self.speed = 250

    self.stepValue = {1,2,3,1,2,3}
    self.stopValue = {1,1,1,1,1,1}
    self.stepIdx = 1

    local sWidth = 900
    local sHeight = 400


    local rows = 3
    local cols = 6

    local rowHeight = sHeight / rows
    local colWidth = sWidth / cols

    local startX = ( display.width - sWidth ) / 2 + colWidth / 2

    local y = display.height - ( display.height - sHeight ) / 2 - rowHeight / 2
    
    local index = 1;

    for idx = 1, self.ptsnum do
        
        local spot =self["spot"..tostring(idx)]

        local cell = CCBuilderReaderLoad(self.cellCCB, self)
        cell.spotSprite = self.spotSprite
        cell.winnumLabel = self.winnumLabel

        local image = self.cell.image[idx]..'.png'

        if cc.SpriteFrameCache:getInstance():getSpriteFrame(image) then
            cell.spotSprite:setSpriteFrame(display.newSpriteFrame(image))
        end
        
        local size = cell.spotSprite:getContentSize()

        local parentNode = spot:getParent()
        local x,y=spot:getPosition()
        cell:setPosition(x, y)
        parentNode:addChild(cell)
        
        spot:removeFromParent(true)

        self["spot"..tostring(idx)] = cell

        cell.type   = self.bonusResult[index].type
        cell.id     = self.bonusResult[index].id
        cell.value  = self.bonusResult[index].value
        cell.flag   = self.bonusResult[index].flag
        
        cell.winnumLabel:setString(tostring(cell.value*self.basebet))
        
        index = index + 1

    end

end

function BonusJourneyScene:registerEvent()
    -- go btn event

    local goBtn = core.displayEX.newButton(self.goBtn)

    local onGoBtnTogle = function()

        if self.ptsIdx > 1 then
            local button =  self["spot"..tostring(self.ptsIdx-1)]
            self:runAnimationByName(button, "idle")
        end

        goBtn:setButtonEnabled(false)

        for idx = 1, 6 do
            self["wheel"..tostring(idx)]:setVisible(false)
        end

        local array = {}
        local startIdx = self.stepIdx+1

        local resetWheel = function()
            
            if startIdx > 6 then
                startIdx = 1
            end
            
            self["wheel"..tostring(startIdx)]:setVisible(true)
            if startIdx == 1 then
                self["wheel"..tostring(6)]:setVisible(false)
            else
                self["wheel"..tostring(startIdx-1)]:setVisible(false)
            end
            
            startIdx = startIdx + 1

        end
        
        local backscene = function()
            local button =  self["spot"..tostring(self.ptsIdx-1)]
            self.totalMoney = button.value
            table.insert(self.selectBox, {type=button.type,id=button.id,value=button.value,flag=button.flag})

            self.bonusGameSet:setUsedItems(self.initData.rewardItems)
            local wincoin = data.slots.MachineApi.calculatBoxes(self.bonusGameSet, self.selectBox)
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
        

        local showResult = function()
            local button =  self["spot"..tostring(self.ptsIdx-1)]

            local wstop = self["stop_w_"..tostring(self.stepIdx)]
            wstop:setVisible(true)
            self["wheel"..tostring(self.stepIdx)]:setVisible(false)
            self.stopValue[self.stepIdx] = 0
            self["wheel"..tostring(self.stepIdx)] = self["stop_"..tostring(self.stepIdx)]

            self:runAnimationByName(button, "spot_show")
            
            local button =  self["spot"..tostring(self.ptsIdx-1)]

            if self.ptsIdx > self.ptsnum then
                backscene()
            end

            goBtn:setButtonEnabled(true)

        end

        local endWheel = function()
            local step = self.stepValue[self.stepIdx]
            local movearray = {}

            if self.stopValue[self.stepIdx] == 0 then
                backscene()
            else
                for idx = 1, step do
                    if self.ptsIdx <= self.ptsnum then
                        local pt1 = self["pt"..tostring(self.ptsIdx)]
                        local pt2
                        if self.ptsIdx == 1 then
                            pt2 = self.actorSprite
                        else
                            pt2 = self["pt"..tostring(self.ptsIdx-1)]
                        end

                        local endPt = cc.p(pt1:getPosition())
                        local startPt = cc.p(pt2:getPosition())

                        local setAngel=function()
                            self.actorSprite:setRotation( 360-180 * cc.pGetAngle(startPt, endPt)/3.1415 )
                        end

                        movearray[#movearray+1] = cc.CallFunc:create(setAngel)

                        local dist = cc.pGetDistance(endPt, startPt)
                        local time = dist / self.speed
                        
                        local distpt = cc.p(endPt.x - startPt.x,endPt.y - startPt.y)

                        movearray[#movearray+1] = cc.MoveTo:create(time, endPt)
                    end

                    self.ptsIdx = self.ptsIdx + 1
                end
                
                if self.ptsIdx > self.ptsnum then self.ptsIdx = self.ptsnum + 1 end
                
                movearray[#movearray+1] = cc.CallFunc:create(showResult)

                local sq = transition.sequence(movearray)
                self.actorSprite:runAction(sq)
            end
        end

        local num = math.random(20)
        
        if num < 6 then
            num = num + 6
        end
        
        self.stepIdx = (num + self.stepIdx )%6
        if self.stepIdx == 0 then self.stepIdx = 6 end

        for idx = 1, num do
            array[#array+1] = cc.CallFunc:create(resetWheel)
            local delay = cc.DelayTime:create(0.1)
            array[#array+1] = delay
        end

        array[#array+1] = cc.CallFunc:create(endWheel)

        local sqe = transition.sequence(array)
        self:runAction(sqe)

    end

    goBtn:onButtonClicked(onGoBtnTogle)

end

function BonusJourneyScene:onEnter()
    -- audio.playMusic( self.dict.cell.bg_music, true)
    -- print("onEnter:", self.dict.cell.bg_music)
end

function BonusJourneyScene:onExit()
    -- audio.stopMusic(true)
    -- audio.unloadSound(self.dict.cell.bg_music)
end

function BonusJourneyScene:runAnimationByName(target, name)
    if target == nil then
        return false
    end
    if target.animationManager:getRunningSequenceName() == name then
        return false
    end
    target.animationManager:runAnimationsForSequenceNamed(name)
    if target.animationManager:getRootNode():getTag() == 10011 then
        return false
    end

    return true
end


return BonusJourneyScene
