
require "app.interface.pb.TimingReward_pb"
require "app.interface.pb.CasinoMessageType"

local TimingRewardCS = {}


function TimingRewardCS:getTimingRewardState(callfunction)
    
    local function callBack(rdata)

        local msg = TimingReward_pb.GCGetTimingRewardState()
        msg:ParseFromString(rdata)

        if callfunction then callfunction(msg) end

    end

    local pid = app:getUserModel():getCurrentPid()

    local req= TimingReward_pb.CGGetTimingRewardState()

    req.pid = pid

    core.SocketNet:sendCommonProtoMessage(CG_GET_TIMING_REWARD_STATE,GC_GET_TIMING_REWARD_STATE,pid,req, callBack, false)
end

function TimingRewardCS:pickTimingReward(callfunction,  wheelReward)
    
    local function callBack(rdata)
        core.Waiting.hide()

        local msg = TimingReward_pb.GCPickTimingReward()
        msg:ParseFromString(rdata)

        if callfunction then callfunction(msg) end

    end

    local pid = app:getUserModel():getCurrentPid()

    local req= TimingReward_pb.CGPickTimingReward()

    req.pid=pid

    if wheelReward then req.wheelReward = wheelReward end

    core.SocketNet:sendCommonProtoMessage(CG_PICK_TIMING_REWARD,GC_PICK_TIMING_REWARD,pid,req, callBack, true)
end


return TimingRewardCS
