
require "app.interface.pb.User_pb"
require "app.interface.pb.CasinoMessageType"

local UserCS = {}

function UserCS:updateDataFromServer(args, model, cls)

    local properties = {}

    properties[cls.serialNo]            = args.playerInfo.serialNo
    properties[cls.name]                = args.playerInfo.name
    properties[cls.exp]                 = args.playerInfo.exp
    properties[cls.level]               = args.playerInfo.level
    properties[cls.coins]               = args.playerInfo.coins
    properties[cls.gems]                = args.playerInfo.gems
    properties[cls.money]               = args.playerInfo.money
    properties[cls.vipLevel]            = args.playerInfo.vipLevel
    properties[cls.vipPoint]            = args.playerInfo.vipPoint
    properties[cls.liked]               = args.playerInfo.liked
    properties[cls.pictureId]           = args.playerInfo.pictureId
    properties[cls.loginDays]           = args.playerInfo.loginDays
    properties[cls.successiveLoginDays] = args.playerInfo.successiveLoginDays
    properties[cls.piggyBank]           = args.playerInfo.piggyBank

    properties[cls.totalgames]          = 0
    properties[cls.spincountafterbuy]   = -1
    properties[cls.buyCoinsPool]        = {}
    properties[cls.firstLoginPool]      = {}

    model:setProperties(properties)

    model:serializeModel()

end


--http调用登录接口
function UserCS:EnterGame(pid, callfunction)

    local model = app:getObject("UserModel")
    local cls = model.class
    local properties = model:getProperties({cls.lastPid})

    local function callBack(rdata)

        local msg = User_pb.GCEnterGame()
        msg:ParseFromString(rdata)

        --print(tostring(msg))

        if msg.result == 1 then
        
            print("EnterGame CallBack:", pid, properties[cls.lastPid])

            if pid ~= properties[cls.lastPid] then
                model:setProperties({lastPid=pid})
                model:serializeModel()
                
                self:updateDataFromServer(msg, model, cls)
            end

            if callfunction~= nil then callfunction() end

        elseif msg.result == 2 then
            if callfunction~= nil then callfunction() end
        end

    end

    local req= User_pb.CGEnterGame()

    req.pid=pid
    
    core.SocketNet:sendCommonProtoMessage(CG_ENTER_GAME,GC_ENTER_GAME,pid,req,callBack, true)

end

function UserCS:RateUsBack()
    local pid = app:getUserModel():getCurrentPid()
    local req= User_pb.CGRateUs()
    req.pid = pid

    core.SocketNet:sendCommonProtoMessage(CG_RATE_US,GC_RATE_US, pid,req, print, false)
end


return UserCS
