
require "app.interface.pb.UserAuth_pb"
require "app.interface.pb.CasinoMessageType"

local UserAuthCS = {}

--http调用登录接口
function UserAuthCS:quickLogin(callfunction)
    core.Waiting.logining = true
    core.Waiting.show()

    local model = app:getObject("UserModel")
    local cls = model.class
    local properties = model:getProperties({cls.pid, cls.lastPid, cls.serialNo, cls.name, cls.level, cls.exp, cls.vipLevel, cls.vipPoint, cls.coins, cls.gems, cls.money, cls.liked, cls.pictureId, cls.extinfo, cls.gameState, cls.itemState})


    local function callBack(responseCode,rdata)
        --core.Waiting.hide()

        if tonumber(responseCode) ~= 200 then
            device.showAlert("Server Connect", "Server Connect error, please check your net!!!", "OK",
            function()
                CCDirector:sharedDirector():endToLua()
                os.exit()
            end)
            return
        end

        local body=core.NetPacket.subPacketBody(rdata)
        local msg = UserAuth_pb.GCQuickLogin()
        msg:ParseFromString(body)

        --print(tostring(msg))

        if msg.result == 1 then -- success
            model:setProperties({pid=msg.pid})

            if callfunction~= nil then callfunction() end

        elseif msg.result == 2 then -- fail
            --if callfunction~= nil then callfunction() end

        end

    end

    local req= UserAuth_pb.CGQuickLogin()

    req.udid= CCAccountManager:sharedAccountManager():UDID()


    req.deviceType=device.model
    req.osVersion = CCAccountManager:sharedAccountManager():SystemVersion()
    req.clientType = 1
    req.gameVersion = CCAccountManager:sharedAccountManager():AppVersion()

    req.deviceVersion = CCAccountManager:sharedAccountManager():SystemVersion()
    req.idfa = CCAccountManager:sharedAccountManager():getIdfa()
    req.idfv = CCAccountManager:sharedAccountManager():getIdfv()

    model:stepSerialNO()

    core.HttpNet.sendCommonProtoMessage(CG_QUICK_LOGIN,1,req, callBack)

end

function UserAuthCS:thirdLogin(id, fbname,callfunction)
    core.Waiting.logining = true
    core.Waiting.show()
    -- core.Waiting.show()
    print("thirdLogin :", id, fbname)
    local model = app:getObject("UserModel")
    local cls = model.class
    local properties = model:getProperties({cls.pid, cls.fbPid, cls.lastPid, cls.serialNo, cls.name, cls.level, cls.exp, cls.vipLevel, cls.vipPoint, cls.coins, cls.gems, cls.money, cls.liked, cls.pictureId, cls.extinfo, cls.gameState, cls.itemState})

    local function callBack(responseCode,rdata)
        -- core.Waiting.hide()

        if tonumber(responseCode) ~= 200 then

            device.showAlert("Server Connect", "Server Connect error, please check your net!!!", "OK",
                function()
                    CCDirector:sharedDirector():endToLua()
                    os.exit()
                end)
            return
        end

        local body=core.NetPacket.subPacketBody(rdata)
        local msg = UserAuth_pb.GCThirdConnect()
        msg:ParseFromString(body)

        if msg.result == 1 then     -- new user

            model:setProperties({fbPid=msg.pid})
            model:serializeModel()

            if callfunction~= nil then callfunction() end

        elseif msg.result == 2 then
            if callfunction~= nil then callfunction() end

        elseif msg.result == 3 then -- old user
                        
            model:setProperties({fbPid=msg.pid})
            model:serializeModel()

            if callfunction~= nil then callfunction() end

        end

    end

    local req= UserAuth_pb.CGThirdConnect()

    req.thirdId = id
    req.channelCode = 1
    req.deviceType=device.model
    req.osVersion = CCAccountManager:sharedAccountManager():SystemVersion()
    req.clientType = 1
    req.gameVersion = CCAccountManager:sharedAccountManager():AppVersion()
    req.thirdName=fbname

    req.deviceVersion = CCAccountManager:sharedAccountManager():SystemVersion()
    req.idfa = CCAccountManager:sharedAccountManager():getIdfa()
    req.idfv = CCAccountManager:sharedAccountManager():getIdfv()
    
    model:stepSerialNO()

    core.HttpNet.sendCommonProtoMessage(CG_THIRD_CONNECT,1,req, callBack)

end

return UserAuthCS
