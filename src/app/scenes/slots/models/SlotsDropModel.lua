
-----------------------------------------------------------
-- SlotsDropModel 
-----------------------------------------------------------
local ModelBase = require("app.scenes.slots.models.SlotsModelBase")
local SlotsDropModel = class("SlotsDropModel", ModelBase)

SlotsDropModel.schema["initRound"]      	= {"number", 0}
SlotsDropModel.schema["rmSymbolArray"]    	= {"table", {}}


local SDM = SlotsDropModel

-----------------------------------------------------------
-- Construct:
-----------------------------------------------------------
function SDM:ctor( initData )
    
    self.initData = initData
    self.super.ctor(self, initData)
    self:init(initData)

end

-----------------------------------------------------------
-- Init
-----------------------------------------------------------
function SDM:init(initData)
	self:setInitRound(initData.initRound)
end

-----------------------------------------------------------
-- pushInitData
-----------------------------------------------------------
function SDM:pushInitData()	
	local args = {initRound = self.initRound_}
	self.super.pushInitData(self, args)
end

--================== public get api =======================
-----------------------------------------------------------
-- getInitRound
-----------------------------------------------------------
function SDM:getInitRound()
    return self.initRound_
end

-----------------------------------------------------------
-- getRmSymbolArray
-----------------------------------------------------------
function SDM:getRmSymbolArray()
	return self.rmSymbolArray_
end


--================== public set api =======================
-----------------------------------------------------------
-- setInitRound
-----------------------------------------------------------
function SDM:setInitRound( var )
	self.initRound_ = var
end

-----------------------------------------------------------
-- setRmSymbolArray
-----------------------------------------------------------
function SDM:setRmSymbolArray( vt )
	self.rmSymbolArray_ = vt
end


return SlotsDropModel
