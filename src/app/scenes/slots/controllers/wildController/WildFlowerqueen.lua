local WildFlowerqueen = class("WildFlowerqueen")
local WFQ = WildFlowerqueen

--------------------------------------
-- Construct
--------------------------------------
function WFQ:ctor( controller )
    
    self.moveSpeed = 200

    local model = controller.model

    self.model = model
    self.ctl = controller
    self.actionNode = controller.actionNode
    
    self.syLayer = controller.machineView:getSyLayer()
    
    self.OR = model:getOR()
    self.OV = model:getOV()

    self.macId = model:getMachineId()

    self.cols = (model:getMatrixConf()).cols
    self.rows = (model:getMatrixConf()).rows

    self.lastRtSpArray = model:getLastRtSpArray()
    self.winSymbolsArray = model:getWinSymbolsArray()
    self.onShoWFQArray = self.model:getOnShoWFQArray()

end

---------------------------------------------------
-- serialWildArray: from roundResult
---------------------------------------------------
function WFQ:playWild( serialWildArray )

    local runTime = 0
    local ctl = self.ctl

    local reelId, tmpTime
    local moveFlag, moveDis

    local middleSymbol
    local colLayerArray = self.model:getColLayerArray()
    
    for k,serialWild in pairs(serialWildArray) do
        
        reelId   = serialWild:getReelIdx()
        moveDis  = #serialWild:getMoveSymbos()
        moveFlag = serialWild:getMoveDirection()
        moveDis  = moveDis * self.OV.y

        middleSymbol = serialWild:getMiddleSymbol()

        if moveDis > 0 then

            local colLayer = colLayerArray[reelId]
            tmpTime = moveDis/self.moveSpeed

            moveDis = moveFlag == 1 and (- moveDis) or moveDis
            moveDis = colLayer:getPositionY() + moveDis

            self:moveTo(colLayer,moveDis,tmpTime)

            if tmpTime > runTime then
                runTime = tmpTime
            end

            local tempArray = {}
            local tempIndex = #self.onShoWFQArray[reelId] - self.rows - 2
            for i=1, self.rows + 3 do
                tempArray[i] = self.onShoWFQArray[reelId][tempIndex]
                tempIndex = tempIndex + 1
            end

            for i=1, #self.winSymbolsArray[reelId] do
                local index_ = i + 2 + moveFlag * (#serialWild:getMoveSymbos())
                self.winSymbolsArray[reelId][i] = tempArray[index_]
            end

        end


        local tmpSymbol = self.winSymbolsArray[reelId][middleSymbol:getY()+1]
        self.winSymbolsArray[reelId][middleSymbol:getY()+2] = tmpSymbol
        self.winSymbolsArray[reelId][middleSymbol:getY()] = tmpSymbol

    end

    return runTime

end

--------------------------------------
-- MoveTo
--------------------------------------
function WFQ:moveTo( node, posY , time )

    local posX = node:getPositionX()
    local actionMv = cc.MoveTo:create(time, cc.p(posX, posY))
    node:runAction(actionMv)

end

----------------------------------------------
-- initWildSymbol
----------------------------------------------
function WFQ:initWildSymbol( holdArray )

end

-----------------------------------------------------
-- prepareInitWildArray 
-----------------------------------------------------
function WFQ:prepareInitWildArray( serialWildArray )

    local reelId,tmpSymbol
    local ctl = self.ctl
    
    for k,serialWild in pairs(serialWildArray) do

        reelId = serialWild:getReelIdx()
        middleSymbol = serialWild:getMiddleSymbol()

        local tmpSymbol = self.winSymbolsArray[reelId][middleSymbol:getY()+1]
        self.winSymbolsArray[reelId][middleSymbol:getY()+2] = tmpSymbol
        self.winSymbolsArray[reelId][middleSymbol:getY()] = tmpSymbol

    end
end


return WildFlowerqueen