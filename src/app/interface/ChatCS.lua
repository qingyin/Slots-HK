
require "app.interface.pb.Chat_pb"
require "app.interface.pb.CasinoMessageType"

local ChatCS = {}


function ChatCS:chatMessage(msg)

    local pid = app:getUserModel():getPid()

    local req= Chat_pb.CGChatMessage()

    req.pid = pid
    req.chatChannel = 4
    req.content = msg

    core.SocketNet:sendCommonProtoMessage(CG_CHAT_MESSAGE,nil,pid,req)
end


return ChatCS
