
local WildSpaceWar = class("WildSpaceWar")
local WUS = WildSpaceWar

local befEff = 'slots/slots_03/animations/slots_03_before.ccbi'
local aftEff = 'slots/slots_03/animations/slots_03_after.ccbi'

--------------------------------------
-- Construct
--------------------------------------
function WUS:ctor( controller )
    
    local model = controller.model

    self.model = model
    self.ctl = controller
    self.actionNode = controller.actionNode
    
    self.machineView = controller.machineView
    
    self.OR = model:getOR()
    self.OV = model:getOV()

    self.macId = model:getMachineId()

    self.cols = (model:getMatrixConf()).cols
    self.rows = (model:getMatrixConf()).rows

end

--------------------------------------
-- playWild
--------------------------------------
function WUS:playWild( wildreObj )

    local ttRunTime = 0
    local ctl = self.ctl
    local scSyb = wildreObj.sourceSymbol
    local reSyb = wildreObj.replaceSymbols


    local playBeforeEffTime = 18/30
    local playAfterEffTime = 1 + 26/30

    local syLayer = ctl.machineView:getSyLayer()

    local onShowSpArray = self.model:getOnShowSpArray()
    local winSymbolsArray = self.model:getWinSymbolsArray()
    
    local function playAfterEff()

        local row,col,sp
        for reIndex,matrixSymbol in pairs(reSyb) do
            row = matrixSymbol:getY() + 1
            col = matrixSymbol:getX() + 1

            sp = onShowSpArray[col][row]
            sp:removeFromParent(false)

        end


        local eff = CCBuilderReaderLoad(aftEff,{})

        local px = scSyb:getX()

        local point = {
            x = self.OR.x + self.OV.x * px,
            y = self.OR.y + self.OV.y * 1
        }

        eff:setPosition( point.x, point.y )
        syLayer:addChild(eff,10)

        local func = function()
            eff:removeFromParent(true)
        end

        ctl:runFunWithDelay(self.actionNode, func, playAfterEffTime)

    end

    local function replaceSymbol()
        
        local row, col, sp
        for reIndex,matrixSymbol in pairs(reSyb) do
            row = matrixSymbol:getY() + 1
            col = matrixSymbol:getX() + 1

            sp = onShowSpArray[col][row]
            sp = SymbolMgr.create( matrixSymbol:getSymbolId(), 
                self.OR.x + self.OV.x * (col - 1), 
                self.OR.y + self.OV.y * (row - 1))

            sp.isLastRt = true
            sp:attachTo(syLayer, 9)
            onShowSpArray[col][row] = sp
            winSymbolsArray[col][row] = sp

        end

    end

    local function playBeforeEff()
        local eff = CCBuilderReaderLoad(befEff, {})
        
        local px = scSyb:getX()
        local py = scSyb:getY()

        local point = {
            x = self.OR.x + self.OV.x * px,
            y = self.OR.y + self.OV.y * py
        }

        eff:setPosition( point.x, point.y )
        syLayer:addChild(eff,11)

        local func = function()
            eff:stopAllActions()
            eff:removeFromParent(true)
            eff = nil
        end

        ctl:runFunWithDelay(self.actionNode, func, playBeforeEffTime)

    end

    local function playWild()
        ctl:runFunWithDelay(self.actionNode, playBeforeEff, 0.2 )  
        ctl:runFunWithDelay(self.actionNode, playAfterEff, playBeforeEffTime + 0.2 )        
        ctl:runFunWithDelay(self.actionNode, replaceSymbol, playBeforeEffTime + playAfterEffTime - 1)
    end

    playWild()
    
    return ttRunTime + playBeforeEffTime + playAfterEffTime + 0.2

end

return WildSpaceWar