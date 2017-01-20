

require "app.interface.pb.Notify_pb"
require "app.interface.pb.CasinoMessageType"

local MessageCS = {}


function MessageCS:getMessageList(callfunction)

    local function callBack(rdata)

        local msg = Notify_pb.GCGetMessageList()
        msg:ParseFromString(rdata)

        print("getMessageList: ",tostring(msg.msgList))

        callfunction(msg.msgList)
        
        core.Waiting.hide()

    end

    local pid = app:getUserModel():getCurrentPid()

    local req= Notify_pb.CGGetMessageList()

    req.pid = pid

    core.SocketNet:sendCommonProtoMessage(CG_GET_MESSAGE_LIST,GC_GET_MESSAGE_LIST,pid,req, callBack, true)
end

function MessageCS:receiveMsg(msgid, result, callbackfunction)


    local function callBack(rdata)

        local msg = Notify_pb.GCReceiveMsg()
        msg:ParseFromString(rdata)

        print("getMessageList: ",tostring(msg))

        callbackfunction(msg)
        
        core.Waiting.hide()

    end

    local pid = app:getUserModel():getCurrentPid()

    local req= Notify_pb.CGReceiveMsg()
    req.id  = msgid
    req.result = result

    core.SocketNet:sendCommonProtoMessage(CG_RECEIVE_MSG,GC_RECEIVE_MSG, pid,req, callBack, true)

end

return MessageCS