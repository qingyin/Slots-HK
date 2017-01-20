local WildGreekGods = class("WildGreekGods")
local wildEffccb = 'slots/slots_greek/effects/slots_greek_lightning.ccbi'

--------------------------------------
-- Construct
--------------------------------------
function WildGreekGods:ctor( controller )

    local model = controller.model

    self.model = model
    self.ctl = controller
    self.actionNode = display.newNode()

    controller:addChild(self.actionNode)
    
    self.machineView = controller.machineView
    
    self.OR = model:getOR()
    self.OV = model:getOV()

    self.macId = model:getMachineId()

    self.cols = (model:getMatrixConf()).cols
    self.rows = (model:getMatrixConf()).rows


end

---------------------------------------------------
-- wildreObj: from roundResult
---------------------------------------------------
function WildGreekGods:playWild( wildreObj )

    local lightTime = 1
    local showGodTime = 1

    local scrSyb, reSyb, symbol

    reSyb = wildreObj.replaceSymbols
    scrSyb = wildreObj.sourceSymbol

    local lastRtSpArray = self.model:getLastRtSpArray()

    symbol = lastRtSpArray[scrSyb:getX()+1][scrSyb:getY()+1]

    symbol:runAnimationByName('scale')

    local function playLightning()
        for reIndex,matrixSymbol in pairs(reSyb) do
            self:playEffect(matrixSymbol, lightTime)
        end
    end

    self.ctl:runFunWithDelay(self.actionNode,function() 
         -- symbol:setGlobalZOrder(0)
        symbol:attachToNewNode(self.ctl:getColSyLayer(scrSyb:getX()+1))
        self.machineView:hideGreyLayer() 
        end, showGodTime+lightTime)

    -- symbol:setGlobalZOrder(0)
    symbol:attachToNewNode(self.machineView:getAnimtionsLayer())
    self.machineView:showGreyLayer()

    self.ctl:runFunWithDelay(self.actionNode, playLightning, showGodTime )

    return showGodTime + lightTime

end

---------------------------------------------------
-- playEffect
---------------------------------------------------
function WildGreekGods:playEffect( matrixSymbol, lightTime )

    local ctl = self.ctl
    local row = matrixSymbol:getY() + 1
    local col = matrixSymbol:getX() + 1

    local onShowSpArray = self.model:getOnShowSpArray()
    local lastRtSpArray = self.model:getLastRtSpArray()
    local winSymbolsArray = self.model:getWinSymbolsArray()

    local sp = lastRtSpArray[col][row]
    local x,y = sp:getPositionX(), sp:getPositionY()

    local reSp = SymbolMgr.create(
        matrixSymbol:getSymbolId(), x, y)

    reSp.isLastRt = true
    lastRtSpArray[col][row] = reSp
    winSymbolsArray[col][row] = reSp

    for row_=1, #onShowSpArray[col] do
        if onShowSpArray[col][row_] == sp then
            onShowSpArray[col][row_] = reSp
            break
        end
    end

    local colLayerArray = self.model:getColLayerArray()
        
    reSp:attachTo(colLayerArray[col])
    reSp:setVisible(false)


    local eff = CCBuilderReaderLoad(wildEffccb,{})

    SlotsMgr.setAllChildrensZorder(eff, 2)

    local point = sp:getWorldPosition()
    eff:setPosition( point.x, point.y )

    self.machineView:addChild(eff)

    local showFun = function(args)

        -- reSp:setGlobalZOrder(0)
        reSp:attachToNewNode(colLayerArray[col])
        eff:removeFromParent()
        eff = nil 
            
    end

    ctl:runFunWithDelay(self.actionNode, function()
        reSp:setVisible(true)
        reSp:attachToNewNode(self.machineView:getAnimtionsLayer())
        -- reSp:setGlobalZOrder(0)
        sp:removeFromParent(false)  
    end, lightTime - 0.5 )

    ctl:runFunWithDelay(self.actionNode, showFun, lightTime)

end

return WildGreekGods
