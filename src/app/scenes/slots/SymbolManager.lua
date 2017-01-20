
local SymbolManager = class("SymbolManager")

local SYM = require("app.scenes.slots.views.Symbol")

local SYMG = SymbolManager
SYMG.symPool = {}

--------------------------------------
-- createSymbol 
--------------------------------------
function SYMG.create( symId, x, y )

    local resId = DICT_SYMBOL[tostring(symId)].res_id
    local image = DICT_SYM_RES[resId].res_name

    local ccbName = DICT_SYM_RES[resId].ccb

    local symbol = SYMG.getSymbolFromPool( ccbName )

    if not symbol then

        symbol = SYM.new(symId, x, y)
        SYMG.push( symbol )

    else

        symbol:runAnimationByName('idle')

        symbol:setPosition(x, y)

        if image ~= "" then
            local spFrame = display.newSpriteFrame(image)
            symbol:setDisplayFrame(spFrame)

        end
        
        symbol:setScale(1)
        symbol:setVisible(true)
        
    end

    return symbol

end

--------------------------------------
-- newSprite 
--------------------------------------
function SYMG.newSprite( symId, x, y )
    local symbol = {}

    local resId = DICT_SYMBOL[tostring(symId)].res_id
    local image  = DICT_SYM_RES[tostring(resId)].res_name
    
    if image == "" then
        symbol = SYMG.create( symId, x, y )
        return symbol
    end

    symbol.node = display.newSprite('#'..image, x, y)

    function symbol:attachTo(target, zOrder)
        if zOrder then
            target:addChild(self.node, zOrder)
        else
            target:addChild(self.node)
        end
    end

    function symbol:removeFromParent( vbool )
        self.node:removeFromParent()
    end

    function symbol:getPosition()
        return self.node:getPosition()
    end

    function symbol:getPositionY()
        return self.node:getPositionY()
    end

    function symbol:getPositionX()
        return self.node:getPositionX()
    end

    function symbol:setPositionX( intX )
        self.node:setPositionX( intX )
    end

    function symbol:setPositionY( intY )
        self.node:setPositionY( intY )
    end

    function symbol:setReelIndex( index )
        self.reelIndex = index
    end

    function symbol:getReelIndex()
        return self.reelIndex
    end

    function symbol:setVisible( vbool )
        self.node:setVisible(vbool)
    end

    return symbol
end

--------------------------------------
-- release 
--------------------------------------
function SYMG.release()

    local symbol
    local symbols = {}
    for name, syms in pairs(SYMG.symPool) do
        symbols = syms
        for i=1,#symbols do
            symbol = symbols[i]

            symbol.rootNode:removeFromParent()
            symbol.nodeLayer:removeFromParent()

            symbol = nil
        end
    end
    
    SYMG.symPool = {}

end

--------------------------------------
-- getSymbolFromPool 
--------------------------------------
function SYMG.getSymbolFromPool( ccbName )
    local symbol
    local symbols = {}
    for name, syms in pairs(SYMG.symPool) do
        if name == ccbName  then
            symbols = syms
            break
        end
    end

    for i=1,#symbols do
        if not symbols[i].inUse then
            symbol = symbols[i]
            break
        end
    end

    return symbol
end

--------------------------------------
-- push 
--------------------------------------
function SYMG.push( symbol )

    local symbols = {}
    for name, syms in pairs(SYMG.symPool) do
        if name == symbol.ccbName  then
            symbols = syms
            break
        end
    end

    if #symbols == 0 then
        SYMG.symPool[symbol.ccbName] = symbols
    end

    table.insert(symbols, symbol)

end


return SYMG