-----------------------------------------------------------
-- SlotsNormalController 
-----------------------------------------------------------
local ModelClass = require("app.scenes.slots.models.SlotsNormalModel")
local BaseController = require('app.scenes.slots.controllers.SlotsControllerBase') 
local WildManager = require("app.scenes.slots.controllers.wildController.WildManager")
local SlotsNormalController = class("SlotsNormalController", BaseController)

local SCN = SlotsNormalController

-----------------------------------------------------------
-- Construct 
-----------------------------------------------------------
function SCN:ctor( initData, homeinfo )

    self.model = ModelClass.new(initData)
    self.super.ctor(self, initData, homeinfo)

    self:init()
    self.wildManager = WildManager.new(self)
    self.hasSerialsy = self.wildManager:hasSerialLogic(initData.machineId)
    self.super.doActionAfterInit(self)

end

-----------------------------------------------------------
-- Init 
-----------------------------------------------------------
function SCN:init()

    self:initModel()
    self:initViews()
    self:initSymbols()
    
end

-----------------------------------------------------------
-- InitModel 
-----------------------------------------------------------
function SCN:initModel()

    local origin = {}
    local originVector = {}

    local cols = (self.model:getMatrixConf()).cols
    local rows = (self.model:getMatrixConf()).rows

    -- 图标层
    local syLw = self.machineView:getSymbolLayerWidth()
    local syLh = self.machineView:getSymbolLayerHeight()

    -- 余、商
    local quotient_x, decimal_x = math.modf(syLw / cols)
    local quotient_y, decimal_y = math.modf(syLh / rows)
    
    -- 余宽、余高
    local remainderWidth = decimal_x * cols 
    local remainderHeight = decimal_y * rows
 
    -- 单位向量
    originVector.x = (syLw - remainderWidth)/ cols
    originVector.y = (syLh - remainderHeight)/ rows

    -- 原点坐标
    origin.x = remainderWidth / 2 + originVector.x / 2 
    origin.y = remainderHeight / 2 + originVector.y / 2 

    self.model:setOrigin(origin.x, origin.y)
    self.model:setOriginVector(originVector.x, originVector.y)

    self.model:setMachineType(self.RUND_TYPE.NORMAL)

end

-----------------------------------------------------------
-- InitView 
-----------------------------------------------------------
function SCN:initViews()
    self:initColLayer()
end

-----------------------------------------------------------
-- InitSymbols 
-----------------------------------------------------------
function SCN:initSymbols()

    local initArray = {}
    local roundResult = self.model:getRoundResult()

    if table.nums(roundResult) ~= 0 then
        self:prepareInitArray(initArray)
    end

    self:initOnShowSymbols(initArray)

end

-----------------------------------------------------------
-- PrepareInitArray  
-----------------------------------------------------------
function SCN:prepareInitArray( initArray )

    local symIds, pos = {}, {}
    local symbol, symId, reelId

    local OR = self.model:getOR()
    local OV = self.model:getOV()

    local cols = (self.model:getMatrixConf()).cols
    local rows = (self.model:getMatrixConf()).rows

    local roundResult = self.model:getRoundResult()
    local stopMatrixs = roundResult:getStopMatrix()

    local colLayerArray = self.model:getColLayerArray()
    local lastRtSpArray = self.model:getLastRtSpArray()
    local winSymbolsArray = self.model:getWinSymbolsArray()

    for col=1, cols do
        initArray[col] = {}
        lastRtSpArray[col] = {}
        winSymbolsArray[col] = {}
        pos.x = colLayerArray[col]:getContentSize().width / 2
                
        for row=1, rows do
            
            symId = stopMatrixs[col][row]:getSymbolId()
            pos.y = OR.y + (row -1) * OV.y
            symbol = SymbolMgr.create( symId, pos.x, pos.y )
            symbol:attachTo( colLayerArray[col] )

            symbol.isLastRt = true
            initArray[col][row] = symbol
            lastRtSpArray[col][row] = symbol
            winSymbolsArray[col][row] = symbol
            
        end

        reelId = self.model:getReels()[col]
        symIds = DICT_REELS[tostring(reelId)].symbol_ids

        symId  = symIds[math.random(#symIds)]
        pos.y  = OR.y + rows * OV.y
        symbol = SymbolMgr.create( symId, pos.x, pos.y )

        symbol.isLastRt = true
        symbol:attachTo( colLayerArray[col] )
        initArray[col][#initArray[col] + 1] = symbol
        lastRtSpArray[col][#lastRtSpArray[col] + 1] = symbol

    end

    self:initWild(roundResult, winSymbolsArray)

end

-----------------------------------------------------------
-- initWild  
-----------------------------------------------------------
function SCN:initWild(roundResult, winSymbolsArray)

    local logicId
    local holdArray = roundResult:getHoldWilds()
    local serialWildArray = roundResult:getSerialWilds()

    -- for wildhold and wild step
    if table.nums(holdArray) > 0 then
        
        symId = holdArray[1]:getSymbolId()
        logicId = DICT_WILD_REEL[tostring(symId)].logic_id
        self.wildManager:prepareInitWildArray(logicId, holdArray)

    -- for wild serial
    elseif table.nums(serialWildArray) > 0 then

        symId = serialWildArray[1]:getMiddleSymbol():getSymbolId()
        logicId = DICT_WILD_REEL[tostring(symId)].logic_id
        self.wildManager:prepareInitWildArray(logicId, serialWildArray)

    end 

    local col, row
    local onHoldWildArray = self.model:getOnHoldWildArray()
    for k,symbol in pairs(onHoldWildArray) do
        col = symbol:getX() + 1
        row = symbol:getY() + 1
        winSymbolsArray[col][row] = symbol.symbolObj
    end

end

-----------------------------------------------------------
-- initOnShowSymbols 
-----------------------------------------------------------
function SCN:initOnShowSymbols( initArray )

    local symbol
    local cols = (self.model:getMatrixConf()).cols
    local rows = (self.model:getMatrixConf()).rows

    local colLayerArray = self.model:getColLayerArray()
    local onShowSpArray = self.model:getOnShowSpArray()  

    if #initArray > 0 then 

        for col=1, cols do
            for row=1, #initArray[col] do
                symbol = initArray[col][row]
                onShowSpArray[col][row] = symbol
            end
        end

    end

    local pos = {}
    local reelId, maxRow
    local symId, symIds, sybIdx

    local OR = self.model:getOR()
    local OV = self.model:getOV()

    -- local speedAfterCol 

    -- if #initArray > 0 then
    --     speedAfterCol = self.model:getRoundResult():getSpeedUpReelIdxs()[1]
    -- end

    for col=1, cols do

        sybIdx = 0
        reelId = self.model:getReels()[col]
        symIds = DICT_REELS[tostring(reelId)].symbol_ids
        
        if #initArray > 0 then
            local lastIndex = #initArray[col]
            sybIdx = initArray[col][lastIndex]:getReelIndex()
            sybIdx = sybIdx ~= nil and sybIdx or 0
        end
        
        maxRow = (5-2+col) * rows + 1
        pos.x  = colLayerArray[col]:getContentSize().width / 2

        -- if speedAfterCol and col > speedAfterCol - 1 then
        --     maxRow = maxRow * 4
        -- end

        for row = #onShowSpArray[col] +1, maxRow do
            sybIdx = self:getNextSyIdx(symIds, sybIdx)
            symId  = symIds[sybIdx]
            pos.y  = OR.y + (row -1) * OV.y
            symbol = SymbolMgr.newSprite(symId, pos.x, pos.y)
            symbol:setReelIndex(sybIdx)
            onShowSpArray[col][row] = symbol
            symbol:attachTo(colLayerArray[col])
        end

    end

end

-----------------------------------------------------------
-- InitColLayer
-----------------------------------------------------------
function SCN:initColLayer()

    local OR = self.model:getOR()
    local OV = self.model:getOV()

    local colLayer, colLayer2, posX
    local sz = cc.size(10, 1600)

    local matrixConf    = self.model:getMatrixConf()
    local speedArray    = self.model:getSpinSpeedArray()
    local colLayerArray = self.model:getColLayerArray()

    for col=1, matrixConf.cols do
        
        speedArray[col] = {}
        speedArray[col].spinSpeed = 2300

        colLayer = cc.Layer:create()
        posX = OR.x + (col-1) * OV.x - sz.width/2
        colLayer:setPosition(posX, 0)
        colLayer:setContentSize(sz)
        colLayerArray[col] = colLayer
        self.machineView:addColLayer(col, colLayer)

    end
    
end

-----------------------------------------------------------
-- onStepSpin
-----------------------------------------------------------
function  SCN:onStepSpin()

    local matSy
    local wildStepArray = self.model:getWildStepArray()

    for i = #wildStepArray, 1, -1 do

        matSy = wildStepArray[i]
        if matSy:getX() <= -1 then
            table.remove(wildStepArray, i)
        end

    end

    local step = #wildStepArray

    if step >= 1 then
        self:onAutoSpin()
    else
        self:changeSpinBtn(self.BTN_STATE.NORMAL)
        self:spinCallBack()
    end


end

-----------------------------------------------------------
-- prepareSpin 
-----------------------------------------------------------
function SCN:prepareSpin()

    local OV = self.model:getOV()

    local cols = (self.model:getMatrixConf()).cols
    local rows = (self.model:getMatrixConf()).rows

    local lastRtSpArray = self.model:getLastRtSpArray()
    local colLayerArray = self.model:getColLayerArray()
    local onShowSpArray = self.model:getOnShowSpArray()

    self:buildRoundResult(self.RUND_TYPE.NORMAL)
    
    if #lastRtSpArray > 0 then
        self:cleanLastSpinData()
        self:initOnShowSymbols(lastRtSpArray)
    end

    -- self:buildRoundResult(self.RUND_TYPE.NORMAL)

    local roundResult = self.model:getRoundResult()
    local ttcoin = self.userModel:getCoins() - roundResult:getCostCoins()

    self.userModel:setCoins(ttcoin)
    self.controlbarView:setTTCoins(ttcoin)

    --save PiggyBank
    self:onSavePiggyBank()

    self:onSaveHandleExpGameSet()

    local exp  = roundResult:getRewardExp()

    if exp > 0 then
        self:updateExp(exp)
    end

    self:insertResultSymbol()

    local layer
    local rowCount, movePosY, moveDisY
    
    for col=1, cols do
        layer = colLayerArray[col]

        rowCount = #(onShowSpArray[col])
        movePosY = rowCount - rows
        moveDisY = (movePosY - 1) * OV.y 
        movePosY = layer:getPositionY() - moveDisY
        layer.moveDisY = moveDisY
        layer.movePosY = movePosY
    end

end

-----------------------------------------------------------
-- insertResultSymbol 
-----------------------------------------------------------
function SCN:insertResultSymbol()

    self:insertSpeedUpSymbol()

    local OV = self.model:getOV()
    local OR = self.model:getOR()

    local cols = (self.model:getMatrixConf()).cols
    local rows = (self.model:getMatrixConf()).rows

    local lastRtSpArray = self.model:getLastRtSpArray()
    local colLayerArray = self.model:getColLayerArray()
    local onShowSpArray = self.model:getOnShowSpArray()
    local winSymbolsArray = self.model:getWinSymbolsArray()

    local roundResult = self.model:getRoundResult()

    local symbol, symId, symIds
    
    local pos, reelId, topIndex = {}, nil, nil
    local reelStopIdxs = roundResult:getReelStopIdxs()

    for col = 1, cols do
        
        lastRtSpArray[col] = {}
        winSymbolsArray[col] = {}

        reelId = self.model:getReels()[col]
        symIds = DICT_REELS[tostring(reelId)].symbol_ids
        pos.x  = colLayerArray[col]:getContentSize().width / 2

        --------=======
        if self.hasSerialsy then

            local colLeng = #(onShowSpArray[col])
            local reelIdx = self:getPreSyIdx(symIds, reelStopIdxs[col])

            symId = symIds[reelIdx]

            local rmSymbol1 = onShowSpArray[col][colLeng]
            local rmSymbol2 = onShowSpArray[col][colLeng - 1]

            rmSymbol1:removeFromParent(false)
            rmSymbol2:removeFromParent(false)


            local newSymbol = SymbolMgr.create(symId , pos.x, (colLeng - 1 ) * OV.y + OR.y)

            newSymbol:attachTo(colLayerArray[col])
            onShowSpArray[col][colLeng] = newSymbol


            reelIdx   = self:getPreSyIdx(symIds, reelIdx)
            symId = symIds[reelIdx]


            local newSymbol2 = SymbolMgr.create(symId , pos.x, (colLeng - 2) * OV.y + OR.y)

            newSymbol2:attachTo(colLayerArray[col])
            onShowSpArray[col][colLeng - 1] = newSymbol2

        end
        ---------

        topIndex = #(onShowSpArray[col]) + 1

        for row = 1, rows do

            symId  = symIds[reelStopIdxs[col]]
            pos.y  = (topIndex - 1) * OV.y + OR.y

            symbol = SymbolMgr.create( symId, pos.x, pos.y )

            symbol.isLastRt = true
            lastRtSpArray[col][row] = symbol
            winSymbolsArray[col][row] = symbol
            onShowSpArray[col][topIndex] = symbol

            symbol:setReelIndex(reelStopIdxs[col])
            symbol:attachTo(colLayerArray[col])
            reelStopIdxs[col] = self:getNextSyIdx( symIds, reelStopIdxs[col] )

            topIndex = topIndex + 1

        end

        symId  = symIds[reelStopIdxs[col]]
        pos.y  =  (topIndex - 1) * OV.y + OR.y
        symbol = SymbolMgr.create( symId, pos.x, pos.y )
        symbol:setReelIndex(reelStopIdxs[col])

        symbol.isLastRt = true
        onShowSpArray[col][topIndex] = symbol
        lastRtSpArray[col][rows + 1] = symbol
        symbol:attachTo(colLayerArray[col])

    end


    -- Init wild symbol 
    local holdArray = roundResult:getHoldWilds()
    if #holdArray >= 1 then
        
        symId = holdArray[1]:getSymbolId()
        local logicId = DICT_WILD_REEL[tostring(symId)].logic_id
        self.wildManager:initWildSymbol(logicId, holdArray)

    end 

end

-----------------------------------------------------------
-- insertSpeedUpSymbol 
-----------------------------------------------------------
function SCN:insertSpeedUpSymbol()

    local speedAfterCol = self.model:getRoundResult():getSpeedUpReelIdxs()[1]

    if not speedAfterCol then
        return
    end

    local symbol
    local cols = (self.model:getMatrixConf()).cols
    local rows = (self.model:getMatrixConf()).rows

    local colLayerArray = self.model:getColLayerArray()
    local onShowSpArray = self.model:getOnShowSpArray()  

    local pos = {}
    local reelId, maxRow
    local symId, symIds, sybIdx

    local OR = self.model:getOR()
    local OV = self.model:getOV()


    for col=1, cols do

        sybIdx = 0
        reelId = self.model:getReels()[col]
        symIds = DICT_REELS[tostring(reelId)].symbol_ids
        

        local lastIndex = #onShowSpArray[col]
        sybIdx = onShowSpArray[col][lastIndex]:getReelIndex()
        sybIdx = sybIdx ~= nil and sybIdx or 0

        pos.x  = colLayerArray[col]:getContentSize().width / 2


        local maxRow = (5-2+col) * rows + 1
        if col > speedAfterCol - 1 then
            maxRow = maxRow * 4
            for row = #onShowSpArray[col] +1, maxRow do
                sybIdx = self:getNextSyIdx(symIds, sybIdx)
                symId  = symIds[sybIdx]
                pos.y  = OR.y + (row -1) * OV.y
                symbol = SymbolMgr.newSprite(symId, pos.x, pos.y)
                symbol:setReelIndex(sybIdx)
                onShowSpArray[col][row] = symbol
                symbol:attachTo(colLayerArray[col])
            end
        end
    end


end

-----------------------------------------------------------
-- CleanLastSpinData
-----------------------------------------------------------
function SCN:cleanLastSpinData()

    local sp, spPosY, rmRowIndex
    local OV = self.model:getOV()
    local OR = self.model:getOR()

    local cols = (self.model:getMatrixConf()).cols
    local rows = (self.model:getMatrixConf()).rows

    local lastRtSpArray = self.model:getLastRtSpArray()
    local onShowSpArray = self.model:getOnShowSpArray()

    for col = 1, cols do
        rmRowIndex = #onShowSpArray[col]
        for row = 1, rmRowIndex do
            sp = onShowSpArray[col][row]
            if sp ~= -1 and sp.isLastRt ~= true then 
                sp:removeFromParent( false )
            end
        end
    end

    self:reSetColLayer()

    local posX, size
    for col = 1, cols do

        onShowSpArray[col] = {}

        for row = 1, rows + 1 do
            sp = lastRtSpArray[col][row]
            sp.isLastRt = false
            spPosY = OR.y + (row -1) * OV.y
            sp:setPositionY(spPosY)
        end
        
    end

end

-----------------------------------------------------------
-- reSetColLayer
-----------------------------------------------------------
function SCN:reSetColLayer()

    local OV = self.model:getOV()
    local OR = self.model:getOR()
    local cols = (self.model:getMatrixConf()).cols

    local colLayerArray = self.model:getColLayerArray()

    local posX, size
    for col = 1, cols do
        size = colLayerArray[col]:getContentSize()
        posX = OR.x + (col -1) * OV.x - size.width / 2
        colLayerArray[col]:setPosition(posX, 0)  
    end

end

-----------------------------------------------------------
-- PlaySpinAnimation
-----------------------------------------------------------
function SCN:playSpinAnimation()

    local posY = 0
    local spinSpeed = 0
    local spinTime ,maxTime = 0, 0

    local layer, playSound
    local cols = (self.model:getMatrixConf()).cols
    local colLayerArray  = self.model:getColLayerArray()
    local spinSpeedArray = self.model:getSpinSpeedArray()

    -- speedSpinTo( node, posY , norTime, ttTime , playSound )

    local norTime
    local speedAfterCol = self.model:getRoundResult():getSpeedUpReelIdxs()[1]

    if speedAfterCol then
        speedAfterCol = speedAfterCol -1
        norTime = colLayerArray[speedAfterCol].moveDisY / spinSpeedArray[speedAfterCol].spinSpeed
    end

    for col = 1, cols do
        layer = colLayerArray[col]
        spinSpeed = spinSpeedArray[col].spinSpeed
        spinTime  = layer.moveDisY / spinSpeed

        if col == cols then
            playSound = true
        end

        if speedAfterCol and col > speedAfterCol then 
            spinTime = 5 * ( 0.5 + col*0.1 ) --spinTime * 2
            self:speedSpinTo(layer, layer.movePosY , norTime,  spinTime , playSound)
        else
            self:spinTo(layer, layer.movePosY , spinTime, playSound)
        end

        if spinTime > maxTime then
            maxTime = spinTime
        end

    end
    
    return maxTime

end

-----------------------------------------------------------
-- onStopSpin
-----------------------------------------------------------
function SCN:onStopSpin()
    if self.model:getLastRtSpArray() == nil then
        print("onStopSpin is stop")
        return
    end
    local sp, spPosY, keyPosY
    local rowIndex, movePosY
    local spinTime, maxSpTime = 0, 0

    local OR = self.model:getOR()
    local OV = self.model:getOV()

    local matrixConf  = self.model:getMatrixConf()
    local speedArray  = self.model:getSpinSpeedArray()
    local colLayerArray = self.model:getColLayerArray()
    local lastRtSpArray = self.model:getLastRtSpArray()
    local onShowSpArray = self.model:getOnShowSpArray()  
    local spinSpeedArray = self.model:getSpinSpeedArray()

    self.keyPosY = OR.y + OV.y 

    print("self.soundSpeed:",  self.soundSpeed)

    if self.soundSpeed then audio.stopSound(self.soundSpeed) self.soundSpeed = nil end

    for col =1, matrixConf.cols do
        sp = lastRtSpArray[col][1]
        
        local hasMvDis = math.abs(colLayerArray[col]:getPositionY())

        spPosY = sp:getPositionY() - hasMvDis

        local cmPosY = self.keyPosY + 0

        if spPosY > cmPosY then 

            -- prepare to replace from rowIndex
            rowIndex = #(onShowSpArray[col]) - (matrixConf.rows) - 2

            while spPosY > cmPosY do
                rowIndex = rowIndex - 1
                sp = onShowSpArray[col][rowIndex]
                hasMvDis = math.abs(colLayerArray[col]:getPositionY())
                spPosY = sp:getPositionY() - hasMvDis
                keyPosY = sp:getPositionY()
                sp:removeFromParent(false)
                onShowSpArray[col][rowIndex] = -1
            end

            local tempIndex = #onShowSpArray[col] - matrixConf.rows - 2
            for row = 1, matrixConf.rows + 2 + 1 do

                sp = onShowSpArray[col][tempIndex]
                sp:setPositionY(keyPosY + (row -1) * OV.y)
                tempIndex = tempIndex + 1

            end

            local layer = colLayerArray[col]
            layer:stopAllActions()
            
            movePosY = spPosY - OR.y + 2*OV.y
            spinTime = movePosY / (spinSpeedArray[col].spinSpeed) + 0.2
            
            if maxSpTime < spinTime then
                maxSpTime = spinTime 
            end
            
            local playSound = (col == matrixConf.cols)

            self:spinTo(layer, (layer:getPositionY() - movePosY), spinTime, playSound)
        
        end

    end

    if maxSpTime > 0 then self.actionNode:stopAllActions() end

    return maxSpTime

end

-----------------------------------------------------------
-- showResult
-----------------------------------------------------------
function SCN:showResult(callback)

    print("onShowRst begin")
    print("callback--2:", callback)

    local BTNS  = self.BTN_STATE
    local winInterval, noWinInterval = 0,0

    local wildTime = self:playWildEff()

    if self.spinBtnState == BTNS.AUTOSPIN or 
        self.spinBtnState == BTNS.FREESPIN or
        self.spinBtnState == BTNS.STEPSPIN then

        winInterval = 1.2
        noWinInterval =  0.5
        
    end

    self:setState(self.STATE.ONSHOWRE)

    local actions = {}
    local rdResult = self.model:getRoundResult()

    local isWin = rdResult:getIsWin()

    if 1 ~= isWin then

        actions[#actions+1] = cc.DelayTime:create(noWinInterval+wildTime)
        actions[#actions+1] = cc.CallFunc:create(self:callbackWithArgs(
            self.setState, {self, self.STATE.SHOWRESOK}))

        actions[#actions+1] = cc.CallFunc:create(callback)
        actions[#actions+1] = cc.CallFunc:create(function()
            if self.model:getTTWinCoin() > 0 and 
                self.model:isFreeSpin() ~= true and
                self.model:hasPlayBouble() ~= true  and
                self.spinBtnState ~= BTNS.STEPSPIN then

                self.controlbarView:showDouble()
                    
            end
        end)  

        local sq = transition.sequence(actions)
        self.actionNode:runAction(sq)
        
        return
    end

    local settle = function()
        self:settleFreeSpinOrBonus(rdResult)
        if not self:isRoundPause(rdResult) then
            self:setState(self.STATE.SHOWRESOK)
            if rdResult:getRewardCoins() > 0 and 
                self.model:isFreeSpin() ~= true and
                self.model:hasPlayBouble() ~= true then
                self.controlbarView:showDouble()
            end
        end
    end
    
    local playEff = function()

        local dt = self:playEffect() + winInterval

        actions[#actions+1] = cc.DelayTime:create(dt)
        actions[#actions+1] = cc.CallFunc:create(settle)
        actions[#actions+1] = cc.CallFunc:create(callback)

        local sq = transition.sequence(actions)
        self.actionNode:runAction(sq)

    end

    self:performWithDelay(playEff, wildTime)

end

-----------------------------------------------------------
-- spinTo
-----------------------------------------------------------
function SCN:spinTo( node, posY , time , playSound )

    local posX = node:getPositionX()
    local actionUp = cc.JumpBy:create(0.2, cc.p(0,0), -20, 1)
    local actionMv = cc.MoveTo:create(time - 0.2, cc.p(posX, posY))

    local actions = {}

    actions[#actions+1] = actionMv
    actions[#actions+1] = actionUp

    if playSound == true then
        local sound = cc.CallFunc:create(function() self:PlayReelStopSound() end)
        actions[#actions+1] = sound
    end

    local sq = transition.sequence(actions)
    node:runAction(sq)

end

-----------------------------------------------------------
-- speedSpinTo
-----------------------------------------------------------
function SCN:speedSpinTo( node, posY , norTime, ttTime , playSpeedSound )

    print("playSpeedSound:", playSpeedSound)

    local spinSpeed = 2300
    local jumpBTime = 0.2
    local speedTime = ttTime - norTime - jumpBTime

    local posX = node:getPositionX()
    local actionUp = cc.JumpBy:create(jumpBTime, cc.p(0,0), -20, 1)
    local actionMv = cc.MoveTo:create(norTime , cc.p(posX, - spinSpeed * norTime))
    local actionMvSpeed = cc.MoveTo:create(speedTime, cc.p(posX, posY))
    
    local actions = {}

    self.soundSpeed = nil

    actions[#actions+1] = actionMv

    print("#actions:", #actions)

    -- if playSpeedSound == true then
    --     print("0000")
    --     actions[#actions+1] = cc.CallFunc:create(function()
    --         print("self.soundSpeed0:", self.soundSpeed)  
    --         -- self.soundSpeed = audio.playSound(RES_AUDIO.wheel_speed, false) 
    --         print("self.soundSpeed1:", self.soundSpeed) 
    --     end)
    --     print("#actions:", #actions)
    -- end

    if playSpeedSound == true then
        actions[#actions+1] = cc.CallFunc:create(function() 
            print("self.soundSpeed1:", self.soundSpeed)
            self.soundSpeed = audio.playSound(RES_AUDIO.wheel_speed, false) 
        end)
    end

    actions[#actions+1] = actionMvSpeed
    if playSpeedSound == true then
        actions[#actions+1] = cc.CallFunc:create(function() 
            print("self.soundSpeed2:", self.soundSpeed)
            audio.stopSound(self.soundSpeed) self.soundSpeed = nil 
        end)
    end

    actions[#actions+1] = actionUp
    actions[#actions+1] = cc.CallFunc:create(function() self:PlayReelStopSound() end)

    local sq = transition.sequence(actions)
    node:runAction(sq)

end


-----------------------------------------------------------
-- PlayReelStopSound
-----------------------------------------------------------
function SCN:PlayReelStopSound()
    audio.playSound("slots/slots_shared_audio/reel_stop.mp3", false)
end

-----------------------------------------------------------
-- getPreSyIdx
-----------------------------------------------------------
function SCN:getPreSyIdx( syArray, preSyId )
    local maxIndex = #(syArray)
    return preSyId <= 1 and maxIndex or (preSyId - 1)
end


-----------------------------------------------------------
-- RegisterUIEvent 
-----------------------------------------------------------
function SCN:registerUIEvent()
    self.super.registerUIEvent(self)
end


-----------------------------------------------------------
-- 
-----------------------------------------------------------
function SCN:onEnter()
    self.super.onEnter(self)
    self:registerUIEvent()
end

-----------------------------------------------------------
-- 
-----------------------------------------------------------
function SCN:onExit() 
    self.super.onExit(self)
    self.model = nil
    self.userModel = nil
    self.controlbarView = nil
    self.machineView = nil
    self.actionNode = nil
    self.lineView = nil

    collectgarbage("collect")
end

-----------------------------------------------------------
-- getWinSymbol
-----------------------------------------------------------
function SCN:getWinSymbol(col, row)
    local resoult
    local isStepSymbol = false
    local stepArray = self.model:getWildStepArray()

    for k, symbol in pairs(stepArray) do
        if symbol:getX() + 1 == col and  symbol:getY() + 1 == row then
            resoult = symbol.symbolObj
            isStepSymbol = true
            break
        end
    end

    if not resoult then
        local winSymbolsArray = self.model:getWinSymbolsArray()
        resoult = winSymbolsArray[col][row]
    end

    return resoult,isStepSymbol
end

return SlotsNormalController
