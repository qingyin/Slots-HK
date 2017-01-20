
--[[--
ReportModel Class
]]

require "app.interface.pb.DataReport_pb"
require "app.interface.pb.CasinoMessageType"

local ReportModel = class("ReportModel", require("app.data.SerializeModel"))

ReportModel.needreport              = "needreport"
ReportModel.udid                    = "udid"
-- ReportModel.serialNo                = "serialNo"


ReportModel.accountInfo             = "accountInfo"
ReportModel.timestamp               = "timestamp"

ReportModel.curGameReport           = "curGameReport"
ReportModel.waitGameReport          = "waitGameReport"

ReportModel.curEventReport           = "curEventReport"
ReportModel.waitEventReport          = "waitEventReport"

ReportModel.rga = {
    spinList                        = "spinList",
    doubleGameList                  = "doubleGameList",
    levelUpList                     = "levelUpList",
    eventList                       = "eventList",
}

ReportModel.spinkey = {
    machineId                        = "machineId",
    machineName                      = "machineName",
    lineNum                          = "lineNum",
    spinType                         = "spinType",
    costCoins                        = "costCoins",
    winCoins                         = "winCoins",
    freeSpinCnt                      = "freeSpinCnt",
    fiveInARow                       = "fiveInARow",
    bonusCnt                         = "bonusCnt",
    bonusScore                       = "bonusScore",
    rewardCoins                      = "rewardCoins"
}


ReportModel.lvupkey = {
    preLevel                         = "preLevel",
    rewardCoins                      = "rewardCoins",
    vipPoint                         = "vipPoint",
}

ReportModel.dbgamekey = {
    initCoins                         = "initCoins",
    flopCnt                           = "flopCnt",
    rewardCoins                       = "rewardCoins",
}

ReportModel.eventkey = {
    eventType                         = "eventType"
}

ReportModel.schema                                       = clone(cc.mvc.ModelBase.schema)

ReportModel.schema[ReportModel.udid]                     = {"string", "nil"}
ReportModel.schema[ReportModel.needreport]          	 = {"number", 0}
ReportModel.schema[ReportModel.curGameReport]            = {"table", {}}
ReportModel.schema[ReportModel.waitGameReport]           = {"table", {}}
ReportModel.schema[ReportModel.curEventReport]           = {"table", {}}
ReportModel.schema[ReportModel.waitEventReport]          = {"table", {}}
-- ReportModel.schema[ReportModel.serialNo]                 = {"number", 1}

function ReportModel:ctor(properties)
    
    ReportModel.super.ctor(self, properties)

    if self.loadModel ~= nil then
        self:loadModel()
    end

    self.reporting = false

end

function ReportModel:test()

    for i=1,1 do
        -- machineId, machineName, lineNum, spinType, costCoins, winCoins, freeSpinCnt, fiveInARow, bonusCnt, rewardCoins, bonusScore
        self:spinGame(100 + i, "machinename"..tostring(i), i+20, math.random(4), 10*i, 100*i, 15, 4, 1, 100, 10)
    end

    -- for i=1,1 do
    --     self:levelUP(i, i*10+200, i*5)
    -- end

    -- for i=1,1 do
    --     self:doubleGame(1000, 5, 1000*1.5)
    -- end

    -- for i=1,1 do
    --     self:gameEvent(math.random(5))
    -- end

    --self:reportEventData()

    self:reportData()
end

-- 回报策略，TODO(Every five second)
function ReportModel:reportDataEveryFiveSeconds()
    -- spin count >= 10
    local curentSpinlist = self.curGameReport_[ReportModel.rga.spinList]
    if curentSpinlist ~= nil then
        --print("#curentSpinlist: ", table.nums(curentSpinlist))
        if table.nums(curentSpinlist) >= 10 then
            table.insert(self.waitGameReport_, clone(self.curGameReport_))
            self.curGameReport_ = {}
            self:serializeModel()
        end

        --print("reportData: ")
        --print("table.nums(self.waitGameReport_) :", table.nums(self.waitGameReport_), self.reporting)

        if table.nums(self.waitGameReport_) > 0 and self.reporting == false then
            self:reportGameData() 
        end
    end

end

-- 回报策略，TODO
function ReportModel:reportData()


    print("self.curGameReport_:", self.curGameReport_)

    --dump( self.curGameReport_ , "self.curGameReport_" ,9999999999999)

    print("table.nums(self.curGameReport_):", table.nums(self.curGameReport_))

-- spin count > 10 
    if table.nums(self.curGameReport_) > 0 then
        table.insert(self.waitGameReport_, clone(self.curGameReport_))
        self.curGameReport_ = {}
        self:serializeModel()
    end

    print("reportData")
    print(table.nums(self.waitGameReport_), self.reporting)

    -- self:reportGameData() 

    if table.nums(self.waitGameReport_) > 0 and self.reporting == false then
        self:reportGameData() 
    end

end

function ReportModel:reportGameData()
    
    print("reportGameData self.reporting:", self.reporting)

    self.reporting = true 

    local function callBack(rdata)

        local msg = DataReport_pb.GCGameReport()
        msg:ParseFromString(rdata)

        if msg.result then

            print("reportGameData callBack:", msg.result)

            print("before:")
            --dump(self.waitGameReport_)

            table.remove(self.waitGameReport_, 1)
            self:serializeModel()

            print("after:")
            --dump(self.waitGameReport_)

            if table.nums(self.waitGameReport_) > 0 then
                print("111")
                self:reportGameData()
            else
                self.reporting = false 
            end
        end

    end

    local gamedata = self.waitGameReport_[1]

    local playerInfo = self:getPlayerInfo()

    local curPid = app:getUserModel():getCurrentPid()
    print("getCurrentPid :", curPid)
    local req = DataReport_pb.CGGameReport()
    req.pid = curPid
    req.serialNo = app:getUserModel():stepSerialNO()--playerInfo.serialNo
    req.timestamp = os.time()

    print("req.serialNo:", req.serialNo)

    self:addPlayerAccountInfo(req.account, playerInfo)

    local spinlist = gamedata[ReportModel.rga.spinList]

    if not spinlist then spinlist = {} end

    for key, val in pairs(spinlist) do

        local spinInfo       = req.spinList:add()

        spinInfo.timestamp      = val[ReportModel.timestamp]
        spinInfo.machineId      = val[ReportModel.spinkey.machineId]
        spinInfo.machineName    = val[ReportModel.spinkey.machineName]
        spinInfo.lineNum        = val[ReportModel.spinkey.lineNum]
        spinInfo.spinType       = val[ReportModel.spinkey.spinType]
        spinInfo.costCoins      = val[ReportModel.spinkey.costCoins]
        spinInfo.winCoins       = val[ReportModel.spinkey.winCoins]
        spinInfo.freeSpinCnt    = val[ReportModel.spinkey.freeSpinCnt]
        spinInfo.fiveInARow     = val[ReportModel.spinkey.fiveInARow]
        spinInfo.bonusCnt       = val[ReportModel.spinkey.bonusCnt]

        local bonusRewardCoins = spinInfo[ReportModel.spinkey.rewardCoins]
        local bonusScore = spinInfo[ReportModel.spinkey.bonusScore]

        if bonusRewardCoins and bonusScore then
            spinInfo.bonusGame.bonusScore = bonusScore
            spinInfo.bonusGame.rewardCoins = bonusRewardCoins
        end

        self:formatAccountInfo(spinInfo.account, val[ReportModel.accountInfo])
        
    end

    local lvUPlist = gamedata[ReportModel.rga.levelUpList]

    if not lvUPlist then lvUPlist = {} end

    for key, val in pairs(lvUPlist) do

        local lvupInfo = req.levelUpList:add()
        lvupInfo.timestamp      = val[ReportModel.timestamp]
        lvupInfo.preLevel       = val[ReportModel.lvupkey.preLevel]
        lvupInfo.rewardCoins    = val[ReportModel.lvupkey.rewardCoins]
        lvupInfo.vipPoint       = val[ReportModel.lvupkey.vipPoint]

        self:formatAccountInfo(lvupInfo.account, val[ReportModel.accountInfo])

    end

    local doubleGameList = gamedata[ReportModel.rga.doubleGameList]

    if not doubleGameList then doubleGameList = {} end

    for key, val in pairs(doubleGameList) do

        local dbgameInfo = req.doubleGameList:add()

        dbgameInfo.timestamp    = val[ReportModel.timestamp]
        dbgameInfo.initCoins    = val[ReportModel.dbgamekey.initCoins]
        dbgameInfo.flopCnt      = val[ReportModel.dbgamekey.flopCnt]
        dbgameInfo.rewardCoins  = val[ReportModel.dbgamekey.rewardCoins]

        -- local accountInfo = val[ReportModel.accountInfo]
        
        self:formatAccountInfo(dbgameInfo.account, val[ReportModel.accountInfo])
        -- addPlayerAccountInfo(dbgameInfo.account, accountInfo)
    end

    local eventList = gamedata[ReportModel.rga.eventList]

    if not eventList then eventList = {} end

    for key, val in pairs(eventList) do

        local eventInfo = req.eventList:add()
        eventInfo.timestamp    = val[ReportModel.timestamp]
        eventInfo.eventType    = val[ReportModel.eventkey.eventType]
        self:formatAccountInfo(eventInfo.account, val[ReportModel.accountInfo])

    end

    core.SocketNet:sendCommonProtoMessage(CG_GAME_REPORT, GC_GAME_REPORT, curPid, req, callBack, false)

end

function ReportModel:getPlayerInfo()
    local model = app:getUserModel()
    local cls = model.class
    return app:getUserModel():getProperties({cls.pid, cls.serialNo, cls.piggyBank, cls.level, cls.exp, cls.vipLevel, cls.vipPoint, cls.coins, cls.gems})
end

function ReportModel:spinGame(machineId, machineName, lineNum, spinType, costCoins, winCoins, freeSpinCnt, fiveInARow, bonusCnt, rewardCoins, bonusScore)

    local spinInfo = {}

    spinInfo[ReportModel.timestamp] = os.time()
    spinInfo[ReportModel.spinkey.machineId] = machineId
    spinInfo[ReportModel.spinkey.machineName] = machineName
    spinInfo[ReportModel.spinkey.lineNum] = lineNum
    spinInfo[ReportModel.spinkey.spinType] = spinType
    spinInfo[ReportModel.spinkey.costCoins] = costCoins
    spinInfo[ReportModel.spinkey.winCoins] = winCoins
    spinInfo[ReportModel.spinkey.freeSpinCnt] = freeSpinCnt
    spinInfo[ReportModel.spinkey.fiveInARow] = fiveInARow
    spinInfo[ReportModel.spinkey.bonusCnt] = bonusCnt

    if bonusCnt > 0 then
        spinInfo[ReportModel.spinkey.rewardCoins] = rewardCoins
        spinInfo[ReportModel.spinkey.bonusScore] = bonusScore
    end

    spinInfo[ReportModel.accountInfo] = {}

    if self.curGameReport_[ReportModel.rga.spinList] == nil then
        self.curGameReport_[ReportModel.rga.spinList] = {}
    end

    self:addPlayerAccountInfo(spinInfo[ReportModel.accountInfo])

    local curentSpinlist = self.curGameReport_[ReportModel.rga.spinList]
    
    curentSpinlist[#curentSpinlist+1] = spinInfo

    -- self:serializeModel()

end

function ReportModel:levelUP(preLevel, rewardCoins, vipPoint)

    print("preLevel:", preLevel, "rewardCoins:", rewardCoins, "vipPoint:", vipPoint)

    local lvupInfo = {}

    lvupInfo[ReportModel.timestamp] = os.time()
    lvupInfo[ReportModel.lvupkey.preLevel] = preLevel
    lvupInfo[ReportModel.lvupkey.rewardCoins] = rewardCoins
    lvupInfo[ReportModel.lvupkey.vipPoint] = vipPoint
    lvupInfo[ReportModel.accountInfo] = {}

    if self.curGameReport_[ReportModel.rga.levelUpList] == nil then
        self.curGameReport_[ReportModel.rga.levelUpList] = {}
    end

    local curentlvUPlist = self.curGameReport_[ReportModel.rga.levelUpList]

    self:addPlayerAccountInfo(lvupInfo[ReportModel.accountInfo])
    
    curentlvUPlist[#curentlvUPlist+1] = lvupInfo

    print("#curentlvUPlist:", #curentlvUPlist)
    print("#self.curGameReport_[ReportModel.rga.levelUpList]", #self.curGameReport_[ReportModel.rga.levelUpList])

    -- self:serializeModel()
    
end

function ReportModel:doubleGame(initCoins, flopCnt, rewardCoins)

    local dbgameInfo = {}

    dbgameInfo[ReportModel.timestamp] = os.time()
    dbgameInfo[ReportModel.dbgamekey.initCoins] = initCoins
    dbgameInfo[ReportModel.dbgamekey.flopCnt] = flopCnt
    dbgameInfo[ReportModel.dbgamekey.rewardCoins] = rewardCoins
    dbgameInfo[ReportModel.accountInfo] = {}

    if self.curGameReport_[ReportModel.rga.doubleGameList] == nil then
        self.curGameReport_[ReportModel.rga.doubleGameList] = {}
    end

    local curentdbGamelist = self.curGameReport_[ReportModel.rga.doubleGameList]

    self:addPlayerAccountInfo(dbgameInfo[ReportModel.accountInfo])
    
    curentdbGamelist[#curentdbGamelist+1] = dbgameInfo

    -- self:serializeModel()
end

function ReportModel:gameEvent(eventType)

    local eventInfo = {}

    eventInfo[ReportModel.timestamp] = os.time()
    eventInfo[ReportModel.eventkey.eventType] = eventType
    eventInfo[ReportModel.accountInfo] = {}

    if self.curGameReport_[ReportModel.rga.eventList] == nil then
        self.curGameReport_[ReportModel.rga.eventList] = {}
    end

    local curentdbEventList = self.curGameReport_[ReportModel.rga.eventList]

    self:addPlayerAccountInfo(eventInfo[ReportModel.accountInfo])
    
    curentdbEventList[#curentdbEventList+1] = eventInfo

end


function ReportModel:addPlayerAccountInfo(target)

    local playerInfo = self:getPlayerInfo()

    target.pid = app:getUserModel():getCurrentPid()
    target.gems = playerInfo.gems
    target.coins = playerInfo.coins
    target.vipPoint = playerInfo.vipPoint
    target.vipLevel = playerInfo.vipLevel
    target.exp = playerInfo.exp
    target.level = playerInfo.level
    target.piggyBank = playerInfo.piggyBank

end

function ReportModel:formatAccountInfo( target , AccountDetail )

    target.pid = app:getUserModel():getCurrentPid()
    target.gems = AccountDetail.gems
    target.coins = AccountDetail.coins
    target.vipPoint = AccountDetail.vipPoint
    target.vipLevel = AccountDetail.vipLevel
    target.exp = AccountDetail.exp
    target.level = AccountDetail.level
    target.piggyBank = AccountDetail.piggyBank

end

function ReportModel:reportBaseInfo()
    local function callBack(rdata)
        local msg = DataReport_pb.GCGameReport()
        msg:ParseFromString(rdata)
        if msg.result then
            print("reportBaseInfo callBack:", msg.result)
        end
    end

    local playerInfo = self:getPlayerInfo()
    local curPid = app:getUserModel():getCurrentPid()
    print("getCurrentPid :", curPid)
    local req = DataReport_pb.CGGameReport()
    req.pid = curPid
    req.serialNo = app:getUserModel():stepSerialNO()--playerInfo.serialNo
    req.timestamp = os.time()
    print("req.serialNo:", req.serialNo)
    self:addPlayerAccountInfo(req.account, playerInfo)

    core.SocketNet:sendCommonProtoMessage(CG_GAME_REPORT, GC_GAME_REPORT, curPid, req, callBack, false)
end




return ReportModel
