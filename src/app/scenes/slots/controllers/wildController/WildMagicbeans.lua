
local WildMagicbeans = class("WildMagicbeans")
local wildMusic = 'slots/slots_egypt/audio/wild_show_egypt.mp3'

--------------------------------------
-- Construct
--------------------------------------
function WildMagicbeans:ctor( controller )

    local model = controller.model

    self.model = model
    self.ctl = controller

    self.actionNode = display.newNode()
    controller:addChild(self.actionNode)
    
    self.OR = model:getOR()
    self.OV = model:getOV()

    self.macId = model:getMachineId()
    self.cols = (model:getMatrixConf()).cols
    self.rows = (model:getMatrixConf()).rows

end

----------------------------------------------
-- initWildSymbol
----------------------------------------------
function WildMagicbeans:initWildSymbol( holdArray )

    local col, row
    local lastRtSpArray = self.model:getLastRtSpArray()
    local onHoldWildArray = self.model:getOnHoldWildArray()
    local winSymbolsArray = self.model:getWinSymbolsArray()

    for k, matSy in pairs(holdArray) do
        col = matSy:getX() + 1
        row = matSy:getY() + 1
        symbol = lastRtSpArray[col][row]
        symbol:setHoldLabel('')  

        if symbol.wildTextNode then
            symbol.wildTextNode:removeAllChildren()
        end

        if symbol.spNode2 then
            symbol.spNode2:setVisible(true)  
        end 
                    
    end

    for k, matSy in pairs(onHoldWildArray) do
        col = matSy:getX() + 1
        row = matSy:getY() + 1
        winSymbolsArray[col][row] = matSy.symbolObj
    end

end

----------------------------------------------
-- playWild
----------------------------------------------
function WildMagicbeans:playWild( holdWildArray )
    
    local runTime = 0
    local isNewHold, matHoldSy

    for j=1, #holdWildArray do

        matHoldSy = holdWildArray[j]
        isNewHold = self:dealHoldWild(matHoldSy)
        
        if isNewHold then
            runTime = self:addHoldWild(matHoldSy)
        end

    end

    return runTime

end

-------------------------------------------
-- addHoldWild
-------------------------------------------
function WildMagicbeans:addHoldWild( matSy )

    local runTime = 0
    local holdCount = matSy:getStayRounds()

    local onHoldWildArray = self.model:getOnHoldWildArray()
    local winSymbolsArray = self.model:getWinSymbolsArray()

    local symbol = SymbolMgr.create(
        matSy:getSymbolId(),
        self.OR.x + matSy:getX()* self.OV.x,
        self.OR.y + matSy:getY()* self.OV.y
    )

    symbol.isHold = true
    matSy.symbolObj = symbol
    symbol:setHoldLabel('')
    symbol.wildTextNode:removeAllChildren()
    symbol:attachTo(self.ctl.machineView:getAnimtionsLayer())
    table.insert(onHoldWildArray, matSy)

    local col = matSy:getX() + 1
    local row = matSy:getY() + 1

    winSymbolsArray[col][row] = symbol

    if self.model:isFreeSpin() then

        local wildtext = display.newSprite("#wildtext_magicbeans.png")
        local size = wildtext:getContentSize()

        wildtext:setPosition(size.width/2, size.height/2)
        symbol.wildTextNode:removeAllChildren()
        symbol.wildTextNode:addChild(wildtext)
        symbol.spNode2:setVisible(false)
        symbol:runWinAnimation(DICT_MAC_RES[tostring(self.macId)].win_animation) 
        
        return runTime

    end

    local showNum = function(num)
        symbol:setHoldLabel(num)
        symbol:runAnimationByName('number')
    end 

    symbol.spNode2:setVisible(false)
    if not symbol.expProgress then
        
        local expX,expY = symbol.spNode2:getPosition()
        local parent = symbol.spNode2:getParent()
    
        local zoder = symbol.spNodeExp:getGlobalZOrder()
        symbol.spNodeExp:removeFromParent(false)
        symbol.expProgress = cc.ProgressTimer:create(symbol.spNodeExp)
        symbol.expProgress:setType(cc.PROGRESS_TIMER_TYPE_BAR)
        symbol.expProgress:setMidpoint(cc.p(0, 1))
        symbol.expProgress:setBarChangeRate(cc.p(0, 1))
        symbol.expProgress:setPosition(cc.p(expX, expY))

        parent:addChild(symbol.expProgress, zoder)

    end

    local expRunTime = 1.3
    local arrayExp = {}
    local fromTo = cc.ProgressFromTo:create(expRunTime, 100, 0)
    arrayExp[#arrayExp+1] = fromTo
    
    local seq = transition.sequence(arrayExp) 
    symbol.expProgress:runAction(seq)

    local numAnimationTime = 20 / 30
    local array = {}

    self.ctl:runFunWithDelay(self.actionNode, function() 
        audio.playSound(wildMusic) end, expRunTime/2)

    array[#array+1] = cc.DelayTime:create(expRunTime)

    for i=1,holdCount do

        runTime = runTime + numAnimationTime
        array[#array+1] = cc.CallFunc:create(self.ctl:callbackWithArgs(showNum, i))
        array[#array+1] = cc.DelayTime:create(numAnimationTime)

    end

    array[#array+1] = cc.CallFunc:create(function()
        local wildtext = display.newSprite("#wildtext_magicbeans.png")
        local size = wildtext:getContentSize()
        wildtext:setPosition(size.width/2, size.height/2)
        symbol.wildTextNode:removeAllChildren()
        symbol.wildTextNode:addChild(wildtext) 
        symbol:runAnimationByName('appear') end)

    self.actionNode:runAction(transition.sequence(array))

    return runTime + expRunTime
     
end

--------------------------------------------
-- dealHoldWild
--------------------------------------------
function WildMagicbeans:dealHoldWild( matHoldSy )
        
    local ctl = self.ctl
    local holdCount, matSy
    local onHoldWildArray = self.model:getOnHoldWildArray()

    local isNewHold = true

    for i = #onHoldWildArray, 1, -1 do

        matSy = onHoldWildArray[i]

        -- print("matSy:", matSy:toString())
        -- print("matHoldSy:", matHoldSy:toString())

        if ctl:isPosEqual(matHoldSy, matSy) then

            isNewHold = false

            if self.model:isFreeSpin() then
                return isNewHold
            end

            holdCount = matHoldSy:getStayRounds()
            matSy:setStayRounds(holdCount)

            print("holdCount:", holdCount)

            if holdCount <= 0 then
                self:setHoldSyToColLayer(matSy)
                table.remove(onHoldWildArray, i)
            else
                matSy.symbolObj:setHoldLabel(holdCount)
            end

        end

    end

    -- print("isNewHold:", isNewHold)

    return isNewHold

end

---------------------------------------
-- setHoldWildsToZero
---------------------------------------
function WildMagicbeans:setHoldWildsToZero()

    local onHoldWildArray = self.model:getOnHoldWildArray()

    for k,matSy in pairs(onHoldWildArray) do
        self:setHoldSyToColLayer(matSy)
    end

    self.model:setOnHoldWildArray({})

end

------------------------------------------------
-- setHoldSyToColLayer
------------------------------------------------
function WildMagicbeans:setHoldSyToColLayer( matSy )

    -- print("setHoldSyToColLayer:", matSy:toString())

    local col = matSy:getX() + 1
    local row = matSy:getY() + 1

    local onShowSpArray = self.model:getOnShowSpArray()
    local colLayerArray = self.model:getColLayerArray()
    local lastRtSpArray = self.model:getLastRtSpArray()
    local winSymbolsArray = self.model:getWinSymbolsArray()
                                                                    
    local tmpSy = lastRtSpArray[col][row]
    local symbol = SymbolMgr.create(matSy:getSymbolId(), 
            tmpSy:getPositionX(), tmpSy:getPositionY())

    symbol:setHoldLabel('')

    local sp = lastRtSpArray[col][row]

    lastRtSpArray[col][row] = symbol
    winSymbolsArray[col][row] = symbol

    for row_=1, #onShowSpArray[col] do
        if onShowSpArray[col][row_] == sp then
            onShowSpArray[col][row_] = symbol
            break
        end
    end

    symbol:attachTo(colLayerArray[col])

    symbol.isHold = false
    tmpSy.isHold = false

    matSy.symbolObj.spNode2:setVisible(true)
    matSy.symbolObj.wildTextNode:removeAllChildren()
    matSy.symbolObj:removeFromParent(false)

    symbol.spNode2:setVisible(false)

    local wildtext = display.newSprite("#wildtext_magicbeans.png")
    local size = wildtext:getContentSize()
    wildtext:setPosition(size.width/2, size.height/2)
    symbol.wildTextNode:removeAllChildren()
    symbol.wildTextNode:addChild(wildtext)

    symbol.isLastRt = true
    matSy.symbolObj = symbol
    tmpSy:removeFromParent(false)

end

-----------------------------------------------------
-- prepareInitWildArray 
-----------------------------------------------------
function WildMagicbeans:prepareInitWildArray( holdArray )

    local stayRounds,symbol
    local lastRtSpArray = self.model:getLastRtSpArray()
    local onHoldWildArray = self.model:getOnHoldWildArray()

    for k,sy in pairs(holdArray) do

        stayRounds = sy:getStayRounds()
        
        if stayRounds > 0 then

            symbol = SymbolMgr.create(
                sy:getSymbolId(),
                self.OR.x + sy:getX()* self.OV.x,
                self.OR.y + sy:getY()* self.OV.y
            )

            sy.symbolObj = symbol
            symbol:setHoldLabel(stayRounds)
            symbol:attachTo(self.ctl.machineView:getSyLayer())
            table.insert(onHoldWildArray, sy)
        
        else
            symbol = lastRtSpArray[sy:getX()+1][sy:getY()+1]
            symbol:setHoldLabel('')
        end

        symbol.spNode2:setVisible(false)

        local wildtext = display.newSprite("#wildtext_magicbeans.png")
        local size = wildtext:getContentSize()
        wildtext:setPosition(size.width/2, size.height/2)
        symbol.wildTextNode:removeAllChildren()
        symbol.wildTextNode:addChild(wildtext)

        symbol.isHold = true
        
    end

end

return WildMagicbeans
