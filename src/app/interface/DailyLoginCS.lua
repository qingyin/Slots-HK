
require "app.interface.pb.DailyLogin_pb"
require "app.interface.pb.CasinoMessageType"

local DailyLoginCS = {}

function DailyLoginCS:getLoginRewardState(callfunction)
    
    local function callBack(rdata)

        local msg = DailyLogin_pb.GCGetLoginRewardState()
        msg:ParseFromString(rdata)

        if callfunction then callfunction(msg) end

    end

    local pid = app:getUserModel():getCurrentPid()

    local req= DailyLogin_pb.CGGetLoginRewardState()

    req.pid = pid

    core.SocketNet:sendCommonProtoMessage(CG_GET_LOGIN_REWARD_STATE,GC_GET_LOGIN_REWARD_STATE,pid,req, callBack, true)
end


function DailyLoginCS:receiveLoginReward(rewardtype, cnt, callfunction)
    
    local function callBack(rdata)
        core.Waiting.hide()

        local msg = DailyLogin_pb.GCReceiveLoginReward()
        msg:ParseFromString(rdata)

        print(tostring(msg))

        if callfunction then callfunction(msg) end

    end


    local pid = app:getUserModel():getCurrentPid()

    local req= DailyLogin_pb.CGReceiveLoginReward()

    req.pid=pid

    core.SocketNet:sendCommonProtoMessage(CG_RECEIVE_LOGIN_REWARD,GC_RECEIVE_LOGIN_REWARD,pid,req, callBack, true)

end

return DailyLoginCS
