
local GameSet = require("app.data.slots.beans.GameSet")
local lineClass = require("app.scenes.slots.views.LineView")
local machClass = require("app.scenes.slots.views.MachineView")
local ctrbClass = require("app.scenes.slots.views.ControlbarView")
local doubClass = require("app.scenes.common.DoublePoker")
local cbarClass = require("app.scenes.common.ControllBar")
local paytClass = require("app.scenes.common.PaytableView")

-----------------------------------------------------------
-- SlotsControllerBase 
-----------------------------------------------------------
local SlotsControllerBase = class("SlotsControllerBase", function()
        return display.newNode()
end)

local SCB = SlotsControllerBase

SCB.STATE = {}
SCB.BONUS_MAP = {}
SCB.BTN_STATE = {}
SCB.BST_STATE = {}
SCB.RUND_TYPE = {}
SCB.BTN_CONFS = {}

SCB.AUTOSPIN_ACT_TIME   = 1

SCB.STATE.ONIDLE        = 1001
SCB.STATE.ONSPIN        = 1002
SCB.STATE.ONSTOP        = 1003
SCB.STATE.ONSHOWRE      = 1004
SCB.STATE.ONCLEAUP      = 1005

SCB.BTN_STATE.NORMAL    = 2001
SCB.BTN_STATE.AUTOSPIN  = 2002
SCB.BTN_STATE.FREESPIN  = 2003
SCB.BTN_STATE.STEPSPIN  = 2004

SCB.RUND_TYPE.DROP      = 'DROP'
SCB.RUND_TYPE.PUSH      = 'PUSH'
SCB.RUND_TYPE.NORMAL    = 'NORMAL'

SCB.BST_STATE.BOOSTER_MULITIPLE0 = 'BOOSTER_MULITIPLE0'
SCB.BST_STATE.BOOSTER_MULITIPLE2 = 'BOOSTER_MULITIPLE2'
SCB.BST_STATE.BOOSTER_MULITIPLE5 = 'BOOSTER_MULITIPLE5'

SCB.BTN_CONFS[SCB.BTN_STATE.NORMAL]    = "btn_spin_[STATE][UITHEME].png"
SCB.BTN_CONFS[SCB.BTN_STATE.FREESPIN]  = "btn_freespin_[STATE][UITHEME].png"
SCB.BTN_CONFS[SCB.BTN_STATE.AUTOSPIN]  = "btn_autospin_[STATE][UITHEME].png"
SCB.BTN_CONFS[SCB.BTN_STATE.STEPSPIN]  = "btn_autospin_[STATE][UITHEME].png"

SCB.BONUS_MAP["1"] = "app.scenes.slots.controllers.bonus.BonusBox3LifeScene"
SCB.BONUS_MAP["2"] = "app.scenes.slots.controllers.bonus.BonusBox5LevelsScene"
SCB.BONUS_MAP["3"] = "app.scenes.slots.controllers.bonus.BonusMatch3Scene"
SCB.BONUS_MAP["4"] = "app.scenes.slots.controllers.bonus.BonusJourneyScene"

-----------------------------------------------------------
-- @Construct:
-- initDataTpl.frWinCoin      = 0
-- initDataTpl.ttWinCoin      = 0
-- initDataTpl.machineId      = 0
-- initDataTpl.usedbstItem    = 0
-- initDataTpl.roundResult    = {}
-- initDataTpl.isDoSpinCk     = true
-- initDataTpl.isFreeSpin     = false
-- initDataTpl.hasPlayBouble  = false  
-----------------------------------------------------------
function SCB:ctor( initData, homeinfo )

    self.actionNode = display.newNode()
    self.lineAcNode = display.newNode()
    self.machineId  = initData.machineId

    self.bsLineView     = lineClass.new({machineId = initData.machineId})
    self.machineView    = machClass.new({machineId = initData.machineId})
    self.controlbarView = ctrbClass.new({machineId = initData.machineId})

    self:addChild(self.lineAcNode)
    self:addChild(self.actionNode)
    self:addChild(self.machineView)
    self:addChild(self.controlbarView)

    self.machineView.linesLayer:addChild(self.bsLineView)
    
    self.super.init(self, initData)
    self:setNodeEventEnabled(true)

    -- layout

    local theight = self.controlbarView:getTopHeight()
    local bheight = self.controlbarView:getBottomHeight()
    local centerY = (display.height - theight - bheight)/2
    local keyPosY = bheight + centerY

    self.machineView:setMachineNodePosisionY(keyPosY)

    local uiPosY = self.machineView:getUIbottomPosY()

    if uiPosY > bheight then

        local dtY = uiPosY - bheight
        local oldY = self.machineView:getMachineNodePosisionY()
        self.machineView:setMachineNodePosisionY(oldY - dtY)

    end

    --
    self:adaptive()
end

-----------------------------------------------------------
-- Init 
-----------------------------------------------------------
function SCB:adaptive(  )
    if tonumber(self.machineId) == 1 then
        local theight = self.controlbarView:getTopHeight()
        local topScreenY = display.height - theight

        local eff = self.machineView.selfFrameSprite
        local fieEffNode = self.machineView.selfEffSprite
        if eff ~= nil and fieEffNode ~= nil then
            local originY = eff:getPositionY()
            local size = eff:getContentSize()

            local effPos = eff:getParent():convertToWorldSpace(cc.p(eff:getPosition()))
            local effScreenTopY = effPos.y + size.height
            if effScreenTopY > topScreenY then
                eff:setPositionY(originY - size.height)

                fieEffNode:setPositionY(originY - size.height)
            end
        end
    end
end

-----------------------------------------------------------
-- Init 
-----------------------------------------------------------
function SCB:init( initData )

    self.state  = SCB.STATE.ONIDLE
    self.spinBtnState  = SCB.BTN_STATE.NORMAL
    self.usedboostItem = SCB.BST_STATE.BOOSTER_MULITIPLE0
    self.userModel = app:getObject("UserModel")
    self.reportModel = app:getObject("ReportModel")
    
    self.super.initViews(self, initData)
    self:loadSpriteFrame()

    -- for DataReport
    self.fiveInARow  = 0
    self.freeSpinCnt = 0
    self.bonusCnt    = 0
    self.bounsWin    = 0
    self.bounsScore  = 0

    self.machineName = DICT_MACHINE[tostring(self.machineId)].machine_name
    self.used_lines  = #DICT_MACHINE[tostring(self.machineId)].used_lines

end

-----------------------------------------------------------
-- InitView 
-----------------------------------------------------------
function SCB:initViews( initData )

    self.lineView = self.bsLineView
    self.controlbarView:updateTTBet(self.model:getTTbet())
    self.controlbarView:setTTCoins(self.userModel:getCoins())
    self.controlbarView:updateWinCoinLabel(initData.ttWinCoin)
    
end

-----------------------------------------------------------
-- RegisterUIEvent 
-----------------------------------------------------------
function SCB:registerUIEvent()

    local scEntry
    local autoTimer = 0
    local autoTicker = function(dt)
        autoTimer = autoTimer + dt 
        if autoTimer > SCB.AUTOSPIN_ACT_TIME and 
            self.spinBtnState == SCB.BTN_STATE.NORMAL then
            autoTimer = 0
            self.trigerAuto = true
            self:onAutoSpin()
            self:changeSpinBtn(SCB.BTN_STATE.AUTOSPIN)
            SlotsMgr.scheduler.unscheduleGlobal(scEntry)
        end
    end

    local spinBtn = self.controlbarView.spinBtn
    local addBetBtn = self.controlbarView.addBetBtn
    local subBetBtn = self.controlbarView.subBetBtn
    local doubleBtn = self.controlbarView.doubleBtn
    local maxBetBtn = self.controlbarView.maxBetBtn
    local paytableBtn = self.controlbarView.payTableBtn
    local topbar = self.controlbarView.topbar

    self.spinBtn = core.displayEX.spinButton(spinBtn, RES_AUDIO.btn_spin)
        :onButtonClicked(function()
            topbar:hideMenu()
            self:spinBtnHandle() 
        end)
        :onButtonPressed(function()
            topbar:hideMenu()
            if scEntry then SlotsMgr.scheduler.unscheduleGlobal(scEntry) end
            scEntry = SlotsMgr.scheduler.scheduleGlobal(autoTicker, 0)
        end)
        :onButtonReleased(function() 
            autoTimer = 0
            SlotsMgr.scheduler.unscheduleGlobal(scEntry)
        end)

    self.addBetBtn = core.displayEX.newButton(addBetBtn)
        :onButtonClicked(function() 
            topbar:hideMenu()
            self:addBetHandle() 
        end)

    self.subBetBtn = core.displayEX.newButton(subBetBtn)
        :onButtonClicked(function() 
            topbar:hideMenu()
            self:subBetHandle() 
        end)

    self.doubleBtn = core.displayEX.newButton(doubleBtn)
        :onButtonClicked(function() 
            topbar:hideMenu()
            self:doubleHandle() 
        end)

    self.maxBetBtn = core.displayEX.newButton(maxBetBtn)
        :onButtonClicked(function() 
            --print("to do!!")
            topbar:hideMenu()
            self:enabledSpinBtn(false)
            self:maxBetHandle()
            self:spinBtnHandle()
        end)

    self.paytableBtn = core.displayEX.newButton(paytableBtn)
        :onButtonClicked(function()
            topbar:hideMenu()
            local ccbi = DICT_MAC_RES[tostring(self.machineId)].paytable
            local pageSize = DICT_MAC_RES[tostring(self.machineId)].paytable_page_size
            local view = paytClass.new({ccbi = ccbi, page = tonumber(pageSize)})
            self:addChild(view)
        end)

    EventMgr:addEventListener(EventMgr.OFFLINE_STOP_SUTOSPIN, handler(self, self.offlineStopAutospin))
end

-----------------------------------------------------------
-- doubleHandle
-----------------------------------------------------------
function SCB:doubleHandle()

    local macType = self.model:getMachineType()

    local callback = function(winCoin)

        --local ttWinCoin = self.model:getTTWinCoin()
        
        --ttWinCoin = ttWinCoin + winCoin

        if winCoin < 0 then
            winCoin = 0
        end

        self.model:setTTWinCoin(winCoin)

        local userCoin = self.userModel:getCoins()
        
        self.controlbarView:setTTCoins(number.commaSeperate(userCoin))
        self.controlbarView:setWinCoins(number.commaSeperate(winCoin))

        if macType ~= SCB.RUND_TYPE.DROP then
            self:playLineEff()
        end

        self.controlbarView:hideDouble()

        audio.playMusic(DICT_MAC_RES[tostring(self.machineId)].bgMusic, true)
    end

    if macType ~= SCB.RUND_TYPE.DROP then
        self:stopPlayLines()
    end

    local wcons = self.model:getTTWinCoin() 
    local layer = doubClass.new({wincoins=wcons, callback=callback})
    self:addChild(layer)

end

-----------------------------------------------------------
-- addBetHandle
-----------------------------------------------------------
function SCB:addBetHandle()
    if self:showChangeBetTip(true) then
        return
    end

    local newBet
    local oldBet = self.model:getBet()
    local betList = self:getBetList()
    local lines = #DICT_MACHINE[tostring(self.machineId)].used_lines

    for i=1, #betList do
        if oldBet == betList[i] then
            if i == #betList then
                newBet = betList[1]
            else
                newBet = betList[i+1]
            end
            break
        end
    end

    local ttBet = newBet * lines

    self.model:setBet(newBet)
    self.model:setTTbet(ttBet)
    self.controlbarView:updateTTBet(ttBet)

end

-----------------------------------------------------------
-- subBetHandle
-----------------------------------------------------------
function SCB:subBetHandle()
    if self:showChangeBetTip(false) then
        return
    end

    local newBet
    local oldBet = self.model:getBet()
    local betList = self:getBetList()
    local lines = #DICT_MACHINE[tostring(self.machineId)].used_lines

    for i=1, #betList do
        if oldBet == betList[i] then
            if i == 1 then
                newBet = betList[#betList]
            else
                newBet = betList[i-1]
            end
            break
        end
    end

    local ttBet = newBet * lines

    self.model:setBet(newBet)
    self.model:setTTbet(ttBet)
    self.controlbarView:updateTTBet(ttBet)

end

-----------------------------------------------------------
-- getBetList
-----------------------------------------------------------
function SCB:getBetList()
    --return DICT_BET['22'].bet_list
    local userlevel = app:getUserModel():getLevel()
    return getBetList(userlevel).list
end

-----------------------------------------------------------
-- maxBetHandle
-----------------------------------------------------------
function SCB:maxBetHandle()

    local betList = self:getBetList()
    local lines = #DICT_MACHINE[tostring(self.machineId)].used_lines
    local newBet = betList[#betList]

    local ttBet = newBet * lines

    self.model:setBet(newBet)
    self.model:setTTbet(ttBet)
    self.controlbarView:updateTTBet(ttBet)
end

-----------------------------------------------------------
-- RunSpin
-----------------------------------------------------------
function SCB:runSpin()

    collectgarbage("collect")

    print("regular spin:", self.state)

    local BTNS = SCB.BTN_STATE
    
    self.super.lockUI(self)

    local callback = function ()
        self:setState(SCB.STATE.ONIDLE)
        self.super.spinCallBack(self)
    end

    local showResult = function(ck)
        self.super.showResult(self, ck)
    end

    local showResultFun = cc.CallFunc:create(
        self:callbackWithArgs(showResult, callback))
    
    self.super.prepareSpin(self)
    
    local actions = {}

    local time = self.super.playSpinAnimation(self)
    local delay = cc.DelayTime:create(time) 
    
    local actions = {} 
    actions[#actions+1] = delay
    actions[#actions+1] = showResultFun
    
    local sq = transition.sequence(actions)
    self.actionNode:runAction(sq)

    -- self.reportModel:test()

end


-----------------------------------------------------------
-- SpinBtnHandle
-----------------------------------------------------------
function SCB:spinBtnHandle()

    -- if true then return end

    print("self.state:", self.state)
    print("self.spinBtnState:", self.spinBtnState)

    if not self.trigerAuto and  
        self.spinBtnState == SCB.BTN_STATE.AUTOSPIN then
        self:changeSpinBtn(SCB.BTN_STATE.NORMAL)
    end

    if self.trigerAuto == true then
        self.trigerAuto = false
        return
    end

    if self.state == SCB.STATE.ONSPIN then

        local rtime = self.super.onStopSpin(self)

        print("111 self.state == SCB.STATE.ONSPIN", rtime)

        if rtime == 0 then return end
        
        self:setState(self.STATE.ONSTOP)
        local callback = function()
            self:setState(SCB.STATE.ONIDLE)
            self.super.spinCallBack(self)
        end

        local showResult = function(ck)
            self:showResult(ck)
        end

        local showResultFun = self:callbackWithArgs(showResult, callback)
        self:runFunWithDelay(self.actionNode, showResultFun, rtime)

    elseif self.state == SCB.STATE.ONIDLE then

        print("222 self.state == SCB.STATE.ONIDLE")

        if not self:checkSpin() then return end

        local time = self:cleanLastSpin()
        self:setState(SCB.STATE.ONSPIN)
        local delaySpin = function()
            self:runSpin()
        end

        self:runFunWithDelay(self.actionNode, delaySpin, time)

    else
        print("*** spin error ****")
    end

end

-----------------------------------------------------------
-- onStopSpin
-----------------------------------------------------------
function SCB:onStopSpin()
    return self:onStopSpin()
end

-----------------------------------------------------------
-- onAutoSpin
-----------------------------------------------------------
function SCB:onAutoSpin()
    
    if self.state == SCB.STATE.ONIDLE then

        if not self:checkSpin() then
            self.trigerAuto = false
            self:changeSpinBtn(SCB.BTN_STATE.NORMAL)
            self:enabledSpinBtn(true)
            self:unLockUI()
            return
        end

        local time = self:cleanLastSpin()
        self:setState(SCB.STATE.ONSPIN)
        local delaySpin = function()
            self:runSpin()
        end

        self:runFunWithDelay(self.actionNode, delaySpin, time)
        
    end
      
end

-----------------------------------------------------------
-- onFreeSpin
-----------------------------------------------------------
function SCB:onFreeSpin()

    local frCount = self.model:getFrSpinCount() - 1

    if frCount == 0 then self:enabledSpinBtn(false) end

    if frCount < 0 then

        local macType = self.model:getMachineType()

        if macType ~= SCB.RUND_TYPE.DROP then
            self:stopPlayLines()
        end

        local callback = function()
            self:backToBaseMachine()
        end

        if tonumber(self.model:getFrCoins()) > 0 then
            local view = require("app.scenes.slots.views.FreeSpinWinView").new({
                coins = self.model:getFrCoins(),
                okHandle = callback })
            self:addChild(view)
        else
            callback()
        end
        return
    end

    self.model:setFrSpinCount(frCount)
    self.controlbarView:setFrLabel(frCount)

    if self.btnState ~= SCB.BTN_STATE.FREESPIN then
        self:changeSpinBtn(SCB.BTN_STATE.FREESPIN)
    end

    local time = self:cleanLastSpin()
    self:setState(SCB.STATE.ONSPIN)
    local delaySpin = function()
        self:runSpin()
    end

    self:runFunWithDelay(self.actionNode, delaySpin, time)

end

-----------------------------------------------------------
-- BuildRoundResult
-----------------------------------------------------------
function SCB:buildRoundResult()

    local bet = self.model:getBet()
    local holdWilds = self.model:getHoldWilds()

    local machineId = self.model:getMachineId()

    local replaceWilds= self.model:getWildSteps()

    if self.model:isFreeSpin() then
        machineId = DICT_MACHINE[tostring(machineId)].f_machine_id
    end

    local bstItem = ITEM_TYPE[self.model:getUsedBoost()]
    local gameSet = GameSet.new(tonumber(machineId), bet)

    if holdWilds and #holdWilds >0 then 
        gameSet:setHoldWilds(holdWilds)
    elseif replaceWilds and #replaceWilds > 0 then
        gameSet:setHoldWilds(replaceWilds)
    end

    local rdResult
    local apiType = self.model:getMachineType()

    if apiType == SCB.RUND_TYPE.DROP then
        rdResult = data.slots.MachineApi.getNormalDropResult(gameSet)  
    else
        rdResult = data.slots.MachineApi.getNormalRoundResult(gameSet) 
    end

    self.model:setRoundResult(clone(rdResult))
    
end

-----------------------------------------------------------
-- updateExp
-----------------------------------------------------------
function SCB:updateExp( exp )

    -- debug
    --if true then return end

    local onCallBack = function()
        exp = exp + self.userModel:getExp()
        self.userModel:setExp(exp)
        EventMgr:dispatchEvent({name = EventMgr.UPDATE_LOBBYUI_EVENT})
    end
    AnimationUtil.MoveExp(
        "btn_star.png",
        15, 
        self.spinBtn, 
        self.controlbarView.expProgress,
        self, 
        onCallBack
    )

end

-----------------------------------------------------------
-- PrepareSpin
-----------------------------------------------------------
function SCB:prepareSpin()
    self:prepareSpin()
end

-----------------------------------------------------------
-- PlaySpinAnimation
-----------------------------------------------------------
function SCB:playSpinAnimation() 
    return self:playSpinAnimation()
end

-----------------------------------------------------------
-- ShowResult
-----------------------------------------------------------
function SCB:showResult(callback) 
    self:showResult(callback)
end

-----------------------------------------------------------
-- PlayEffect
-----------------------------------------------------------
function SCB:playEffect() 

    local rt = 0
    local rdResult = self.model:getRoundResult()
    local wilds = rdResult.replaceWilds
        
    local function playLineEff()
        self:playLineEff()
    end

    self:runFunWithDelay(self.actionNode, playLineEff , rt)

    if rdResult.hasPlayWinEff then
        return rt
    end

    local fiveWinTime = 0
    
    if 1 == rdResult:getFiveWin() then
        self.fiveInARow = 1
        fiveWinTime = self:playFiveOfKind()
    end

    rt = rt + fiveWinTime + self:playEffByWinCoins(rdResult, fiveWinTime)
    self:runFunWithDelay(self.actionNode, function() self:updateCoins(rdResult) end, rt)

    rdResult.hasPlayWinEff = true

    return rt

end

-----------------------------------------------------------
-- playFiveOfKind
-----------------------------------------------------------
function SCB:playFiveOfKind()

    local rtime = 2
    local view = require("app.scenes.slots.views.FiveOfKindView").new({})
    self:addChild(view)

    return rtime

end

-----------------------------------------------------------
-- PlayEffByWinCoins
-----------------------------------------------------------
function SCB:playEffByWinCoins(rdResult, dtime) 
    
    local rt = 0
    local megaTime, bigTime, smallTime = 4.5, 3.5, 2

    local callfunc
    local actions = {}
    local delay = cc.DelayTime:create(dtime)

    actions[#actions+1] = delay

    local ttBet = self.model:getTTbet()
    local winCoin = rdResult:getRewardCoins()


    local mega = winCoin >= 10 * ttBet
    local bigw = winCoin >= 5 * ttBet and winCoin < 10 * ttBet
    local small = winCoin >= 2 * ttBet and winCoin < 5 * ttBet

    if  mega == true then
        
        rt = rt + megaTime

        callfunc = function()
            local view = require("app.views.MegaWinView").new({
            winCoin = winCoin})
            self:addChild(view)
        end

        actions[#actions+1] = cc.CallFunc:create(callfunc)

    elseif bigw == true  then

        rt = rt + bigTime

        callfunc = function()
            local view = require("app.views.BigWinView").new({
            winCoin = winCoin})
            self:addChild(view)
        end

        actions[#actions+1] = cc.CallFunc:create(callfunc)

    elseif small == true  then
        rt = rt + smallTime
        callfunc = function ()
            --当上一次动画没有停止时，这时又要播放此动画，就会出现有一次未停止的情况
            if self.smallwineff then
                self.smallwineff:removeFromParent()
                self.smallwineff = nil
            end
            self.smallwineff = CCBuilderReaderLoad("view/smallwin.ccbi",{})
            self.controlbarView:addSmallWinEff(self.smallwineff)

            local fun = function()
                if self.smallwineff then
                    self.smallwineff:removeFromParent()
                end
                self.smallwineff = nil
            end
            self:runFunWithDelay(self.actionNode, fun, smallTime)
        end

        actions[#actions+1] = cc.CallFunc:create(callfunc)

    elseif winCoin > 0 then

        audio.playSound("shared/shared_audio/SmallWin.mp3")

    end
    

    local sq = transition.sequence(actions)
    self.actionNode:runAction(sq)

    return rt

end

-----------------------------------------------------------
-- PlayLineEff
-----------------------------------------------------------
function SCB:playLineEff() 

    local ttRunTime = 0
    local rdResult = self.model:getRoundResult()
    local linePattern = rdResult:getLinePattern()
    local winSymbolsArray = self.model:getWinSymbolsArray()

    if table.nums(linePattern) == 0 then
        return ttRunTime
    end

    local lineIdArray = {} 

    local drawLines = function()

        local runTime = 2
        ttRunTime = ttRunTime + runTime

        local symbol,winSymbols,col,row
        for lineNum,pattern in pairs(linePattern) do
            self.lineView:showLine(lineNum)
            self.lineView:blinkLineById(lineNum)
            table.insert(lineIdArray, lineNum)
        end
        
    end

    local playOneLine
    local getOnComplete

    getOnComplete = function ( lineId )
        
        if not self.autoPlay then 
            return nil
        end

        local nextId
        for i=1,#lineIdArray do
            if lineId == lineIdArray[i] then
                nextId = lineIdArray[i+1]
                if not nextId then
                    nextId = lineIdArray[1]
                end
            end
        end

        return function() 
            playOneLine( nextId, getOnComplete(nextId) ) 
        end
    
    end

    playOneLine = function(lineId , onComplete)

        local symbol,winSymbols,col,row
        local pattern = linePattern[lineId]

        self.lineView:showLine(lineId)
        self.lineView:blinkLineById(lineId)

        winSymbols = pattern:getWinSymbols()

        local cols = (self.model:getMatrixConf()).cols
        local rows = (self.model:getMatrixConf()).rows

        for col=1, cols do
            for row=1, rows do
                symbol = self:getWinSymbol(col, row)
                symbol:attachToNewNode(self:getColSyLayer(col))
            end
        end

        for i=1, #winSymbols do
            col = winSymbols[i]:getX() + 1
            row = winSymbols[i]:getY() + 1
            symbol = self:getWinSymbol(col, row)
            
			symbol:runWinAnimation(
                DICT_MAC_RES[tostring(self.machineId)].win_animation)

            symbol:attachToNewNode(self.machineView:getAnimtionsLayer())

        end

        local callfunc = function()
            
            self.lineView:hideLineById(lineId)

            for i=1, #winSymbols do
                col = winSymbols[i]:getX() + 1
                row = winSymbols[i]:getY() + 1
                symbol = self:getWinSymbol(col, row)
                -- if symbol.isHold ~= true then         
                    symbol:runAnimationByName('idle')
                -- end
            end

            local isStepSymbol = false
            for col=1, cols do
                for row=1, rows do
                    symbol,isStepSymbol = self:getWinSymbol(col, row)
                    if isStepSymbol and (not self.lineView:containPos(lineId,row,col)) then
                        symbol:runAnimationByName('idle')
                    end
                end
            end


            if onComplete and self.autoPlay then 
                onComplete()
            end

        end

        self:runFunWithDelay(self.lineAcNode, callfunc , 1 + 4/30)

    end

    local autoPlay = function()
        
        if not self.autoPlay then
            return
        end

        self:stopPlayLines()
        self.machineView:showGreyLayer()
        playOneLine(lineIdArray[1], getOnComplete(lineIdArray[1]))

    end

    drawLines()
    self.autoPlay = true
    self:runFunWithDelay(self.lineAcNode, autoPlay, 1.24)

    return ttRunTime

end

-----------------------------------------------------------
-- getWinSymbol
-----------------------------------------------------------
function SCB:getWinSymbol(col, row)
    local winSymbolsArray = self.model:getWinSymbolsArray()
    return winSymbolsArray[col][row]
end

-----------------------------------------------------------
-- stopPlayLines
-----------------------------------------------------------
function SCB:stopPlayLines()

    local rdResult = self.model:getRoundResult()

    if  0 == table.nums(rdResult) then
        return
    end

    local lpCounts = table.nums(rdResult:getLinePattern())
        
    if 0 == lpCounts then
        return
    end

    local symbol, col, row, winSymbols
    local linePattern = rdResult:getLinePattern()

    local cols = (self.model:getMatrixConf()).cols
    local rows = (self.model:getMatrixConf()).rows

    local newNode, isStepSymbol
    for col=1, cols do
        for row=1, rows do
            symbol,isStepSymbol = self:getWinSymbol(col, row)
            newNode = self:getColSyLayer(col)
            if symbol.isHold or isStepSymbol then
                newNode = self.machineView:getAnimtionsLayer()
            end
            symbol:attachToNewNode(newNode)
        end
    end


    for lineNum, pattern in pairs(linePattern) do

        self.lineView:hideLineById(lineNum)

        winSymbols = pattern:getWinSymbols()
        for i=1,#winSymbols do
            col = winSymbols[i]:getX() + 1
            row = winSymbols[i]:getY() + 1
            symbol = self:getWinSymbol(col, row)

            -- if symbol.isHold ~= true then
                symbol:runAnimationByName('idle')
            -- end
        end

    end

    self.machineView:hideGreyLayer()
    self.lineAcNode:stopAllActions()

end

-----------------------------------------------------------
-- PlayWildEff
-----------------------------------------------------------
function SCB:playWildEff() 

    local ttRunTime = 0
    local logicId, symId

    local roundResult = self.model:getRoundResult()
    
    if roundResult.hasPlayWild then
        return ttRunTime
    end

    roundResult.hasPlayWild = true

    local holdWildArray = roundResult:getHoldWilds()
    local serialWildArray = roundResult:getSerialWilds()
    local replaceWildsArray = roundResult:getReplaceWilds()

    -- wild replace
    if table.nums(replaceWildsArray) > 0 then

        for k, wildreObj in pairs(replaceWildsArray) do
            symId = wildreObj.sourceSymbol:getSymbolId()
            logicId = DICT_WILD_REEL[tostring(symId)].logic_id
            ttRunTime = self.wildManager:playWild(logicId, wildreObj)
        end

    -- wildhold or wildstep
    elseif table.nums(holdWildArray) > 0 then
        symId = holdWildArray[1]:getSymbolId()
        logicId = DICT_WILD_REEL[tostring(symId)].logic_id
        ttRunTime = self.wildManager:playWild(logicId, holdWildArray)

    -- wild serial
    elseif table.nums(serialWildArray) > 0 then

        symId = serialWildArray[1]:getMiddleSymbol():getSymbolId()
        logicId = DICT_WILD_REEL[tostring(symId)].logic_id
        ttRunTime = self.wildManager:playWild(logicId, serialWildArray)

    end

    return ttRunTime

end

-----------------------------------------------------------
-- updateCoins
-----------------------------------------------------------
function SCB:updateCoins(rdResult) 

    local rewardCoin = rdResult:getRewardCoins()
    local isFreeSpin = self.model:isFreeSpin()

    if rdResult.hasUpdateCoins == true then
        return
    end

    if isFreeSpin then
        local frCoin = self.model:getFrCoins()
        self.model:setFrCoins(frCoin + rewardCoin)
    end

    local ttCoin = rewardCoin + self.userModel:getCoins()
    local winCoin = rewardCoin + self.model:getTTWinCoin()

    self.userModel:setCoins(ttCoin)
    self.model:setTTWinCoin(winCoin)

    self.controlbarView:upTTCoinsByStep(ttCoin)
    self.controlbarView:upWinCoinsByStep(winCoin)

    rdResult.hasUpdateCoins = true

end

-----------------------------------------------------------
-- backToBaseMachine
-----------------------------------------------------------
function SCB:backToBaseMachine()

    self:stopPlayLines()
    self:changeSpinBtn(SCB.BTN_STATE.NORMAL)
    self:enabledSpinBtn(false) 
    self.controlbarView:hideFrLabel()

    local rtime = self.machineView:backToBaseMachine()

    local cleanUp = function()

        local initData = SlotsMgr.popInitDate()
        local matrixConf    = self.model:getMatrixConf()
        local colLayerArray = self.model:getColLayerArray()
        local onShowSpArray = self.model:getOnShowSpArray()

        self.model:setFreeSpin(false)
        self.model:setLastRtSpArray({})
        self.model:setRoundResult(initData.roundResult)

        self.controlbarView:setWinCoins(0)

        for col=1, matrixConf.cols do
            for row=1, #onShowSpArray[col] do
                if onShowSpArray[col][row] ~= -1 then
                    onShowSpArray[col][row].isLastRt = false
                    onShowSpArray[col][row]:removeFromParent(false)
                end
            end
            onShowSpArray[col] = {}
            colLayerArray[col] = self.machineView.colLayer[col]
        end

        self:reSetColLayer()
        self:cleanHoldArray()

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

    self:runFunWithDelay(self.actionNode, cleanUp, rtime/2)
    self:runFunWithDelay(self.actionNode, callback, rtime/2 + 0.2)

end

-----------------------------------------------------------
-- enterFreeSpin
-----------------------------------------------------------
function SCB:enterFreeSpin()

    local vtime = 1.5
    local view = require("app.scenes.slots.views.FreeSpinView").new()
    local func = function() view:removeFromParent(false) end

    self:runFunWithDelay(self.actionNode, func, vtime)

    self:addChild(view)
    self:stopPlayLines()
    self.model:pushInitData()

    local rtime = self.machineView:enterFreeSpin(vtime)
    self:runFunWithDelay(self.actionNode, function() self:cleanHoldArray()  end, rtime)

    local callback = function()

        local frCount = self.model:getFrSpinCount()

        self.model:setFrCoins(0)
        self.model:setFreeSpin(true)
        self.model:setFrSpinCount(frCount)

        self.controlbarView:showFrLabel()
        self.controlbarView:setWinCoins(0)
        self.controlbarView:setFrLabel(frCount)

        self:changeSpinBtn(self.BTN_STATE.FREESPIN)
        self:enabledSpinBtn(false)
        
        local matrixConf    = self.model:getMatrixConf()
        local colLayerArray = self.model:getColLayerArray()
        local onShowSpArray = self.model:getOnShowSpArray()

        self.model:setRoundResult({})
        self.model:setLastRtSpArray({})

        for col=1, matrixConf.cols do

            for row=1, #onShowSpArray[col] do
                if onShowSpArray[col][row] ~= -1 then
                    onShowSpArray[col][row].isLastRt = false
                    onShowSpArray[col][row]:removeFromParent(false)
                end
            end

            onShowSpArray[col] = {}
            colLayerArray[col] = self.machineView.colLayer[col]

        end

        self.model:upReelsForFreeSpin()

        self:reSetColLayer()
        self:initSymbols()
        
    end

    local goOn = function()
        self:doActionAfterInit()
        self:enabledSpinBtn(true)
    end

    self:enabledSpinBtn(false)
    self:runFunWithDelay(self.actionNode, callback, vtime + rtime/2)
    self:runFunWithDelay(self.actionNode, goOn, vtime + rtime)

end

-----------------------------------------------------------
-- cleanHoldArray
-----------------------------------------------------------
function SCB:cleanHoldArray()

    local symbol
    local onHoldWildArray = self.model:getOnHoldWildArray()

    for k,sy in pairs(onHoldWildArray) do

        symbol = sy.symbolObj
        symbol.isHold = false
        symbol:setHoldLabel('')
        symbol:removeFromParent()

    end

    self.model:setOnHoldWildArray({})

end

-----------------------------------------------------------
-- enterBonus
-----------------------------------------------------------
function SCB:enterBonus()

    local onComplete = function()

        local id = DICT_MACHINE[tostring(self.machineId)].bonus_id
        local machineType = DICT_BONUS_CONFIG[tostring(self.machineId)].bonus_type

        self:stopPlayLines()

        local callback = function(coins)

            self.bounsWin = self.bounsWin + coins
            
            local winCoin = self.model:getTTWinCoin()
            
            winCoin = winCoin + coins
            
            self.model:setTTWinCoin(winCoin)
            self.controlbarView:setWinCoins(winCoin)
            self.model:setDoSpinCk(true)
            self:doActionAfterInit()
            self:enabledSpinBtn(true)

        end

        local bet = self.model:getBet()
        local reItems = self.model:getRewardItems()

        local initData = {bet=bet, rewardItems=reItems, callback=callback}
        local bonusLayer = require(self.BONUS_MAP[machineType]).new(id, initData)

        self:addChild(bonusLayer)

    end

    local view = require("app.scenes.slots.views.BonusDialogView").new({onComplete=onComplete})

    self:enabledSpinBtn(false)

    self:stopPlayLines()
    self:addChild(view)

end

-----------------------------------------------------------
-- SettleFreeSpinOrBonus
-----------------------------------------------------------
function SCB:settleFreeSpinOrBonus( rdResult ) 

    -- if true then return true end

    local redItems = rdResult:getRewardItems()
    -- if not self.model:isFreeSpin() then redItems[ITEM_TYPE.BONUS_MULITIPLE] = nil end
    -- if not self.model:isFreeSpin() then redItems[ITEM_TYPE.FREESPIN_MULITIPLE] = 2 end


    local bsCount = redItems[ITEM_TYPE.BONUS_MULITIPLE]
    local frCount = redItems[ITEM_TYPE.FREESPIN_MULITIPLE]

    self.model:setRewardItems(redItems)

    if bsCount ~= nil and rdResult.bonusBeSettled ~= true then

        self.bonusCnt = self.bonusCnt + bsCount

        self.model:setDoSpinCk(false)
        rdResult.bonusBeSettled = true
        self:enterBonus()

    elseif frCount ~= nil and rdResult.freeBeSettled ~= true then

        self.freeSpinCnt = self.freeSpinCnt + frCount

        if self.model:isFreeSpin() then
            local count = self.model:getFrSpinCount()
            self.model:setFrSpinCount(count + frCount)
        else

            self.model:setDoSpinCk(false)
            self.model:setFrSpinCount(frCount)
            rdResult.freeBeSettled = true
            self:enterFreeSpin()

        end
    end

end

-----------------------------------------------------------
-- IsRoundPause
-----------------------------------------------------------
function SCB:isRoundPause( rdResult )

    local rt = false
    local reItems = rdResult:getRewardItems()

    local isBonus = reItems[ITEM_TYPE.BONUS_MULITIPLE] ~= nil 
        and rdResult.bonusBeSettled ~= true
    
    local isFreeSpin = reItems[ITEM_TYPE.FREESPIN_MULITIPLE] ~= nil 
        and rdResult.freeBeSettled ~= true 

    if isBonus or isFreeSpin then
        rt = true
    end

    return rt

end

-----------------------------------------------------------
-- SetState
-----------------------------------------------------------
function SCB:setState( state ) 
    self.state = state
end

-----------------------------------------------------------
-- doActionAfterInit
-----------------------------------------------------------
function SCB:doActionAfterInit() 

    local free = function()
        self:onFreeSpin()
    end

    local showRes = function(callback)

        self.super.lockUI(self)
        self:enabledSpinBtn(false)
        self.super.showResult(self, callback)
    end
    
    local fr = self.model:getIsFreeSpin()
    local rr = table.nums(self.model:getRoundResult()) ~= 0
    
    local actions = {}

    if rr == true and fr == false then

        local tcallback = function()
        
            local ws = self.model:getWildSteps()
            
            if ws and #ws > 0 then
                self:changeSpinBtn(SCB.BTN_STATE.STEPSPIN)
            else
                self:changeSpinBtn(SCB.BTN_STATE.NORMAL)
            end

            self:enabledSpinBtn(true)
            self:setState(SCB.STATE.ONIDLE)
            self.super.spinCallBack(self)

        end

        actions[#actions+1] = cc.CallFunc:create(
            self:callbackWithArgs(showRes, tcallback))

    elseif rr == true and fr == true then

        actions[#actions+1] = cc.CallFunc:create(
            self:callbackWithArgs(showRes, free))

    elseif rr == false and fr == true then

        actions[#actions+1] = cc.DelayTime:create(1)
        actions[#actions+1] = cc.CallFunc:create(free)

    else
        return
    end

    local sq = transition.sequence(actions)
    self.actionNode:runAction(sq)

end

-----------------------------------------------------------
-- cleanLastSpin
-----------------------------------------------------------
function SCB:cleanLastSpin()
    local stepSpin
    local runTime = 0

    self:setState(SCB.STATE.ONCLEAUP)

    self.model:setDoSpinCk(true)
    self.model:setRewardItems({})
    self.model:setPlayBouble(false)
    self.controlbarView:hideDouble()

    local rdResult = self.model:getRoundResult()
    local wildStepArray = self.model:getWildStepArray()
    local lastRtSpArray = self.model:getLastRtSpArray()

    if table.nums(rdResult) > 0 then
        self:stopPlayLines()
    end
    
    if #wildStepArray >0 then
        if not self.model:isFreeSpin() then
            self:enabledSpinBtn(false)
        end
        local symId = wildStepArray[1]:getSymbolId()
        local logicId = DICT_WILD_REEL[tostring(symId)].logic_id
        runTime, stepSpin = self.wildManager:moveStepSymbol(logicId)
        
    end

    if not stepSpin then
        self.model:setTTWinCoin(0)
        self.controlbarView:setWinCoins(0)
    end

    return runTime

end

-----------------------------------------------------------
-- LockUI
-----------------------------------------------------------
function SCB:lockUI() 

    self.controlbarView.payTableBtn:setButtonEnabled(false)
    self.controlbarView.maxBetBtn:setButtonEnabled(false)
    self.controlbarView.subBetBtn:setButtonEnabled(false)
    self.controlbarView.addBetBtn:setButtonEnabled(false)
    self.controlbarView.doubleBtn:setButtonEnabled(false)

    self.controlbarView.topbar:lockUI()
end

-----------------------------------------------------------
-- UnLockUI
-----------------------------------------------------------
function SCB:unLockUI() 

    self.controlbarView.payTableBtn:setButtonEnabled(true)
    self.controlbarView.maxBetBtn:setButtonEnabled(true)
    self.controlbarView.subBetBtn:setButtonEnabled(true)
    self.controlbarView.addBetBtn:setButtonEnabled(true)
    self.controlbarView.doubleBtn:setButtonEnabled(true)

    self.controlbarView.topbar:unLockUI()
end

-----------------------------------------------------------
-- spinCallBack
-----------------------------------------------------------
function SCB:spinCallBack() 

    if not self.model:isDoSpinCk() then
        return
    end

    --  dataReport:

    -- machineId, 
    -- machineName, 
    -- lineNum, 
    -- spinType, 
    -- costCoins, 
    -- winCoins, 
    -- freeSpinCnt, 
    -- fiveInARow, 
    -- bonusCnt, 
    -- rewardCoins, 
    -- bonusScore

    self.reportModel:spinGame(
        tonumber(self.machineId),
        self.machineName,
        self.used_lines,
        self.spinBtnState,
        self.model:getTTbet(),
        self.model:getTTWinCoin(),
        self.freeSpinCnt,
        self.fiveInARow,
        self.bonusCnt,
        self.bounsWin,
        self.bounsScore
    )

    self.fiveInARow  = 0
    self.freeSpinCnt = 0
    self.bonusCnt    = 0
    self.bounsWin    = 0
    self.bounsScore  = 0

    local btnSt = self.spinBtnState
    
    print("spinCallBack:", btnSt)

    if btnSt == SCB.BTN_STATE.FREESPIN then
        
        self:onFreeSpin()

    elseif btnSt == SCB.BTN_STATE.AUTOSPIN then
    
        self:onAutoSpin()

    elseif btnSt == SCB.BTN_STATE.NORMAL then

        self:unLockUI()
        self:enabledSpinBtn(true)

    elseif btnSt == SCB.BTN_STATE.STEPSPIN then

        self:onStepSpin()
        
    else
        print("st state error")
    end   

end

-----------------------------------------------------------
-- callbackWithArgs
-----------------------------------------------------------
function SCB:callbackWithArgs(callback, args) 
    local ret = function ()
        callback(args)
    end
    return ret
end

-----------------------------------------------------------
-- getNextSyIdx
-----------------------------------------------------------
function SCB:getNextSyIdx(syArray, preIdx) 
    local maxIndex = #(syArray)
    return preIdx >= maxIndex and 1 or (preIdx + 1)
end

-----------------------------------------------------------
-- 
-----------------------------------------------------------
function SCB:runFunWithDelay(node, func, time) 
    local cFunc = cc.CallFunc:create(func)
    local delay = cc.DelayTime:create(time)
    local sequence = cc.Sequence:create(delay, cFunc)
    node:runAction(sequence)
    return sequence   
end

-----------------------------------------------------------
-- enabledSpinBtn
-----------------------------------------------------------
function SCB:enabledSpinBtn( vbool )
    self.spinBtn:setButtonEnabled(vbool)
end

-----------------------------------------------------------
-- checkSpin
-----------------------------------------------------------
function SCB:checkSpin() 

    local betList = self:getBetList()
    local coin = self.userModel:getCoins()

    local function getMaxBet()

        local bet, ttBet, maxBet
        for i=#betList,1,-1 do
            bet = betList[i]
            ttBet = bet * #DICT_MACHINE[
            tostring(self.machineId)].used_lines
            
            if ttBet <= coin then
                maxBet = bet
                break
            end
            
        end

        return maxBet

    end
    
    local ck = function()

        local bet = getMaxBet()

        if bet then
            
            local ttBet = bet * #DICT_MACHINE[
                tostring(self.machineId)].used_lines

            self.model:setBet(bet)
            self.model:setTTbet(ttBet)
            self.controlbarView:updateTTBet(ttBet)

        end

    end

    if not self.model:isFreeSpin() 
        and coin < self.model:getTTbet() then
        local maxBet = getMaxBet()


        scn.ScnMgr.popView("ShortCoinsView", {callback = ck, showContinue = maxBet})
        return false
    end

    return true
end

-----------------------------------------------------------
-- changeSpinBtn
-----------------------------------------------------------
function SCB:changeSpinBtn(btnState)

    local images = self:getBtnImages(btnState)
    self.spinBtn:setButtonImages(images)
    self.spinBtnState = btnState

end

-----------------------------------------------------------
-- getBtnImages
-----------------------------------------------------------
function SCB:getBtnImages(btnState)

    local imgConf
    local btnConf = SCB.BTN_CONFS[btnState]
    local uiTheme = ""--DICT_MAC_RES[tostring(self.machineId)].UITheme

    local reg = ""
    if uiTheme ~= "" then
        reg = "_"..uiTheme
    end

    imgConf = string.gsub(btnConf, "%[UITHEME%]", reg)

    local images = {}

    images.n=string.gsub(imgConf, "%[STATE%]", 'n')
    images.s=string.gsub(imgConf, "%[STATE%]", 's')
    images.d=string.gsub(imgConf, "%[STATE%]", 'd')

    return images

end

-----------------------------------------------------------
-- isPosEqual
-----------------------------------------------------------
function SCB:isPosEqual(matSyA, matSyB)
    local rt = false
    if matSyA:getX() == matSyB:getX() and 
        matSyA:getY() == matSyB:getY() then
        rt = true
    end
    return rt
end

-----------------------------------------------------------
-- loadSpriteFrame
-----------------------------------------------------------
function SCB:loadSpriteFrame()

    local resPath = DICT_MAC_RES[tostring(self.machineId)].pvr
    local plist = string.gsub(resPath, "pvr.ccz", "plist")

    display.addSpriteFrames(plist,resPath)
    
    local fullPath = cc.FileUtils:getInstance():fullPathForFilename(plist)
    local dict = cc.FileUtils:getInstance():getValueMapFromFile(fullPath)

    local spFrame
    for k,v in pairs(dict.frames) do
        print(k)
        spFrame = display.newSpriteFrame(k)
        spFrame:retain()

    end

    for k,btnState in pairs(SCB.BTN_STATE) do
        local images = self:getBtnImages(btnState)

        for s,image in pairs(images) do
            spFrame = display.newSpriteFrame(image)
            spFrame:retain()
        end

    end

end

-----------------------------------------------------------
-- unLoadSpriteFrame
-----------------------------------------------------------
function SCB:unLoadSpriteFrame()

    local resPath = DICT_MAC_RES[tostring(self.machineId)].pvr
    local plist = string.gsub(resPath, "pvr.ccz", "plist")
    
    local fullPath = cc.FileUtils:getInstance():fullPathForFilename(plist)
    local dict = cc.FileUtils:getInstance():getValueMapFromFile(fullPath)

    local spFrame
    for k,v in pairs(dict.frames) do
        print(k)
        spFrame = display.newSpriteFrame(k)
        spFrame:release()

    end

    for k,btnState in pairs(SCB.BTN_STATE) do
        local images = self:getBtnImages(btnState)

        for s,image in pairs(images) do
            spFrame = display.newSpriteFrame(image)
            spFrame:release()
        end

    end

end

-----------------------------------------------------------
-- for auto player line
-----------------------------------------------------------
function SCB:getColSyLayer(col)

    local macType = self.model:getMachineType()
    if macType == SCB.RUND_TYPE.NORMAL then
        return self.model:getColLayerArray()[col]
    end
    return self.machineView:getSyLayer()
end

-----------------------------------------------------------
-- onSavePiggyBank
-----------------------------------------------------------
function SCB:onSavePiggyBank()
    local model = app:getUserModel()

    local level = model:getLevel()
    local info = DICT_LEVEL[tostring(level)]

    local ratio = info.piggy_bank_ratio
    local ttbet = self.model:getTTbet()
    --print("ttbet:",ttbet)
    local coins = math.floor(ttbet/ratio)
    --print("coins:", coins)
    local piggyBank = model:getPiggyBank() + coins
    model:setPiggyBank(piggyBank)

    local fivewan = 50000
    local tenwan = 100000
    local offset = math.floor(piggyBank/tenwan)
    --print("can save to piggyBank for:", offset)
    if piggyBank > fivewan or offset >= 1 then
        local alert = model:getPiggyBankAlert()
        --print("alert:",alert)
        if alert == 0 then
            model:setPiggyBankAlert(1)
            EventMgr:dispatchEvent({name = EventMgr.UPDATE_LOBBYUI_EVENT})
        end
    end
end

-----------------------------------------------------------
-- onSaveTotalgames
-----------------------------------------------------------
function SCB:onSaveHandleExpGameSet()
    local model = app:getObject("UserModel")
    local totalgames = tonumber(model:getTotalgames()) + 1
    model:setTotalgames(totalgames)

    local spincountafterbuy = model:getSpincountafterbuy()
    if spincountafterbuy >= 0 then
        spincountafterbuy = spincountafterbuy + 1
        model:setSpincountafterbuy(spincountafterbuy)
    end

    model:serializeModel()
end

-----------------------------------------------------------
-- 
-----------------------------------------------------------
function SCB:onEnter()

    audio.playMusic(DICT_MAC_RES[tostring(self.machineId)].bgMusic, true)

    app:getObject("ReportModel"):gameEvent(EventMgr.INTER_MACHINE + self.machineId)


    self:onReportScheduler()
end

-----------------------------------------------------------
-- onReportScheduler
-----------------------------------------------------------
function SCB:onReportScheduler() 
    local autoTimer = 0
    self.scEntry = nil
    self.scheduler = require(cc.PACKAGE_NAME .. ".scheduler")

    local autoTicker = function(dt)
        autoTimer = autoTimer + dt 
        if autoTimer > 5 then 
            autoTimer = 0
            app:getObject("ReportModel"):reportDataEveryFiveSeconds()
        end
    end

    self.scEntry = self.scheduler.scheduleGlobal(autoTicker, 0)
end

-----------------------------------------------------------
-- 
-----------------------------------------------------------
function SCB:onExit() 
    audio.stopMusic(true)
    audio.unloadSound(DICT_MAC_RES[tostring(self.machineId)].bgMusic)
    self:unLoadSpriteFrame()

    app:getObject("ReportModel"):gameEvent(EventMgr.EXIT_MACHINE + self.machineId)
    
    if self.scEntry ~= nil then
        self.scheduler.unscheduleGlobal(self.scEntry)
        self.scEntry = nil
    end

    EventMgr:removeEventListenersByEvent(EventMgr.OFFLINE_STOP_SUTOSPIN)
end

function SCB:showChangeBetTip(is_add)
    if self.model:getMachineType() == SCB.RUND_TYPE.NORMAL and table.getn(self.model:getOnHoldWildArray()) > 0 then
        self.is_add = is_add
        local callback = function()
            local onHoldWildArray = self.model:getOnHoldWildArray()
            for k,sy in pairs(onHoldWildArray) do
                local logicId = DICT_WILD_REEL[tostring(sy:getSymbolId())].logic_id
                self.wildManager:setHoldWildsToZero(logicId)
            end
            self:addorsub(self.is_add)
        end
        scn.ScnMgr.popView("BetTipView",{callback = callback})
        return true
    end
end

function SCB:addorsub(is_add)
    local newBet
    local oldBet = self.model:getBet()
    local betList = self:getBetList()
    local lines = #DICT_MACHINE[tostring(self.machineId)].used_lines

    if is_add then
        for i=1, #betList do
            if oldBet == betList[i] then
                if i == #betList then
                    newBet = betList[1]
                else
                    newBet = betList[i+1]
                end
                break
            end
        end
    else
        for i=1, #betList do
            if oldBet == betList[i] then
                if i == 1 then
                    newBet = betList[#betList]
                else
                    newBet = betList[i-1]
                end
                break
            end
        end
    end

    local ttBet = newBet * lines

    self.model:setBet(newBet)
    self.model:setTTbet(ttBet)
    self.controlbarView:updateTTBet(ttBet)
end


function SCB:offlineStopAutospin()
    self.trigerAuto = false
    self:changeSpinBtn(SCB.BTN_STATE.NORMAL)
    self:enabledSpinBtn(true)
    self:unLockUI()
end

return SlotsControllerBase
