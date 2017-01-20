local ccnet = require("framework.cc.net.init")

require "app.interface.pb.Chat_pb"
require "app.interface.pb.Game_pb"
require "app.interface.pb.CasinoMessageType"

--module("app.core.network.SocketNetModule", package.seeall)

--local SocketNetModule = app.core.network.SocketNetModule

local PM = require("app.core.network.PacketModule")

local SocketNetModule = class("SocketNetModule")

function SocketNetModule:ctor()
    --self:init()
end

--初始化方法，程序启动时初始化一次
function SocketNetModule:init()

    local time = ccnet.SocketTCP.getTime()
   -- print("socket time:" .. time)

    local socket = ccnet.SocketTCP.new()
    socket:setName("SocketTcp")
    socket:setTickTime(0.2)
    --socket:setReconnTime(6)
    socket:setConnFailTime(5)

    socket:addEventListener(ccnet.SocketTCP.EVENT_DATA, handler(self, self.tcpData))
    socket:addEventListener(ccnet.SocketTCP.EVENT_CLOSE, handler(self, self.tcpClose))
    socket:addEventListener(ccnet.SocketTCP.EVENT_CLOSED, handler(self, self.tcpClosed))
    socket:addEventListener(ccnet.SocketTCP.EVENT_CONNECTED, handler(self, self.tcpConnected))
    socket:addEventListener(ccnet.SocketTCP.EVENT_CONNECT_FAILURE, handler(self, self.tcpConnectedFail))

    self.socket_ = socket
    
    self:ConnectServer()

    self.requests = {}

    self.events={}

    self.requestting = false
    self.checkTimer = 0

end

function SocketNetModule:ConnectServer()
    
    local socket_addr = cc.UserDefault:getInstance():getStringForKey("socket_addr")
    local socket_port = cc.UserDefault:getInstance():getStringForKey("socket_port")

    self.socket_:connect(socket_addr, socket_port, false)
    -- self.socket_:connect("104.200.30.18", 8082, false)
end

function SocketNetModule:enterGame()

end

function SocketNetModule:SendDataTest(fid)
    local function callBack(body)
        local msg = Chat_pb.GCChatMessage()
        msg:ParseFromString(body)
        print(tostring(msg))
    end

    self.events[tostring(GC_CHAT_MESSAGE)] = callBack

    local req= Chat_pb.CGChatMessage()

    req.pid  = fid
    req.chatChannel = 0
    req.content = "chat slots room!!!"
    
    core.SocketNet:sendCommonProtoMessage(CG_CHAT_MESSAGE, fid, req)
end

function SocketNetModule:isConnected()
    return self.socket_.isConnected
end

function SocketNetModule:removeReq(rtype)
    for k,v in pairs(self.requests) do
        if k ~= nil and v ~= nil then
            if v.rType == rtype then
                self.requests[k] = nil
                self:hideWaiting()
            end
        end
    end
end

function SocketNetModule:hideWaiting()
    if table.nums(self.requests) == 0 then
        core.Waiting.hide()
    end
end

function SocketNetModule:tcpData(event)


    print("tcpData:", event)
    
    local mybuf=luabuf.iobuffer_new()
    local headdata=PM.subPacketHead(event.data)
    mybuf:iobuffer_write_str(headdata)
    mybuf:iobuffer_read_int32()
    --读取消息类型
    local type=mybuf:iobuffer_read_short()

    print("===============tcpData:", type)
    self.requestting = false
    self:removeReq(type)
    --获得回调函数

    local callbackFun=self.events[tostring(type)]
    
    local body=PM.subPacketBody(event.data)

    --print(tostring(type),callbackFun)
    
    if nil ~= callbackFun then
        callbackFun(body)
    else
        print("not found callbackFun by type:"..type)
    end
end

function SocketNetModule:tcpClose()
    print("SocketTCP close")

    if self.requestHandle  then
        scheduler.unscheduleGlobal(self.requestHandle)
        self.requestHandle = nil
    end

    core.Waiting.logining = false
    core.Waiting.hide()
    -- scn.ScnMgr.popView("CommonView",
    --     {
    --         title="Server Connect error",
    --         content="please check your net!",
    --         callback = function()
    --             scn.ScnMgr.replaceScene("lobby.LoginScene")
    --         end
    --     })
    EventMgr:dispatchEvent({name = EventMgr.OFFLINE_STOP_SUTOSPIN})
    scn.ScnMgr.popView("CommunicationView")
end

function SocketNetModule:tcpClosed()
    print("SocketTCP closed")
end

function SocketNetModule:tcpConnected()
    print("SocketTCP connect success")
    EventMgr:dispatchEvent({ name  = EventMgr.SOCKET_CONNECT_EVENT  })
    --core.SocketNet:SendDataTest1(855094658)
    --core.SocketNet:SendDataTest(855094658)

    local requestTick = function(dt)

        if self.requestting == true or self.socket_.isConnected == false then
            print("self.requestting:", self.requestting, "self.socket_.isConnected:", self.socket_.isConnected," requests.num:",table.nums(self.requests))
            return
        end

        for k,v in pairs(self.requests) do

            if k ~= nil and v ~= nil then

                if v.rType ~= nil and v.callback ~= nil then
                    self.events[tostring(v.rType)] = v.callback
                end

                if v.callback ~= nil and self.requestting == false then

                    local bodyData = v.protoObj:SerializeToString()
                    if v.needwait == true then
                        core.Waiting.show()
                    end
                    self.requestting = true

                    self:sendCommonMessage(k,v.passportId,bodyData)
                    break
                else
                    local bodyData = v.protoObj:SerializeToString()
                    self:sendCommonMessage(k,v.passportId,bodyData)
                    self.requests[k] = nil
                    self:hideWaiting()
                end
            end
        end
    end
    if self.requestHandle  then
        scheduler.unscheduleGlobal(self.requestHandle)
        self.requestHandle = nil
    end
    self.requestHandle = scheduler.scheduleGlobal(requestTick, 1)

    -- check net
   local checkNetFun = function()
        if network.isInternetConnectionAvailable() then
             self.checkTimer = 0
            -- print("network.isInternetConnectionAvailable()")
        else
            self.checkTimer = self.checkTimer + 2

            print("self.checkTimer:", self.checkTimer)
            if self.checkTimer > 10 then
                scheduler.unscheduleGlobal(self.checkNetHandler)
                self.netHandler = nil
                self.checkTimer = 0
                self.socket_:close()
                print("self.socket_:close()")
                return
            end
        end
    end

    if self.checkNetHandler  then
        scheduler.unscheduleGlobal(self.checkNetHandler)
        self.checkNetHandler = nil
    end
    self.checkNetHandler = scheduler.scheduleGlobal(checkNetFun,2)


end

function SocketNetModule:tcpConnectedFail()
    print("SocketTCP connect fail")
end

--停止发送和接收数据
function SocketNetModule:stop()
    self.socket_:close()
end

function SocketNetModule:registEvent(iType, callback)
    self.events[tostring(iType)] = callback
end

function SocketNetModule:unregistEvent(iType)

    self.events[tostring(iType)] = nil
    self:removeReq(iType)
end

-- add request to queue
function SocketNetModule:sendCommonProtoMessage(iType,rType,passportId,protoObj, callback, needwait,forceMove)

    print("sendCommonProtoMessage", iType, rType)

    if self.requests[tostring(iType)] == nil then
        self.requests[tostring(iType)] = {}
    end
    -- if callback ~= nil then
    --     needwait = true
    -- end

    self.requests[tostring(iType)].protoObj=protoObj
    self.requests[tostring(iType)].rType=rType
    self.requests[tostring(iType)].passportId=passportId
    self.requests[tostring(iType)].callback=callback
    self.requests[tostring(iType)].needwait=needwait

    self.forceMove = forceMove

    -- local bodyData=protoObj:SerializeToString()
    -- if rType ~= nil and callback ~= nil then
    --     self.events[tostring(rType)] = callback
    -- end
    -- self:sendCommonMessage(iType,passportId,bodyData)
end

function SocketNetModule:sendCommonMessage(iType,passportId,iBody)
    print("send--- sendCommonMessage:", iType)
    local packet=core.NetPacket.buildPacket(iType,passportId,iBody)
    self.socket_:send(packet)
end
 
return SocketNetModule