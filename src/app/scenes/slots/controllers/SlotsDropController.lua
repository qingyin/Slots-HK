-----------------------------------------------------------
-- SlotsDropController 
-----------------------------------------------------------
local ModelClass = require("app.scenes.slots.models.SlotsDropModel")
local BaseController = require('app.scenes.slots.controllers.SlotsControllerBase') 
local SlotsDropController = class("SlotsDropController", BaseController)

local SDC = SlotsDropController

-----------------------------------------------------------
-- Construct
-----------------------------------------------------------
function SDC:ctor( initData, homeinfo)

    self.model = ModelClass.new(initData)
    self.super.ctor(self, initData, homeinfo)

    self:init()
    self.super.doActionAfterInit(self)

end

-----------------------------------------------------------
-- Init 
-----------------------------------------------------------
function SDC:init()
    
    self:initModel()
    self:initViews()
    self:initSymbols()
    
end

-----------------------------------------------------------
-- initViews 
-----------------------------------------------------------
function SDC:initViews()
    self:setMultVisible(1)
    self.syLayer = self.machineView.symbolsColsLayer
end

-----------------------------------------------------------
-- InitModel 
-----------------------------------------------------------
function SDC:initModel()

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

    self.model:setMachineType(self.RUND_TYPE.DROP)

end

-----------------------------------------------------------
-- InitSymbols 
-----------------------------------------------------------
function SDC:initSymbols()

    local roundResult = self.model:getRoundResult()
    
    if table.nums(roundResult) ~= 0 then
        self:initByResult()
    else
        self:initOnShowSymbols()
    end

end

-----------------------------------------------------------
-- initByResult  
-----------------------------------------------------------
function SDC:initByResult()

    local OR = self.model:getOR()
    local OV = self.model:getOV()

    local cols = (self.model:getMatrixConf()).cols
    local rows = (self.model:getMatrixConf()).rows

    local roundResults = self.model:getRoundResult()
    local onShowSpArray = self.model:getOnShowSpArray() 

    local initRound = self.model:getInitRound()
    local roundResult = roundResults[initRound]

    local pos = {}
    local symbol, matSym  
    local stopMatrixs = roundResult:getStopMatrix()

    for col = 1, cols do
        onShowSpArray[col] = {}
        for row = 1, rows do

            matSym = stopMatrixs[col][row]
            symId  = matSym:getSymbolId()

            pos.x = OR.x + (col -1) * OV.x
            pos.y = OR.y + (row -1) * OV.y
            
            symbol = SymbolMgr.create(symId, pos.x, pos.y)

            symbol:attachTo(self.syLayer)
            symbol.syIndex = matSym.symbolIdx
            onShowSpArray[col][row] = symbol
            
        end
    end


end

-----------------------------------------------------------
-- initOnShowSymbols 
-----------------------------------------------------------
function SDC:initOnShowSymbols()

    local symbol, x, y
    local symId, reelId, symIds
    local OR = self.model:getOR()
    local OV = self.model:getOV()

    local cols = (self.model:getMatrixConf()).cols
    local rows = (self.model:getMatrixConf()).rows

    local onShowSpArray = self.model:getOnShowSpArray()  

    for col = 1, cols do

        onShowSpArray[col] = {}
        reelId = self.model:getReels()[col]
        symIds = DICT_REELS[tostring(reelId)].symbol_ids

        for row = 1, rows do

            symId = symIds[row]
            x = OR.x + (col -1) * OV.x
            y = OR.y + (row -1) * OV.y
                    
            symbol = SymbolMgr.create(symId, x, y)

            symbol:attachTo(self.syLayer)
            onShowSpArray[col][row] = symbol

        end
    end

end

-----------------------------------------------------------
-- PrepareSpin 
-----------------------------------------------------------
function SDC:prepareSpin()
    
    local reelId
    local symId, symIds, symbol, syIndex

    self:buildRoundResult(self.RUND_TYPE.DROP)

    local roundResults = self.model:getRoundResult()
    local ttcoin = self.userModel:getCoins() - roundResults[1]:getCostCoins()

    self.userModel:setCoins(ttcoin)
    self.controlbarView:setTTCoins(ttcoin)

    --save PiggyBank
    self:onSavePiggyBank()

    self:onSaveHandleExpGameSet()

    local exp  = roundResults[1]:getRewardExp()

    if exp > 0 then
        self:updateExp(exp)
    end

    local x,y = 0, self.syLayer:getPositionY() + 630 
    local reelStopIdxs = roundResults[1]:getReelStopIdxs()

    local OR = self.model:getOR()
    local OV = self.model:getOV()
    local cols = (self.model:getMatrixConf()).cols
    local rows = (self.model:getMatrixConf()).rows

    local onShowSpArray = self.model:getOnShowSpArray()

    for col = 1, cols do
        
        onShowSpArray[col] = {}

        reelId = self.model:getReels()[col]       
        symIds = DICT_REELS[tostring(reelId)].symbol_ids
        
        x = OR.x + (col -1) * OV.x

        for row = 1, rows do

            syIndex = reelStopIdxs[col]
       
            symId  = symIds[syIndex]
            symbol = SymbolMgr.create(symId, x, y)

            symbol.syIndex = syIndex
            symbol:attachTo(self.syLayer)

            onShowSpArray[col][row] = symbol
            reelStopIdxs[col] = self:getNextSyIdx(symIds, syIndex)

        end

    end

end

-----------------------------------------------------------
-- playSpinAnimation
-----------------------------------------------------------
function SDC:playSpinAnimation()
    
    local rtime = 0
    rtime = self:allColsFallDown()

    return rtime

end

-----------------------------------------------------------
-- onStopSpin
-----------------------------------------------------------
function SDC:onStopSpin()
    return 0
end

-----------------------------------------------------------
-- upExp
-----------------------------------------------------------
function SDC:upExp()

    local roundResults = self.model:getRoundResult()
    local exp  = roundResults[1]:getRewardExp()

    if exp > 0 then
        exp = exp + User.getProperty(User.KEY_EXP)
        User.setProperty(User.KEY_EXP, exp)
    end

end

-----------------------------------------------------------
-- Eliminate
-----------------------------------------------------------
function SDC:eliminate( roundResult )

    local row,col,maxRow 
    local syIndex, reelId, sp
    local symbol, symId, symIds
    
    local spArray = self.model:getOnShowSpArray()
    local allWinSymbols = roundResult:getAllWinSymbols()

    audio.playSound("slots/slots_shared_audio/bust.mp3", false)

    local OR = self.model:getOR()
    local OV = self.model:getOV()

    for k,syObj in pairs(allWinSymbols) do
        row = syObj:getY() + 1
        col = syObj:getX() + 1
        sp = spArray[col][row]
        maxRow = #(spArray[col])

        reelId = self.model:getReels()[col] 
        symIds = DICT_REELS[tostring(reelId)].symbol_ids

        syIndex = self:getNextSyIdx(symIds, 
            spArray[col][maxRow].syIndex)

        symId = symIds[syIndex]

        self:eliminateSprite(sp)
        spArray[col][row] = 0

        symbol = SymbolMgr.create(symId,
            OR.x + (col - 1) * OV.x, 
            self.syLayer:getPositionY() + 630
        )

        symbol.syIndex = syIndex
        spArray[col][maxRow + 1] = symbol
        symbol:attachTo(self.syLayer)

    end

end

-----------------------------------------------------------
-- Filling
-----------------------------------------------------------
function SDC:filling()
    
    local mvsp,index
    local pos = {x=0,y=0}
    local spArray = self.model:getOnShowSpArray()

    local OR = self.model:getOR()
    local OV = self.model:getOV()
    local cols = (self.model:getMatrixConf()).cols
    local rows = (self.model:getMatrixConf()).rows

    local function drop(col, row)
        local sp = spArray[col][row]
        if type(sp) ~= "userdata" 
            and sp == 0 then
            
            mvsp = 0
            index = row
                
            while type(mvsp) ~= "userdata" 
                and mvsp == 0 do
                index = index + 1
                mvsp = spArray[col][index]
            end

            pos.x = OR.x + (col -1)* OV.x
            pos.y = OR.y + (row -1)* OV.y
            self:symbolSpriteFallDown(mvsp, pos)
            spArray[col][row] = mvsp
            spArray[col][index] = 0
        end
    end
    
    for col=1, cols do
        for row=1, rows do   
            drop(col, row)
        end
    end

    for col=1, cols do
        for row = rows+1, #(spArray[col]) do
            spArray[col][row] = nil
        end
    end

end

-----------------------------------------------------------
-- onShowReFinish
-----------------------------------------------------------
function SDC:onShowReFinish(isPause)

    if isPause then
        self.model:setDoSpinCk(false) 
    end

    if self.model:getTTWinCoin() > 0 and 
        self.model:isFreeSpin() == false and
        self.model:hasPlayBouble() == false then
        self.controlbarView:showDouble()
    end

end

-----------------------------------------------------------
-- ShowResult
-----------------------------------------------------------
function SDC:showResult( callback ) 

    local isPause = false
    local spinRet = self.model:getRoundResult()

    local function onFinish()
        self:setMultVisible(1)
        self:onShowReFinish(isPause)
        pcall(callback)
    end

    local actions = {}
    local isWin = spinRet[1]:getIsWin()

    if spinRet[1]:getIsWin() ~= 1 then
        actions[#actions + 1] = cc.CallFunc:create(onFinish)
        local sq = transition.sequence(actions)
        self.actionNode:runAction(sq)
        return
    end

    local continue = false
    local round, count = 0, 0
    local initRound = self.model:getInitRound()

    for k,roundResult in pairs(spinRet) do
        continue = false
      
        if isPause or self.hasPlayBouble
            or roundResult:getIsWin() ~= 1 then 
            continue = true
        end

        if initRound > 0 and 
            count + 1 < initRound then
            count = count + 1
            round = count
            continue = true
        end

        if continue == false then
            round = round + 1
            self.model:setInitRound(round)
            
            -- -- for debug:
            -- if not self.model:isFreeSpin() then
            --     local redItems = roundResult:getRewardItems()
            --     -- redItems[ITEM_TYPE.BONUS_MULITIPLE] = 2
            --     redItems[ITEM_TYPE.FREESPIN_MULITIPLE] = 2
            --     roundResult:setRewardItems(redItems)
            -- end

            isPause = self:isRoundPause(roundResult)
            self:initREArray(round, roundResult, isPause, actions)
            actions[#actions + 1] = cc.DelayTime:create(1.5)
        end

    end

    actions[#actions + 1] = cc.CallFunc:create(onFinish)
    local sq = transition.sequence(actions)
    self.actionNode:runAction(sq)

end

-----------------------------------------------------------
-- InitREArray
-----------------------------------------------------------
function SDC:initREArray(round, rdResult, isPause, array)

    local effDelay = 0 

    local playEffect = function()
        self:playEffect(rdResult,round)
    end

    local settle = function()
        self:settleFreeSpinOrBonus(rdResult)
    end

    local rmEffect = function()

        local symbol
        local lp = rdResult:getLinePattern()

        self.lineView:hideAllLines()
        for lineNum,pattern in pairs(lp) do
            for k,sy in pairs ( pattern:getWinSymbols() ) do
                symbol = self.model:getOnShowSpArray()[sy:getX() + 1][sy:getY() + 1]
                symbol:runWinAnimation('idle')
            end
        end
    end

    local upData = function()
        self:upUserData(rdResult, round)
    end

    local eliminate = function()
        self:eliminate(rdResult)
    end

    local filling = function()
        self:filling()
    end

    local pEff_   = cc.CallFunc:create(playEffect)
    local settle_ = cc.CallFunc:create(settle)
    local rmEff_  = cc.CallFunc:create(rmEffect)
    local upData_ = cc.CallFunc:create(upData)
    local eliminate_ = cc.CallFunc:create(eliminate)
    local filling_  = cc.CallFunc:create(filling)
            
    local delay_ = cc.DelayTime:create(0.7)
            
    array[#array + 1] = pEff_
    array[#array + 1] = delay_
    array[#array + 1] = settle_

    if not isPause then

        if rdResult:getFiveWin() == 1 then
            array[#array + 1] = cc.DelayTime:create(3)
        end

        local winCoin = rdResult:getRewardCoins()
        if winCoin >= 10 * self.model:getTTbet() then
            array[#array + 1] = cc.DelayTime:create(4.5)
        elseif winCoin >= 5 * self.model:getTTbet() and
            winCoin < 10 * self.model:getTTbet() then
            array[#array + 1] = cc.DelayTime:create(3.5)
        else
        end

        array[#array + 1] = upData_
        array[#array + 1] = rmEff_
        array[#array + 1] = eliminate_
        array[#array + 1] = cc.DelayTime:create(0.5)
        array[#array + 1] = filling_
    
    else

        array[#array + 1] = upData_
        array[#array + 1] = rmEff_

    end

end

-----------------------------------------------------------
-- playEffect
-----------------------------------------------------------
function SDC:playEffect(rdResult, round)

    local lp = rdResult:getLinePattern()

    local reItems = 
        rdResult:getRewardItems()

    round = round + 1
    if round > 4 then
        round = 4
    end

    self:setMultVisible(round, self.mult)

    local symbol
    for lineNum,pattern in pairs(lp) do
        self.lineView:showLine(lineNum)
        self.lineView:blinkLineById(lineNum)
        for k,sy in pairs ( pattern:getWinSymbols() ) do
            symbol = self.model:getOnShowSpArray()[sy:getX()+1][sy:getY()+1]
            symbol:runWinAnimation(DICT_MAC_RES[tostring(self.machineId)].win_animation)
        end
    end

    if rdResult.hasSettled then
        return
    end

    local fiveWinTime = 0
    if rdResult:getFiveWin() == 1 then
        fiveWinTime = self:playFiveOfKind()
    end

    local playSetteEff = function(rdResult)
        self:playEffByWinCoins(rdResult, 0)
    end

    self:runFunWithDelay(self.actionNode, self:callbackWithArgs(
        playSetteEff, rdResult), fiveWinTime)

end



-----

-----------------------------------------------------------
-- UpUserData
-----------------------------------------------------------
function SDC:upUserData( rdResult, round )

    local rtime = 0

    if rdResult.hasUpUserData == true then
        
        -- local rewardCoin = rdResult:getRewardCoins()
        -- local winCoin = rewardCoin + self.model:getTTWinCoin()
        -- self.model:setTTWinCoin(winCoin)
        -- self.controlbarView:setWinCoins(winCoin)
        -- print("upUserData:", round, winCoin)

        return
    end

    self:updateCoins(rdResult)
    rdResult.hasUpUserData = true

    if rdResult:getRewardCoins() > 0  and round > 1 then
        
        -- local node = {}
        -- local numberLayer = CCBuilderReaderLoad(GAME_CCBI.winNumber, node)
        -- node.numLabel:setString('+'..rdResult:getRewardCoins())
        
        -- local pos = self.controlbarView.winCoinLabel:getParent():
        --     convertToWorldSpace(cc.p(self.controlbarView.winCoinLabel:getPosition()))

        -- numberLayer:setPosition(pos.x, pos.y)

        -- local function rm()
        --     numberLayer:removeFromParent()
        --     numberLayer = nil
        -- end

        -- self:addChild(numberLayer)
        -- self:runFunWithDelay(rm, 1)

    end

    -- if self.model:getTTWinCoin() > 0 then
    --     self:playEffByWinCoins(rdResult, 0)
    -- end

    return rtime

end

-----------------------------------------------------------
-- setMultVisible
-----------------------------------------------------------
function SDC:setMultVisible(pos, lastPos)

    if pos == self.mult then
        return
    end
    
    self.machineView:setMultVisible(pos, lastPos)

    self.mult = pos

end

-----------------------------------------------------------
-- SymbolSpriteFallDown
-----------------------------------------------------------
function SDC:symbolSpriteFallDown( sp, pos )

    local OV = self.model:getOV()
    local jumpY = 30 - (pos.y - OV.y) * 0.5

    jumpY = (jumpY >=0 or jumpY and 0)

    local actionMove = cc.MoveTo:create(0.4, cc.p(pos.x, pos.y))
    local actionUp = cc.JumpBy:create(0.4, cc.p(0,0), 30, 1)

    local actions = {}
    actions[#actions+1] = actionMove
    actions[#actions+1] = actionUp

    local sq = transition.sequence(actions)
    sp:runAction(sq)
    
end

-----------------------------------------------------------
-- EliminateSprite
-----------------------------------------------------------
function SDC:eliminateSprite( sp )

    local func = function()

        local eff = CCBuilderReaderLoad(DICT_MACHINE_EFF[
            tostring(self.machineId)].explosion, {})

        eff:setPosition(sp:getPositionX(), sp:getPositionY())
        self.machineView:addEff(eff)

        local effArray = self.model:getEffArray()
        table.insert(effArray, eff)
        sp:removeFromParent()
        
    end

    func()

end

-----------------------------------------------------------
-- OneColFallDown
-----------------------------------------------------------
function SDC:oneColFallDown( col )
    
    local dTime = 0
    local runTime = 0
    local maxTime = 0

    local OV = self.model:getOV()
    local OR = self.model:getOR()

    local cols = (self.model:getMatrixConf()).cols
    local rows = (self.model:getMatrixConf()).rows

    local onShowSpArray = self.model:getOnShowSpArray()

    for row=1, rows do
        local sp = onShowSpArray[col][row]
        local moveTime = 0.4 * (1 - 0.2 * (row -1))
        local actionMove = cc.MoveTo:create( 
                moveTime, cc.p(sp:getPositionX(), OR.y + (row -1 )* OV.y))
        
        dTime = 0.15 * (row -1)

        local actions = {}
        local delay = cc.DelayTime:create(dTime)

        local jumpY = 30 - (row - 1 ) * 10
        local actionUp = cc.JumpBy:create(0.35, cc.p(0,0), jumpY, 1)
        
        actions[#actions+1] = delay
        actions[#actions+1] = actionMove
        actions[#actions+1] = actionUp

        local sq = transition.sequence(actions)
        sp:runAction(sq)

        runTime = runTime + moveTime + 0.35 + dTime

        if runTime > maxTime then
            maxTime = runTime
        end
    end

    local playSound = function() 
        self:PlayReelStopSound()
    end
 
    self:runFunWithDelay(self.actionNode, playSound, 0.38)

    return maxTime
end 

-----------------------------------------------------------
-- AllColsFallDown
-----------------------------------------------------------
function SDC:allColsFallDown()
    local dTime = 0
    local runTime = 0
    local maxTime = 0 

    local colFallDown = function( col )
        runTime = self:oneColFallDown(col)
    end

    local cols = (self.model:getMatrixConf()).cols

    for col = 1, cols do
        dTime = 0.15 * (col - 1)

        local func = self:callbackWithArgs(colFallDown, col)

        self:runFunWithDelay(self.actionNode, func, dTime)

        runTime = runTime + dTime

        if runTime > maxTime then
            maxTime = runTime
        end
    end

    return maxTime

end

-----------------------------------------------------------
-- RemoveOneCol
-----------------------------------------------------------
function SDC:removeOneCol( col )
    
    local dTime = 0
    local runTime = 0

    local OV = self.model:getOV()
    local OR = self.model:getOR()

    local rows = (self.model:getMatrixConf()).rows
    local rmSymbolArray = self.model:getRmSymbolArray()

    for row = 1, rows do
        local sp = rmSymbolArray[col][row] 
        local point = cc.p(sp:getPositionX(), 
            OR.y - ( 4-1 )* OV.y)
        
        runTime = 0.3 * (1 - 0.1 * (row -1))

        local actions = {}
        dTime = 0.12*(row -1)
        
        local delay = cc.DelayTime:create(dTime)
        local move  =  cc.MoveTo:create(runTime , point)
        
        actions[#actions+1] = delay
        actions[#actions+1] = move

        local sq = transition.sequence(actions)
        sp:runAction(sq)
        
    end 

    return runTime + dTime
end

-----------------------------------------------------------
-- RemoveSymbols
-----------------------------------------------------------
function SDC:removeSymbols()
    
    local dTime = 0
    local runTime = 0
    local tallTime = 0

    local onShowSpArray = self.model:getOnShowSpArray()
    self.model:setRmSymbolArray(onShowSpArray)

    local rmSymbolArray = self.model:getRmSymbolArray()
    self.model:setOnShowSpArray({})

    local removeOneCol = function(col)
        runTime = self:removeOneCol(col)
    end

    local cols = (self.model:getMatrixConf()).cols

    for col = 1, cols do

        dTime = 0.12 * (col - 1)
        tallTime = tallTime + dTime

        local func = self:callbackWithArgs(removeOneCol, col)
        self:runFunWithDelay(self.actionNode, func, dTime)
        
    end

    tallTime = tallTime + runTime 

    return tallTime
end

-----------------------------------------------------------
-- ReleseSymbolSprite
-----------------------------------------------------------
function SDC:releseSymbolSprite()
    local sprite
    local cols = (self.model:getMatrixConf()).cols
    local rows = (self.model:getMatrixConf()).rows

    local effArray = self.model:getEffArray()
    local rmSymbolArray = self.model:getRmSymbolArray()

    for col=1, cols do
        for row=1, rows do
            sprite = rmSymbolArray[col][row] 
            sprite:removeFromParent()
        end
    end

    for k,eff in pairs(effArray) do
        eff:removeFromParent()
        effArray[k] = nil
    end
end

-----------------------------------------------------------
-- cleanLastSpin 
-----------------------------------------------------------
function SDC:cleanLastSpin()

    local runTime = 0

    self.model:setDoSpinCk(true)
    self.model:setRewardItems({})
    self.model:setPlayBouble(false)
    self.controlbarView:hideDouble()
    self:setState(SDC.STATE.ONCLEAUP)

    self.model:setTTWinCoin(0)
    self.model:setInitRound(1)
    self.controlbarView:setWinCoins(0)

    runTime = self:removeSymbols()

    local func = function() self:releseSymbolSprite() end

    self:runFunWithDelay(self.actionNode, func, runTime)

    return runTime - runTime

end

-----------------------------------------------------------
-- backToBaseMachine
-----------------------------------------------------------
function SDC:backToBaseMachine()

    self.controlbarView:hideFrLabel()
    self:changeSpinBtn(SDC.BTN_STATE.NORMAL)

    local rtime = self.machineView:backToBaseMachine()
    local initData = SlotsMgr.popInitDate()

    local cleanUp = function()    

        self.model:setFreeSpin(false)
        self.controlbarView:setWinCoins(0)
        self.model:setInitRound(initData.initRound)
        self.model:setRoundResult(initData.roundResult)

        local matrixConf    = self.model:getMatrixConf()
        local onShowSpArray = self.model:getOnShowSpArray()

        self.syLayer = self.machineView.symbolsColsLayer

        for col=1, matrixConf.cols do
            for row=1, #onShowSpArray[col] do
                if onShowSpArray[col][row] ~= -1 then
                    onShowSpArray[col][row]:removeFromParent(false)
                end
            end
            onShowSpArray[col] = {}
        end

    end

    local callback = function() 

        local winCoin = 0
        winCoin = winCoin + self.model:getFrCoins()

        local rdResult = self.model:getRoundResult()

        for i=1, initData.initRound do
            winCoin = winCoin + rdResult[i]:getRewardCoins()
        end

        self.model:setTTWinCoin(winCoin)
        self.model:upReelsForBaseSpin()

        self:initSymbols()

    end

    local goOn = function()

        self:doActionAfterInit()
        self:enabledSpinBtn(true)

    end

    self:runFunWithDelay(self.actionNode, cleanUp, rtime/2)
    self:runFunWithDelay(self.actionNode, callback, rtime/2 + 0.2)
    self:runFunWithDelay(self.actionNode, goOn, rtime + 0.2)

end

-----------------------------------------------------------
-- enterFreeSpin
-----------------------------------------------------------
function SDC:enterFreeSpin()

    local vtime = 1.5
    local view = require("app.scenes.slots.views.FreeSpinView").new()
    local func = function() view:removeFromParent(false) end

    self:addChild(view)
    self.model:pushInitData()
    self:runFunWithDelay(self.actionNode, func, vtime)

    local rtime = self.machineView:enterFreeSpin(vtime)

    local callback = function()

        local frCount = self.model:getFrSpinCount()

        self.model:setFrCoins(0)
        self.model:setFreeSpin(true)
        self.model:setFrSpinCount(frCount)

        self.controlbarView:showFrLabel()
        self.controlbarView:setWinCoins(0)
        self.controlbarView:setFrLabel(frCount)
        self:changeSpinBtn(self.BTN_STATE.FREESPIN)

        local matrixConf    = self.model:getMatrixConf()
        local onShowSpArray = self.model:getOnShowSpArray()

        self.model:setRoundResult({})

        for col=1, matrixConf.cols do

            for row=1, #onShowSpArray[col] do
                onShowSpArray[col][row]:removeFromParent(false)
            end

            onShowSpArray[col] = {}

        end

        self.model:upReelsForFreeSpin()

        self:initSymbols()
        self:doActionAfterInit()
        self:enabledSpinBtn(true)
        
    end

    self:enabledSpinBtn(false)
    self:runFunWithDelay(self.actionNode, callback, vtime + rtime/2)

end

-----------------------------------------------------------
-- enterBonus
-----------------------------------------------------------
function SDC:enterBonus()

    local onComplete = function()
    
        local id = DICT_MACHINE[tostring(self.machineId)].bonus_id
        local machineType = DICT_BONUS_CONFIG[tostring(self.machineId)].bonus_type

        -- id = "5"
        -- machineType = "3"

        local callback = function(coins)
            
            local winCoin = self.model:getTTWinCoin()

            winCoin = winCoin + coins
            self.model:setTTWinCoin(winCoin)
            self.controlbarView:setWinCoins(winCoin)

            local initData = SlotsMgr.popInitDate()

            self.model:setInitRound(initData.initRound)
            self.model:setRoundResult(initData.roundResult)

            local matrixConf    = self.model:getMatrixConf()
            local onShowSpArray = self.model:getOnShowSpArray()

            for col=1, matrixConf.cols do
                for row=1, #onShowSpArray[col] do
                    if onShowSpArray[col][row] ~= -1 then
                        onShowSpArray[col][row]:removeFromParent(false)
                    end
                end
                onShowSpArray[col] = {}
            end

            self:initSymbols()
            self:doActionAfterInit()
            self:enabledSpinBtn(true)

        end

        self.model:pushInitData()

        local bet = self.model:getBet()
        local reItems = self.model:getRewardItems()

        local initData = {bet=bet, rewardItems=reItems, callback=callback}
        local bonusLayer = require(self.BONUS_MAP[machineType]).new(id, initData)

        self:addChild(bonusLayer)

    end

    self:enabledSpinBtn(false)

    local view = require("app.scenes.slots.views.BonusDialogView").new({onComplete=onComplete})
    self:addChild(view)


end

-----------------------------------------------------------
-- PlayReelStopSound
-----------------------------------------------------------
function SDC:PlayReelStopSound()
    audio.playSound("slots/slots_shared_audio/stone_drop.mp3", false)
end

-----------------------------------------------------------
-- RegisterUIEvent 
-----------------------------------------------------------
function SDC:registerUIEvent()
    self.super.registerUIEvent(self)
end


-----------------------------------------------------------
-- 
-----------------------------------------------------------
function SDC:onEnter()
    print("SDC:onEnter")
    self.super.onEnter(self)
    self:registerUIEvent()
end

-----------------------------------------------------------
-- 
-----------------------------------------------------------
function SDC:onExit() 
    self.super.onExit(self)
    self.model = nil
    self.userModel = nil
    self.controlbarView = nil
    self.machineView = nil
    self.actionNode = nil
    self.lineView = nil

    collectgarbage("collect")
end

return SlotsDropController
