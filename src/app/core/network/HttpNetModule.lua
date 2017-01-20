
module("app.core.network.HttpNetModule", package.seeall)

require("luabuf")


local HttpNetModule = app.core.network.HttpNetModule

local PM = require("app.core.network.PacketModule")

--local serverurl = HTTP_SERVER_URL
local serverurl = "http://122.0.71.122:8020/gamedata.py"

--[[
protoObj:protobuf对象
]]

function HttpNetModule.sendCommonProtoMessage(iType,passportId,protoObj, iCallbackFunction)
    local bodyData=protoObj:SerializeToString()
    HttpNetModule.sendCommonMessage(iType,passportId,bodyData, iCallbackFunction)
end


--[[
发送默认的消息格式,messageLength(int)+type(short)+protobuf
iType:消息类型
iBody:消息体
iCallbackFunction:回调函数,callback(responseCode,rdata)
]]

function HttpNetModule.sendCommonMessage(iType,passportId,iBody, iCallbackFunction)

    local packet=core.NetPacket.buildPacket(iType,passportId,iBody)
    
    print("packet len"..string.len(packet),iType,passportId)

    local url = cc.UserDefault:getInstance():getStringForKey("server_url")
    
    if url==nil then
        url=serverurl
    end
    print("server_url:",url)
    HttpNetModule.sendBinaryDataAsync(url,packet, iCallbackFunction)
end


--发送j二进制包到服务器
function HttpNetModule.sendBinaryDataAsync(url,iData, iCallbackFunction)

    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_ARRAY_BUFFER
    xhr:open("POST", url)

    xhr.timeout = 5

    local function onHttpCallback()
        if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
            print("=======http readyState is:", xhr.readyState, "http status is: ",xhr.status)
            iCallbackFunction(xhr.status, xhr.response)
        else
            print("http readyState is:", xhr.readyState, "http status is: ",xhr.status)

            core.Waiting.logining = false
            core.Waiting.hide()
            -- scn.ScnMgr.popView("CommonView",
            --     {
            --         title="Server Connect error",
            --         content="please check your net!",
            --     })
            scn.ScnMgr.popView("CommunicationView")
        end
    end

    xhr:registerScriptHandler(onHttpCallback)
    xhr:send(iData)

end