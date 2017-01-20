
-----------------------------------------------------------
-- LineView 
-----------------------------------------------------------
local LineView = class("LineView", function()
    return display.newLayer()
end)

-----------------------------------------------------------
-- Construct 
-- args.machineId
-----------------------------------------------------------
function LineView:ctor(args) 

    self.onShowLineArray = {}
    self.machineId = args.machineId

    local lineCcbi = DICT_MAC_RES[tostring(self.machineId)].line_ccb

    self.lineFadeTime = tonumber( DICT_MAC_RES[
        tostring(self.machineId)].line_fade_time )

    self.line = CCBuilderReaderLoad(lineCcbi, self)
    self:addChild(self.line)
    self:init()

    self:setNodeEventEnabled(true)

end

-----------------------------------------------------------
-- Init 
-----------------------------------------------------------
function LineView:init()
    local lineId, colorId , lineSp
    for id, detail in pairs(DICT_LINE_COLOR) do
        id = tonumber(id)
        if id >= self.machineId * 1000 and 
            id <= (self.machineId + 1) * 1000 then
            
            lineId  = detail.line
            colorId = detail.color
            lineSp  = self['lineNode'..lineId]


            local childrens = lineSp:getChildren()
            for i=1, table.getn(childrens) do
                
                childrens[i]:setOpacity(DICT_COLOR[colorId].Opacity)
                childrens[i]:setColor(cc.c3b(
                        tonumber(DICT_COLOR[colorId].R), 
                        tonumber(DICT_COLOR[colorId].G), 
                        tonumber(DICT_COLOR[colorId].B)))
            end
        end
    end
end

-----------------------------------------------------------
-- ShowLine
-----------------------------------------------------------
function LineView:showLine(lineId)
    
    local lname = 'lineNode'..
        DICT_LINE[tostring(lineId)].no

    self.onShowLineArray[lineId] = true
    self[lname]:setVisible(true)

end

-----------------------------------------------------------
-- HideAllLines
-----------------------------------------------------------
function LineView:hideAllLines()

    for lineId, isOnShow in 
        pairs(self.onShowLineArray) do
        if isOnShow then
            self:hideLineById(lineId)
        end
    end

end

-----------------------------------------------------------
-- HideLineById
-----------------------------------------------------------
function LineView:hideLineById(lineId)

    local lname = 'lineNode'..
        DICT_LINE[tostring(lineId)].no
        
    local nodeObj = self[lname]
    nodeObj:setVisible(false)

    local childrens = nodeObj:getChildren()
    for i=1, table.getn(childrens) do
        childrens[i]:stopAllActions()
    end

    self.onShowLineArray[lineId] = false

end


-----------------------------------------------------------
-- BlinkLineById
-----------------------------------------------------------
function LineView:blinkLineById(lineId)

    local runTime = self.lineFadeTime
    local nodeName = "lineNode"..
        DICT_LINE[tostring(lineId)].no

    local target = self[nodeName]
    local childrens = target:getChildren()

    local fadeOut = function(onComplete)
        local callback
        for i=1, table.getn(childrens) do

            if i == table.getn(childrens) then
                callback = onComplete
            end

            transition.fadeOut(
            childrens[i],
            {
                time = runTime,
                onComplete = callback
            }
        )
        end     
    end

    local fadeIn  = function(onComplete)
        local callback
        for i=1, table.getn(childrens) do

            if i == table.getn(childrens) then
                callback = onComplete
            end

            transition.fadeIn(
            childrens[i],
            {
                time = runTime,
                onComplete = callback
            }
        )
        end     
    end

    local getCallback
    local fadeTime, blinkTime = 0, 10
    
    getCallback = function(isFadeOut)
        fadeTime = fadeTime + 1
        if fadeTime >= blinkTime * 2 then
            return nil
        end

        local callback

        if isFadeOut then
            fadeIn( function() getCallback(false) end ) 
        else
            fadeOut( function() getCallback(true) end ) 
        end 
    end

    fadeOut(function() getCallback(true) end)

end

-----------------------------------------------------------
-- onExit 
-----------------------------------------------------------
function LineView:onExit()

end

-----------------------------------------------------------
-- containPos
-----------------------------------------------------------
function LineView:containPos(lineId,x,y)
    local coordinate = DICT_LINE[tostring(lineId)].coordinate
    local isOnLine = false
    for _,pos in pairs(coordinate) do
        if tonumber(pos.x) == tonumber(x) and tonumber(pos.y) == tonumber(y) then
            isOnLine = true
            break
        end
    end
    return isOnLine
end

return LineView
