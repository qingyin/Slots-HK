
-----------------------------------------------------------
-- SlotsScene 
-----------------------------------------------------------
local SlotsScene = class("SlotsScene", function()
    return display.newScene("SlotsScene")
end)

SlotsScene.CONTROLLER_MAP 			= {}
SlotsScene.CONTROLLER_MAP.DROP 		= 'SlotsDropController' 
SlotsScene.CONTROLLER_MAP.PUSH 		= 'SlotsPushController'
SlotsScene.CONTROLLER_MAP.FLOAT     = 'SlotsFloatController'
SlotsScene.CONTROLLER_MAP.NORMAL 	= 'SlotsNormalController'

-----------------------------------------------------------
-- @Construct:
-- initData
-----------------------------------------------------------
function SlotsScene:ctor( initData, homeinfo )

	local controllerClass
    local machineId = initData.machineId

    local swithSlots = function(macId)   
        local machineType = DICT_MACHINE[tostring(macId)].machine_type
        return self.CONTROLLER_MAP[machineType]
    end
    
    local controllerName  = swithSlots(initData.machineId)
    controllerClass = require('app.scenes.slots.controllers.'..controllerName)

    self.controller = controllerClass.new(initData, homeinfo)
    self:addChild(self.controller)
    EventMgr:dispatchEvent({name  = EventMgr.UPDATE_TOPBACK_EVENT})
end

-----------------------------------------------------------
-- onEnter
-----------------------------------------------------------
function SlotsScene:onEnter()
    print("SlotsScene:onEnter")
end

-----------------------------------------------------------
-- onExit
-----------------------------------------------------------
function SlotsScene:onExit()

end

return SlotsScene
