
local WildWestWild = class("WildWestWild")
local LiziEff = 'slots/slots_wildwest/effects/effect_cowboylizi.ccbi'
local WSILD = WildWestWild

------------------------------------------
-- Construct
------------------------------------------
function WSILD:ctor( controller )

    local model = controller.model

    self.model = model
    self.ctl = controller
    self.actionNode = controller.actionNode
    
--    self.syLayer = controller.machineView:getSyLayer()
    self.syLayer = controller.machineView:getAnimtionsLayer()

    self.OR = model:getOR()
    self.OV = model:getOV()

    self.macId = model:getMachineId()

    self.cols = (model:getMatrixConf()).cols
    self.rows = (model:getMatrixConf()).rows

    self.lastRtSpArray = model:getLastRtSpArray()
    self.wildStepArray = model:getWildStepArray()
    self.winSymbolsArray = model:getWinSymbolsArray()
    self.onShowSpArray = self.model:getOnShowSpArray()

end

--------------------------------------------------
-- playWild
--------------------------------------------------
function WSILD:playWild( stepWildArray )

    local ctl = self.ctl
    local isNewHold, notLastOne
    local matHoldSy, matStepSy

    local runTime = 0

    local st = ctl.spinBtnState
    local BTNS  = ctl.BTN_STATE

    for j=1, #stepWildArray do

        matStepSy = stepWildArray[j]
        isNewHold = self:dealStepWild(matStepSy)
        
        if isNewHold then
            runTime = self:addStepWild(matStepSy)
        end

        if matStepSy:getX() ~= -1 then
            notLastOne = true
        end

    end

    if st ~= BTNS.STEPSPIN and notLastOne then
        ctl:changeSpinBtn(BTNS.STEPSPIN)
    end

    return runTime
end

----------------------------------------
-- dealStepWild
----------------------------------------
function WSILD:dealStepWild( matStepSy )
    
    local matSy, isEqual
    local isNewHold = true

    for i = #self.wildStepArray, 1, -1 do

        matSy = self.wildStepArray[i]
        isEqual = self.ctl:isPosEqual(matStepSy, matSy)

        if isEqual then
            isNewHold = false
            break
        end

    end
    
    return isNewHold
end

--------------------------------------
-- addStepWild
--------------------------------------
function WSILD:addStepWild( matSy )

    local runTime = 0
    local ctl = self.ctl

    local symbol = SymbolMgr.create(
        matSy:getSymbolId(),
        self.OR.x + matSy:getX()* self.OV.x,
        self.OR.y + matSy:getY()* self.OV.y
    )

    symbol:attachTo(self.syLayer)

    symbol:runAnimationByName('appear')
        
    matSy.symbolObj = symbol
    table.insert(self.wildStepArray, matSy)

    return 18/30
        
end

--------------------------------------
-- setStepSyToColLayer
--------------------------------------
function WSILD:setStepSyToColLayer( matSy )

    local ctl = self.ctl
    local col = matSy:getX()+1
    local row = matSy:getY()+1
                                                                    
    local tmpSy = self.lastRtSpArray[col][row]
    local symbol = SymbolMgr.create(matSy:getSymbolId(), 
        tmpSy:getPositionX(), tmpSy:getPositionY())

    local colLayerArray = self.model:getColLayerArray()

    self.lastRtSpArray[col][row] = symbol
    symbol:attachTo(colLayerArray[col])
    matSy.symbolObj:removeFromParent(false)

    symbol.isLastRt = true
    matSy.symbolObj = symbol
    tmpSy:removeFromParent(false)

end

--------------------------------------
-- moveStepSymbol
--------------------------------------
function WSILD:moveStepSymbol()
    
    local matSy
    local runTime = 0
    local stepSpin = false
    local ctl = self.ctl

    if #self.wildStepArray > 0 then
        stepSpin = true
    end
    
    for i= #self.wildStepArray, 1, -1 do
        
        matSy = self.wildStepArray[i]

        if matSy:getX() == 0 then
            
            self:setStepSyToColLayer(matSy)
            matSy.x = (matSy:getX() - 1)

        else

            local eff = CCBuilderReaderLoad(LiziEff,{})

            eff:setPosition(
                self.OR.x + self.OV.x * matSy:getX(), 
                self.OR.y + self.OV.y * matSy:getY())

            self.syLayer:addChild(eff)

            ctl:runFunWithDelay(self.actionNode, function()
                eff:removeFromParent(true)
            end, 2)


            runTime = 0.5

            local actionMove = cc.MoveTo:create(
                    runTime,
                    cc.p(matSy.symbolObj:getPositionX() - self.OV.x,
                        matSy.symbolObj:getPositionY())
                )

            local action = cc.EaseElasticInOut:create(actionMove, 0.2)

            matSy.symbolObj:runAction(action)
            matSy.symbolObj:runWinAnimation(
                DICT_MAC_RES[tostring(self.macId)].win_animation)

            print("matSy:getX()+1:",matSy:getX()+1,"matSy:getY()+1:", matSy:getY()+1)

            self.lastRtSpArray[matSy:getX()+1][matSy:getY()+1]:setVisible(false)

            matSy.x = (matSy:getX() - 1)

        end

    end

    return runTime, stepSpin

end

---------------------------------------------------
-- prepareInitWildArray
---------------------------------------------------
function WSILD:prepareInitWildArray( holdArray )

    local symbol
    local ctl = self.ctl

    for k,sy in pairs(holdArray) do

        symbol = SymbolMgr.create(
            sy:getSymbolId(),
            self.OR.x + sy:getX()* self.OV.x,
            self.OR.y + sy:getY()* self.OV.y
        )

        sy.symbolObj = symbol
        symbol:attachTo(self.syLayer)
        table.insert(self.wildStepArray, sy)

        symbol:runWinAnimation(
            DICT_MAC_RES[tostring(self.macId)].win_animation)
        
    end

end

---------------------------------------------------
-- initWildSymbol
---------------------------------------------------
function WSILD:initWildSymbol( args )
    return
end

return WildWestWild