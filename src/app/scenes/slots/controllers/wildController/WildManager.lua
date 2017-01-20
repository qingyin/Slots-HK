
local WildManager = class("WildManager")

local WildEgypt         = require("app.scenes.slots.controllers.wildController.WildEgypt")
local WildGreekGods     = require("app.scenes.slots.controllers.wildController.WildGreekGods")
local WildWestWild      = require("app.scenes.slots.controllers.wildController.WildWestWild")
local WildSerialPirate  = require("app.scenes.slots.controllers.wildController.WildSerialPirate")
local WildSpaceWar      = require("app.scenes.slots.controllers.wildController.WildSpaceWar")
local WildFlowerqueen   = require("app.scenes.slots.controllers.wildController.WildFlowerqueen")
local WildMagicbeans    = require("app.scenes.slots.controllers.wildController.WildMagicbeans")

local LogicMap = {
    ['2000'] = WildGreekGods,
    ['2001'] = WildEgypt,
    ['2003'] = WildWestWild,
    ['2004'] = WildSerialPirate,
    ['2005'] = WildFlowerqueen,
    ['2006'] = WildMagicbeans,
    ['1030'] = WildSpaceWar,
}

local SerialLogicIds = {
    ['2004'] = true,
    ['2005'] = true
}


----------------------------------------
-- Construct
----------------------------------------
function WildManager:ctor( controller )
    
    self.logicEntry = nil
    self.controller = controller

end

function WildManager:getLogicEntry( logicId )

    if not self.logicEntry then
        self.logicEntry = LogicMap[logicId].new(self.controller)
    end

    return self.logicEntry

end

-----------------------------------------------------
-- playWild
-----------------------------------------------------
function WildManager:playWild( logicId, args )
    return self:getLogicEntry(logicId):playWild( args )
end

------------------------------------------------------
-- moveStepSymbol
------------------------------------------------------
function WildManager:moveStepSymbol( logicId )
    return self:getLogicEntry(logicId):moveStepSymbol()
end

-------------------------------------------------------------------
-- prepareInitWildArray
-------------------------------------------------------------------
function WildManager:prepareInitWildArray( logicId, args )
    return self:getLogicEntry(logicId):prepareInitWildArray(args)
end

-------------------------------------------------------------------
-- initWildSymbol
-------------------------------------------------------------------
function WildManager:initWildSymbol( logicId, args )
    return self:getLogicEntry(logicId):initWildSymbol(args)
end

-------------------------------------------------------------------
-- setHoldWildsToZero
-------------------------------------------------------------------
function WildManager:setHoldWildsToZero( logicId, args )
    return self:getLogicEntry(logicId):setHoldWildsToZero(args)
end

-------------------------------------------------------------------
-- hasSerialLogic
-------------------------------------------------------------------
function WildManager:hasSerialLogic( machinId )
    
    local rt = false
    local logicIds = {}
    local usedSymbols = DICT_MACHINE[tostring(machinId)].used_symbols

    local symId, logicId
    for i=1, #usedSymbols do
        symId = usedSymbols[i]
        if DICT_WILD_REEL[tostring(symId)] then
            logicId = DICT_WILD_REEL[tostring(symId)].logic_id
            if SerialLogicIds[logicId] then
                rt = true
                break
            end
        end
    end

    return rt

end


return WildManager

