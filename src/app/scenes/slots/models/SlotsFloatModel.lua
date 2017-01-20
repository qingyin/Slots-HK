
-----------------------------------------------------------
-- SlotsFloatModel 
-----------------------------------------------------------
local ModelBase = require("app.scenes.slots.models.SlotsModelBase")
local SlotsFloatModel = class("SlotsFloatModel", ModelBase)

local SDM = SlotsFloatModel

-----------------------------------------------------------
-- Construct:
-----------------------------------------------------------
function SDM:ctor( initData )
    
    self.initData = initData
    self.super.ctor(self, initData)
    self:init()

end

-----------------------------------------------------------
-- Init
-----------------------------------------------------------
function SDM:init()
	
end


return SlotsFloatModel
