
-----------------------------------------------------------
-- SlotsNormalModel 
-----------------------------------------------------------
local ModelBase = require("app.scenes.slots.models.SlotsModelBase")
local SlotsNormalModel = class("SlotsNormalModel", ModelBase)

SlotsNormalModel.schema["colLayerArray"]      = {"table", {}}
SlotsNormalModel.schema["wildStepArray"]      = {"table", {}}
SlotsNormalModel.schema["spinSpeedArray"]     = {"table", {}}
SlotsNormalModel.schema["onHoldWildArray"]    = {"table", {}}

local SNM = SlotsNormalModel

-----------------------------------------------------------
-- Construct:
-----------------------------------------------------------
function SNM:ctor( initData )

    -- print("SNM:ctor")
    
    self.initData = initData
    self.super.ctor(self, initData)
    self:init()

end

-----------------------------------------------------------
-- Init
-----------------------------------------------------------
function SNM:init()
	
end

--================== public get api =======================
-----------------------------------------------------------
-- getSpinSpeedArray
-----------------------------------------------------------
function SNM:getSpinSpeedArray()
    return self.spinSpeedArray_
end

-----------------------------------------------------------
-- getColLayerArray
-----------------------------------------------------------
function SNM:getColLayerArray()
    return self.colLayerArray_
end

-----------------------------------------------------------
-- getOnHoldWildArray
-----------------------------------------------------------
function SNM:getOnHoldWildArray()
	return self.onHoldWildArray_
end

-----------------------------------------------------------
-- getWildStepArray
-----------------------------------------------------------
function SNM:getWildStepArray()
	return self.wildStepArray_
end


--================== public set api =======================
-----------------------------------------------------------
-- setOnHoldWildArray
-----------------------------------------------------------
function SNM:setOnHoldWildArray( tvar )
	self.onHoldWildArray_ = tvar
end

-----------------------------------------------------------
-- setWildStepArray
-----------------------------------------------------------
function SNM:setWildStepArray( tvar )
	self.wildStepArray_ = tvar
end


return SlotsNormalModel
