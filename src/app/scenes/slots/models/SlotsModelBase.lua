
-----------------------------------------------------------
-- SlotsModelBase 
-----------------------------------------------------------
local SlotsModelBase = class("SlotsModelBase", cc.mvc.ModelBase)

-- private
SlotsModelBase.schema                   	= clone(cc.mvc.ModelBase.schema)

SlotsModelBase.schema["machineType"]		= {"string"}

SlotsModelBase.schema["bet"]           		= {"number", 0}
SlotsModelBase.schema["totalBet"]       	= {"number", 0}
SlotsModelBase.schema["ttWinCoin"]       	= {"number", 0}
SlotsModelBase.schema["frWinCoin"]       	= {"number", 0}
SlotsModelBase.schema["machineId"]      	= {"number", 0}
SlotsModelBase.schema["frWinCoin"]    	    = {"number", 0}
SlotsModelBase.schema["frSpinCount"]  	    = {"number", 0}

SlotsModelBase.schema["reels"]		 		= {"table", {}}
SlotsModelBase.schema["origin"] 		 	= {"table", {}}
SlotsModelBase.schema["matrixConf"]         = {"table", {}}
SlotsModelBase.schema["rewardItems"] 		= {"table", {}}
SlotsModelBase.schema["roundResult"] 		= {"table", {}}
SlotsModelBase.schema["usedbstItem"] 		= {"table", {}} 
SlotsModelBase.schema["originVector"] 		= {"table", {}}

SlotsModelBase.schema["effArray"] 			= {"table", {}}
SlotsModelBase.schema["onShowSpArray"] 		= {"table", {}}
SlotsModelBase.schema["lineNodeArray"] 		= {"table", {}}
SlotsModelBase.schema["lastRtSpArray"] 	    = {"table", {}}
SlotsModelBase.schema["onShowLineArray"] 	= {"table", {}}
SlotsModelBase.schema["winSymbolsArray"]    = {"table", {}}

SlotsModelBase.schema["isLastNode"] 		= {"boolean", false}
SlotsModelBase.schema["isFreeSpin"] 		= {"boolean", false}
SlotsModelBase.schema["isDoSpinCk"] 		= {"boolean", false}
SlotsModelBase.schema["isFiveinRows"] 		= {"boolean", false}
SlotsModelBase.schema["hasPlayBouble"] 		= {"boolean", false}

local SMB = SlotsModelBase

-----------------------------------------------------------
-- @Construct:
-- initDataTpl.frWinCoin      = 0
-- initDataTpl.ttWinCoin      = 0
-- initDataTpl.machineId      = 0
-- initDataTpl.usedbstItem    = 0
-- initDataTpl.roundResult    = {}
-- initDataTpl.isDoSpinCk     = true
-- initDataTpl.isFreeSpin     = false
-- initDataTpl.hasPlayBouble  = false 
-----------------------------------------------------------
function SMB:ctor( initData )
    
    -- print("SMB:ctor")

    self.super.super.ctor(self)

    self.machineId_ 	= initData.machineId
    self.frWinCoin_ 	= initData.frWinCoin
    self.ttWinCoin_ 	= initData.ttWinCoin
    self.isDoSpinCk_  	= initData.isDoSpinCk
    self.isFreeSpin_  	= initData.isFreeSpin
    self.usedbstItem_ 	= initData.usedbstItem
    self.roundResult_ 	= initData.roundResult
    self.hasPlayBouble_ = initData.hasPlayBouble

    self.super.init(self)

end

-----------------------------------------------------------
-- Init
-----------------------------------------------------------
function SMB:init()
	
	self.bet_ = tonumber(self:getBetConf().default)--2--User.getProperty(User.KEY_LASTBET)
    self.totalBet_ = self.bet_ * #DICT_MACHINE[tostring(self.machineId_)].used_lines
    self.matrixConf_.rows = tonumber(DICT_MACHINE[tostring(self.machineId_)].max_row)
    self.matrixConf_.cols = tonumber(DICT_MACHINE[tostring(self.machineId_)].reel_size)
    self.reels_ = DICT_MACHINE[tostring(self.machineId_)].reels

    for col=1, self.matrixConf_.cols do
        self.onShowSpArray_[col]  = {}
    end

end


-----------------------------------------------------------
-- pushInitData
-----------------------------------------------------------
function SMB:pushInitData( args )	

	local initData = SlotsMgr:buildInitData()

	initData.frWinCoin       = self.frWinCoin_
    initData.ttWinCoin       = self.ttWinCoin_
    initData.machineId       = self.machineId_
    initData.isDoSpinCk      = self.isDoSpinCk_
    initData.isFreeSpin      = self.isFreeSpin_
    initData.usedbstItem     = self.usedbstItem_
    initData.roundResult     = self.roundResult_
    initData.frSpinCount     = self.frSpinCount_
    initData.hasPlayBouble   = self.hasPlayBouble_

    if args then
    	for k,v in pairs(args) do
    		initData[k] = v
    	end
    end

	SlotsMgr.pushInitData(initData)

end

-----------------------------------------------------------
-- upReelsForFreeSpin
-----------------------------------------------------------
function SMB:upReelsForFreeSpin()
    local machineId = DICT_MACHINE[tostring(self.machineId_)].f_machine_id
    self.reels_ = DICT_MACHINE[tostring(machineId)].reels
end

-----------------------------------------------------------
-- upReelsForBaseSpin
-----------------------------------------------------------
function SMB:upReelsForBaseSpin()
    self.reels_ = DICT_MACHINE[tostring(self.machineId_)].reels
end

--================== public get api =======================
-----------------------------------------------------------
-- getMachineId
-----------------------------------------------------------
function SMB:getMachineId()
	return self.machineId_
end

-----------------------------------------------------------
-- getBet
-----------------------------------------------------------
function SMB:getBet()
	return self.bet_
end

-----------------------------------------------------------
-- getTTbet
-----------------------------------------------------------
function SMB:getTTbet()
    return self.totalBet_
end

-----------------------------------------------------------
-- getUsedBoost
-----------------------------------------------------------
function SMB:getUsedBoost()
	return self.usedbstItem_
end

-----------------------------------------------------------
-- getHoldWilds
-----------------------------------------------------------
function SMB:getHoldWilds()
	return self.onHoldWildArray_
end

-----------------------------------------------------------
-- getWildSteps
-----------------------------------------------------------
function SMB:getWildSteps()
    return self.wildStepArray_
end

-----------------------------------------------------------
-- getRoundResult
-----------------------------------------------------------
function SMB:getRoundResult()
	return self.roundResult_
end

-----------------------------------------------------------
-- getMachineType
-----------------------------------------------------------
function SMB:getMachineType()
	return self.machineType_
end

-----------------------------------------------------------
-- getIsFreeSpin
-----------------------------------------------------------
function SMB:getIsFreeSpin()
    return self.isFreeSpin_
end

-----------------------------------------------------------
-- getOR
-----------------------------------------------------------
function SMB:getOR()
    return self.origin_
end

-----------------------------------------------------------
-- getOV
-----------------------------------------------------------
function SMB:getOV()
    return self.originVector_
end

-----------------------------------------------------------
-- getReels
-----------------------------------------------------------
function SMB:getReels()
    return self.reels_
end

-----------------------------------------------------------
-- getOnShowSpArray
-----------------------------------------------------------
function SMB:getOnShowSpArray()
    return self.onShowSpArray_
end

-----------------------------------------------------------
-- getLastRtSpArray
-----------------------------------------------------------
function SMB:getLastRtSpArray()
    return self.lastRtSpArray_
end

-----------------------------------------------------------
-- getWinSymbolsArray
-----------------------------------------------------------
function SMB:getWinSymbolsArray()
    return self.winSymbolsArray_
end

-----------------------------------------------------------
-- getMatrixConf
-----------------------------------------------------------
function SMB:getMatrixConf()
    return self.matrixConf_
end

-----------------------------------------------------------
-- getFrSpinCount
-----------------------------------------------------------
function SMB:getFrSpinCount()
    return self.frSpinCount_
end

-----------------------------------------------------------
-- getTTWinCoin
-----------------------------------------------------------
function SMB:getTTWinCoin()
    return self.ttWinCoin_
end

-----------------------------------------------------------
-- isFreeSpin
-----------------------------------------------------------
function SMB:isFreeSpin()
    return self.isFreeSpin_
end

-----------------------------------------------------------
-- hasPlayBouble
-----------------------------------------------------------
function SMB:hasPlayBouble()
    return self.hasPlayBouble_
end

-----------------------------------------------------------
-- getBetConf
-----------------------------------------------------------
function SMB:getBetConf()
	local betList = getBetList(app:getUserModel():getLevel())
    return betList
end

-----------------------------------------------------------
-- hasPlayBouble
-----------------------------------------------------------
function SMB:hasPlayBouble()
    return self.hasPlayBouble_
end

-----------------------------------------------------------
-- isDoSpinCk
-----------------------------------------------------------
function SMB:isDoSpinCk()
    return self.isDoSpinCk_
end


-----------------------------------------------------------
-- getFrCoins
-----------------------------------------------------------
function SMB:getFrCoins()
    return self.frWinCoin_
end

-----------------------------------------------------------
-- getEffArray
-----------------------------------------------------------
function SMB:getEffArray()
    return self.effArray_
end

-----------------------------------------------------------
-- getRewardItems
-----------------------------------------------------------
function SMB:getRewardItems()
    return self.rewardItems_
end

--================== public set api =======================

-----------------------------------------------------------
-- setDoSpinCk
-----------------------------------------------------------
function SMB:setDoSpinCk( vbool )
    self.isDoSpinCk_ = vbool
end

-----------------------------------------------------------
-- getMachineType
-----------------------------------------------------------
function SMB:setMachineType( typ )
    self.machineType_ = typ
end

-----------------------------------------------------------
-- setFrSpinCount
-----------------------------------------------------------
function SMB:setFrSpinCount( var )
    self.frSpinCount_ = var
end

-----------------------------------------------------------
-- setRoundResult
-----------------------------------------------------------
function SMB:setRoundResult( rds )
 	self.roundResult_ = rds
end 

-----------------------------------------------------------
-- setLastRtSpArray
-----------------------------------------------------------
function SMB:setLastRtSpArray( vtb )
    self.lastRtSpArray_ = vtb
end 


-----------------------------------------------------------
-- setOrigin
-----------------------------------------------------------
function SMB:setOrigin( x, y )
    self.origin_.x = x
    self.origin_.y = y
end 

-----------------------------------------------------------
-- setOriginVector
-----------------------------------------------------------
function SMB:setOriginVector( x, y )
    self.originVector_.x = x
    self.originVector_.y = y
end 

-----------------------------------------------------------
-- setTTWinCoin
-----------------------------------------------------------
function SMB:setTTWinCoin( var )
    self.ttWinCoin_ = var
end

-----------------------------------------------------------
-- setFreeSpin
-----------------------------------------------------------
function SMB:setFreeSpin( vbool )
    self.isFreeSpin_ = vbool
end

-----------------------------------------------------------
-- setPlayBouble
-----------------------------------------------------------
function SMB:setPlayBouble( vbool )
    self.hasPlayBouble_ = vbool
end

-----------------------------------------------------------
-- setBet
-----------------------------------------------------------
function SMB:setBet( var )
    self.bet_ = var
end

-----------------------------------------------------------
-- setTTbet
-----------------------------------------------------------
function SMB:setTTbet( var )
    self.totalBet_ = var
end

-----------------------------------------------------------
-- setFrCoins
-----------------------------------------------------------
function SMB:setFrCoins( var )
    self.frWinCoin_ = var
end

-----------------------------------------------------------
-- setOnShowSpArray
-----------------------------------------------------------
function SMB:setOnShowSpArray( vt )
    self.onShowSpArray_ = vt
end

-----------------------------------------------------------
-- setRewardItems
-----------------------------------------------------------
function SMB:setRewardItems( vt )
    self.rewardItems_ = vt
end


return SlotsModelBase
