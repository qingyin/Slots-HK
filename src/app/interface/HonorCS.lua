
require "app.interface.pb.Honor_pb"
require "app.interface.pb.CasinoMessageType"

local HonorCS = {}

--http调用登录接口
function HonorCS:getHonorList(callfunction)
    
    local function callBack(rdata)
        core.Waiting.hide()

        local msg = Honor_pb.GCGetHonorList()
        msg:ParseFromString(rdata)

        callfunction(msg.honorList)
    end

    local pid = app:getUserModel():getPid()

    local req= Honor_pb.CGGetHonorList()

    req.pid=pid

    core.SocketNet:sendCommonProtoMessage(CG_GET_HONOR_LIST,GC_GET_HONOR_LIST,pid,req, callBack, true)

end

function HonorCS:receiveHonorReward(honorId, callfunction)
    
    local function callBack(rdata)
        core.Waiting.hide()

        local msg = Honor_pb.GCReceiveHonorReward()
        msg:ParseFromString(rdata)

        callfunction(msg)
        
    end

    local pid = app:getUserModel():getPid()

    local req= Honor_pb.CGReceiveHonorReward()

    req.pid=pid
    req.honorId=honorId

    core.SocketNet:sendCommonProtoMessage(CG_RECEIVE_HONOR_REWARD,GC_RECEIVE_HONOR_REWARD,pid,req, callBack, true)

end

return HonorCS
