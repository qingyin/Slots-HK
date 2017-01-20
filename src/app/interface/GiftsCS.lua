
require "app.interface.pb.Gift_pb"
require "app.interface.pb.CasinoMessageType"

local GiftsCS = {}

function GiftsCS:getGiftList(hascollected, callfunction)

    local function callBack(rdata)
        core.Waiting.hide()

        local msg = Gift_pb.GCGetGiftList()
        msg:ParseFromString(rdata)
        callfunction(msg.giftList)

    end

    local pid = app:getUserModel():getCurrentPid()

    local req= Gift_pb.CGGetGiftList()

    req.pid = pid
    req.state = hascollected

    core.SocketNet:sendCommonProtoMessage(CG_GET_GIFT_LIST,GC_GET_GIFT_LIST, pid,req,callBack, true)
end

function GiftsCS:sendGift(toFreinds, giftId, callfunction)

    local function callBack(rdata)
        core.Waiting.hide()

        local msg = Gift_pb.GCSendGift()
        msg:ParseFromString(rdata)

        callfunction(msg)

    end

    local pid = app:getUserModel():getCurrentPid()

    local req= Gift_pb.CGSendGift()

    req.fromPid = pid

    local num = #toFreinds 

    if num > 0 then
        req.toPid = tostring(toFreinds[1].pid)
        for i=2, num do
            local fd = toFreinds[i]
            req.toPid = req.toPid..","..tostring(fd.pid)
        end
    end
    
    --req.giftType = tonumber(giftType)
    req.giftId = giftId

    -- print("Gift_pb", req.fromPid, req.giftType, req.giftId, req.toPid)

    core.SocketNet:sendCommonProtoMessage(CG_SEND_GIFT, GC_SEND_GIFT, pid,req, callBack, true)
end

function GiftsCS:receiveGift(pdId, callfunction)


    local function callBack(rdata)
        core.Waiting.hide()

        local msg = Gift_pb.GCReceiveGift()
        msg:ParseFromString(rdata)
        
        callfunction(msg)

    end

    local pid = app:getUserModel():getCurrentPid()

    local req= Gift_pb.CGReceiveGift()

    req.id = pdId

    core.SocketNet:sendCommonProtoMessage(CG_RECEIVE_GIFT, GC_RECEIVE_GIFT, pid,req, callBack, true)
end

return GiftsCS
