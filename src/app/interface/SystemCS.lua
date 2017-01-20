require "app.interface.pb.SystemConfig_pb"
require "app.interface.pb.SlotsMessageType"

local SystemCS = {}

--http调用登录接口
function SystemCS:checkVersion(callfunction)
    
    local function callBack(responseCode,rdata)

        if tonumber(responseCode) ~= 200 then
            if callfunction ~=nil then callfunction() end
            return
        end

        local body=core.NetPacket.subPacketBody(rdata)
        local msg = SystemConfig_pb.GCCheckVersion()
        msg:ParseFromString(body)

        print(tostring(msg))
        
        if msg.needUpdate == 1 then
            print("need update new version")
            if callfunction ~=nil then callfunction() end
        else
            print("no new version")
        end

    end

    local req = SystemConfig_pb.CGCheckVersion()
    req.pid   = 587067935
    req.clientVersion = "1.3"

    core.HttpNet.sendCommonProtoMessage(CG_CHECK_VERSION,1,req, callBack)

end

function SystemCS:kingsoftAD(callfunction)

    Waiting.show()

    local function callBack(responseCode,rdata)

        Waiting.hide()

        if tonumber(responseCode) ~= 200 then
            if callfunction ~=nil then callfunction() end
            return
        end

        local body=core.NetPacket.subPacketBody(rdata)
        local msg = SystemConfig_pb.GCUserTrack()
        msg:ParseFromString(body)

        print(tostring(msg))

        if msg.result == 1 then

            if msg.rewardType == ITEM_TYPE.NORMAL_MULITIPLE then

                local coins = User.getProperty(User.KEY_TOTALCOINS)
                User.setProperty(User.KEY_TOTALCOINS, coins + msg.rewardCnt)

            elseif msg.rewardType == ITEM_TYPE.GEMS_MULITIPLE then

                local gems = User.getProperty(User.KEY_TOTALGEMS)
                User.setProperty(User.KEY_TOTALGEMS, gems + msg.rewardCnt)
            end

        end

        if callfunction ~=nil then callfunction() end

    end

    local req = SystemConfig_pb.CGUserTrack()
    req.pid     = User.getProperty(User.KEY_PID)
    req.udid    = User.getProperty(User.KEY_UDID)
    req.type    = 1

    core.HttpNet.sendCommonProtoMessage(CG_USER_TRACK,1,req, callBack)

end

return SystemCS