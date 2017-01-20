-----------------------------------------------------------
-- SlotsFloatController 
-----------------------------------------------------------
local ModelClass = require("app.scenes.slots.models.SlotsFloatModel")
local BaseController = require('app.scenes.slots.controllers.SlotsControllerBase') 
local WildManager = require("app.scenes.slots.controllers.wildController.WildManager")
local SlotsFloatController = class("SlotsFloatController", BaseController)

local SFC = SlotsFloatController

-----------------------------------------------------------
-- Construct
-----------------------------------------------------------
function SFC:ctor( initData, homeinfo )

    self.model = ModelClass.new(initData)
    self.super.ctor(self, initData, homeinfo)

    self:init()
    self.wildManager = WildManager.new(self)
    self.super.doActionAfterInit(self)

end

-----------------------------------------------------------
-- Init 
-----------------------------------------------------------
function SFC:init()
    
    self:initModel()
    self:initViews()
    self:initSymbols()
    
end

-----------------------------------------------------------
-- initViews 
-----------------------------------------------------------
function SFC:initViews()
    self.syLayer = self.machineView.symbolsColsLayer
end

-----------------------------------------------------------
-- InitModel 
-----------------------------------------------------------
function SFC:initModel()

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

    self.model:setMachineType(self.RUND_TYPE.FLOAT)

end

-----------------------------------------------------------
-- InitSymbols 
-----------------------------------------------------------
function SFC:initSymbols()

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
function SFC:initByResult()

    local OR = self.model:getOR()
    local OV = self.model:getOV()

    local cols = (self.model:getMatrixConf()).cols
    local rows = (self.model:getMatrixConf()).rows

    local roundResult = self.model:getRoundResult()
    local onShowSpArray = self.model:getOnShowSpArray() 
    local winSymbolsArray = self.model:getWinSymbolsArray()

    local pos = {}
    local symbol, matSym  
    local stopMatrixs = roundResult:getStopMatrix()

    for col = 1, cols do

        onShowSpArray[col] = {}
        winSymbolsArray[col] = {}

        for row = 1, rows do

            matSym = stopMatrixs[col][row]
            symId  = matSym:getSymbolId()

            pos.x = OR.x + (col -1) * OV.x
            pos.y = OR.y + (row -1) * OV.y
            
            symbol = SymbolMgr.create(symId, pos.x, pos.y)

            symbol:attachTo(self.syLayer)
            symbol.syIndex = matSym.symbolIdx
            onShowSpArray[col][row] = symbol
            winSymbolsArray[col][row] = symbol
            
        end
    end


end

-----------------------------------------------------------
-- initOnShowSymbols 
-----------------------------------------------------------
function SFC:initOnShowSymbols()

    local symbol, x, y
    local symId, reelId, symIds
    local OR = self.model:getOR()
    local OV = self.model:getOV()

    local cols = (self.model:getMatrixConf()).cols
    local rows = (self.model:getMatrixConf()).rows

    local onShowSpArray = self.model:getOnShowSpArray()  
    local winSymbolsArray = self.model:getWinSymbolsArray()

    for col = 1, cols do

        onShowSpArray[col] = {}
        winSymbolsArray[col] = {}
        reelId = self.model:getReels()[col]
        symIds = DICT_REELS[tostring(reelId)].symbol_ids

        for row = 1, rows do

            symId = symIds[row]
            x = OR.x + (col -1) * OV.x
            y = OR.y + (row -1) * OV.y
                    
            symbol = SymbolMgr.create(symId, x, y)

            symbol:attachTo(self.syLayer)
            onShowSpArray[col][row] = symbol
            winSymbolsArray[col][row] = symbol

        end
    end

end

-----------------------------------------------------------
-- PrepareSpin 
-----------------------------------------------------------
function SFC:prepareSpin()
    
    local reelId
    local symId, symIds, symbol, syIndex

    self:buildRoundResult(self.RUND_TYPE.DROP)

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

    local x,y = 0, -230
    local reelStopIdxs = roundResult:getReelStopIdxs()

    local OR = self.model:getOR()
    local OV = self.model:getOV()
    local cols = (self.model:getMatrixConf()).cols
    local rows = (self.model:getMatrixConf()).rows

    local onShowSpArray = self.model:getOnShowSpArray()
    local winSymbolsArray = self.model:getWinSymbolsArray()

    for col = 1, cols do
        
        onShowSpArray[col] = {}
        winSymbolsArray[col] = {}

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
            winSymbolsArray[col][row] = symbol

            reelStopIdxs[col] = self:getNextSyIdx(symIds, syIndex)

        end

    end

end

-----------------------------------------------------------
-- playSpinAnimation
-----------------------------------------------------------
function SFC:playSpinAnimation()
    
    local rtime = 0
    rtime = self:allColsFallDown()

    return rtime

end

-----------------------------------------------------------
-- onStopSpin
-----------------------------------------------------------
function SFC:onStopSpin()
    return 0
end

-----------------------------------------------------------
-- showResult
-----------------------------------------------------------
function SFC:showResult(callback)

    print("onShowRst begin")
    print("callback--2:", callback)

    local BTNS  = self.BTN_STATE
    local winInterval, noWinInterval = 0,0

    local wildTime = self:playWildEff()

    if self.spinBtnState == BTNS.AUTOSPIN or 
        self.spinBtnState == BTNS.FREESPIN or
        self.spinBtnState == BTNS.SUPERSPIN then

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
            if rdResult:getRewardCoins() > 0 and 
                self.model:isFreeSpin() ~= true and
                self.model:hasPlayBouble() ~= true  and
                self.spinBtnState ~= BTNS.SUPERSPIN then

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
-- UpUserData
-----------------------------------------------------------
function SFC:upUserData(rdResult)

    local rtime = 0

    if rdResult.hasUpUserData == true then
        return
    end

    self:updateCoins(rdResult)
    rdResult.hasUpUserData = true

    if self.model:getTTWinCoin() > 0 then
        self:playEffByWinCoins(rdResult)
    end

    return rtime

end

-----------------------------------------------------------
-- AllColsFallDown
-----------------------------------------------------------
function SFC:allColsFallDown()

    local runTime = 0
    local symbol, action

    local OR = self.model:getOR()
    local OV = self.model:getOV()
    local cols = (self.model:getMatrixConf()).cols
    local rows = (self.model:getMatrixConf()).rows

    local onShowSpArray = self.model:getOnShowSpArray()

    for row = rows, 1, -1 do
        for col = 1, cols do

            local rtime = math.random(15) * 0.05
            local mvTime = 1.7 + rtime

            symbol = onShowSpArray[col][row]
            local x = symbol:getPositionX()

            local actionMove = cc.MoveTo:create( 
                    mvTime, cc.p(x, OR.y + (row -1 )* OV.y))

            action = cc.EaseElasticOut:create(actionMove, 1.3)
            symbol:runAction(action)

            if mvTime  > runTime then
                runTime = mvTime 
            end

        end
    end
   
   return runTime - 1.2

end

-----------------------------------------------------------
-- hideAllSymbols
-----------------------------------------------------------
function SFC:hideAllSymbols()

    local symbol
    local cols = (self.model:getMatrixConf()).cols
    local rows = (self.model:getMatrixConf()).rows

    local onShowSpArray = self.model:getOnShowSpArray()

    for col = 1, cols do
        for row = 1, rows do
            symbol = onShowSpArray[col][row]
            symbol:runAnimationByName('disappear')
        end
    end
    
    return 15/30 

end

-----------------------------------------------------------
-- ReleseSymbolSprite
-----------------------------------------------------------
function SFC:releseSymbolSprite()

    local sprite
    local cols = (self.model:getMatrixConf()).cols
    local rows = (self.model:getMatrixConf()).rows

    local effArray = self.model:getEffArray()
    local onShowSpArray = self.model:getOnShowSpArray()

    for col=1, cols do
        for row=1, rows do
            sprite = onShowSpArray[col][row] 
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
function SFC:cleanLastSpin()

    local runTime = 0

    self.model:setDoSpinCk(true)
    self.model:setRewardItems({})
    self.model:setPlayBouble(false)
    self.controlbarView:hideDouble()
    self:setState(SFC.STATE.ONCLEAUP)

    self.model:setTTWinCoin(0)
    self.controlbarView:setWinCoins(0)

    local rdResult = self.model:getRoundResult()

    if table.nums(rdResult) > 0 then
        self:stopPlayLines()
    end

    runTime = self:hideAllSymbols()

    local func = function() self:releseSymbolSprite() end

    self:runFunWithDelay(self.actionNode, func, runTime)

    return runTime

end

-----------------------------------------------------------
-- backToBaseMachine
-----------------------------------------------------------
function SFC:backToBaseMachine()

    self:stopPlayLines()
    self:changeSpinBtn(SFC.BTN_STATE.NORMAL)

    local rtime = self.machineView:backToBaseMachine()
    local initData = SlotsMgr.popInitDate()

    self.lineView = self.bsLineView

    self.model:setFreeSpin(false)
    self.controlbarView:setWinCoins(0)
    self.model:setRoundResult(initData.roundResult)

    local matrixConf    = self.model:getMatrixConf()
    local onShowSpArray = self.model:getOnShowSpArray()

    self.model:setLastRtSpArray({})
    self.syLayer = self.machineView.symbolsColsLayer

    for col=1, matrixConf.cols do
        for row=1, #onShowSpArray[col] do
            if onShowSpArray[col][row] ~= -1 then
                onShowSpArray[col][row]:removeFromParent(false)
            end
        end
        onShowSpArray[col] = {}
    end

    local callback = function() 

        self.model:upReelsForBaseSpin()

        self:initSymbols()
        self:doActionAfterInit()
        self:enabledSpinBtn(true) 

        local rdResult = self.model:getRoundResult() 

        local winCoin = rdResult:getRewardCoins()
        winCoin = winCoin + self.model:getFrCoins()
        self.model:setTTWinCoin(winCoin)
        self.controlbarView:setWinCoins(winCoin)

    end
    self:runFunWithDelay(self.actionNode, callback, rtime )

end

-----------------------------------------------------------
-- enterFreeSpin
-----------------------------------------------------------
function SFC:enterFreeSpin()

    --
    local view = require("app.scenes.slots.views.FreeSpinView").new()
    local func = function() view:removeFromParent(false) end

    self:addChild(view)
    self:runFunWithDelay(self.actionNode, func, 1.5)

    self:stopPlayLines()
    self.model:pushInitData()
    local rtime = self.machineView:enterFreeSpin(1.2)

    local callback = function()

        local frCount = self.model:getFrSpinCount()

        self.model:setFrCoins(0)
        self.model:setFreeSpin(true)
        self.model:setFrSpinCount(frCount)
        self.controlbarView:setWinCoins(0)

        self:changeSpinBtn(self.BTN_STATE.FREESPIN)
        self.machineView.FreeSpinCounterLabel:setString(frCount)

        local matrixConf    = self.model:getMatrixConf()
        local onShowSpArray = self.model:getOnShowSpArray()

        self.lineView = self.frLineView

        self.model:setRoundResult({})
        self.syLayer = self.machineView.frsymbolsColsLayer

        for col=1, matrixConf.cols do

            for row=1, #onShowSpArray[col] do
                onShowSpArray[col][row]:removeFromParent(false)
            end

            onShowSpArray[col] = {}

        end

        self.model:upReelsForFreeSpin()

        self:initSymbols()
        self:doActionAfterInit()
        
    end

    self:runFunWithDelay(self.actionNode, callback, rtime)

end


-----------------------------------------------------------
-- RegisterUIEvent 
-----------------------------------------------------------
function SFC:registerUIEvent()
    self.super.registerUIEvent(self)
end


-----------------------------------------------------------
-- 
-----------------------------------------------------------
function SFC:onEnter()
    print("SFC:onEnter") 
    self.super.onEnter(self)
    self:registerUIEvent()
end

-----------------------------------------------------------
-- 
-----------------------------------------------------------
function SFC:onExit() 
    self.super.onExit(self)
    self.model = nil
    self.userModel = nil
    self.controlbarView = nil
    self.machineView = nil
    self.actionNode = nil
    self.lineView = nil

    collectgarbage("collect")
end

return SlotsFloatController