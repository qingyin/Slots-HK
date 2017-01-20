local FBPlatform = class("FBPlatform")
FBPlatform.isLogined = false

FBPlatform.facebookCallBack = nil
FBPlatform.data_fun = nil

function FBPlatform.getIsLogin()
    return plugin.FacebookAgent:getInstance():isLoggedIn()
end


function FBPlatform.logout()
    plugin.FacebookAgent:getInstance():logout()
end

function FBPlatform.getUid()
    if plugin.FacebookAgent:getInstance():isLoggedIn() then
        return plugin.FacebookAgent:getInstance():getUserID()
    else
        print("User haven't been logged in")
    end
end

function FBPlatform.getToken()
    if plugin.FacebookAgent:getInstance():isLoggedIn() then
        return plugin.FacebookAgent:getInstance():getAccessToken()
    else
        print("User haven't been logged in")
    end
end

function FBPlatform.requestAPI(path, method, params, callback)
    --local path = "/me/photos"
    --local params = {url = "http://files.cocos2d-x.org/images/orgsite/logo.png"}
    --method = plugin.FacebookAgent.HttpMethod.POST
    plugin.FacebookAgent:getInstance():api(path, method, params, function(ret, msg)
        callback(ret,msg)
    end)
end

function FBPlatform.share(params, callback)
    if plugin.FacebookAgent:getInstance():canPresentDialogWithParams(params) then
        
        plugin.FacebookAgent:getInstance():dialog(params, function(ret, msg)
                    print(msg)
                    callback(ret, msg)
                end)
    else
        params.dialog = "feedDialog"
        plugin.FacebookAgent:getInstance():dialog(params, function(ret, msg)
                    print(msg)
                    callback(ret, msg)
                end)
    end
end

function FBPlatform.appRequest(params, callback)
    plugin.FacebookAgent:getInstance():appRequest(params, function(ret, msg)
            print(msg)
            callback(ret, msg)
        end)
end

function FBPlatform.login( callback )
    core.Waiting.logining = true
    core.Waiting.show()

    local model = app:getObject("UserModel")
    local cls = model.class
    local properties = model:getProperties({cls.facebook})

    local fb = properties[cls.facebook]
    local facebookCallBack = function(ret, msg)
        if tonumber(ret) == 1 then
            core.Waiting.logining = false
            core.Waiting.hide()
            return
        end
                
        local msgJson = json.decode(msg)
                                
        fb[cls.fb.fbid]             = msgJson.id
        fb[cls.fb.name]             = msgJson.name
        fb[cls.fb.token]            = msgJson.accessToken

        local properties = {}
        properties[cls.facebook] = fb
        model:setProperties(properties)
        model:serializeModel()

        net.UserAuthCS:thirdLogin(msgJson.id, msgJson.name,function()
            
            local path = "/me/friends"
            local params = {fields="id",fields="name"}

            core.FBPlatform.requestAPI(path, plugin.FacebookAgent.HttpMethod.GET, params, function(ret, msg)
 
                local friends = json.decode(msg)

                local fbs = ""
                local idx = 1

                for k,v in pairs(friends.data) do

                    if idx == 1 then
                        fbs = fbs..v.id
                    else
                        fbs = fbs..","..v.id
                    end
                    idx = idx + 1
                    print(k,v, v.id)
                end         
                            
                local function onComplete()
                    core.Waiting.hide()


                    function connected(event)
                        local properties = model:getProperties({cls.fbPid})
                        net.UserCS:EnterGame(properties[cls.fbPid], function()
                            EventMgr:removeEventListenersByEvent(EventMgr.SOCKET_CONNECT_EVENT)
                            pcall(callback)
                            EventMgr:dispatchEvent({name  = EventMgr.UPDATE_LOBBYUI_EVENT})
                        end)
                    end

                    if core.SocketNet:isConnected() then
                        local properties = model:getProperties({cls.fbPid})
                        net.UserCS:EnterGame(properties[cls.fbPid], function()
                           pcall(callback)
                           EventMgr:dispatchEvent({name  = EventMgr.UPDATE_LOBBYUI_EVENT})
                        end)
                    else
                        EventMgr:addEventListener(EventMgr.SOCKET_CONNECT_EVENT, connected)
                        core.SocketNet:ConnectServer()
                    end


                end

                net.FriendsCS:addFacebookFriends(fbs, onComplete)
                    
            end)
        end)

    end

    local permissions = "user_friends,user_photos,public_profile"
    plugin.FacebookAgent:getInstance():login(permissions, function(ret, msg)
        FBPlatform.facebookCallBack = facebookCallBack
        FBPlatform.data_fun = facebookCallBack
        FBPlatform.facebookCallBack(ret, msg)
        if not FBPlatform.facebookCallBack then
            FBPlatform.data_fun(ret, msg)
        end
        FBPlatform.data_fun = nil
    end)

end

function FBPlatform.onEnterBackground()
    if FBPlatform.data_fun then
        FBPlatform.facebookCallBack = FBPlatform.data_fun
        --print("FBPlatform.onEnterBackground()-----------")
    end
end

function FBPlatform.onEnterForeground()
    if core.Waiting.logining then
        core.Waiting.logining = false
        core.Waiting.hide()
        FBPlatform.data_fun = FBPlatform.facebookCallBack
        FBPlatform.facebookCallBack = nil
        --print("FBPlatform.onEnterForeground()----------")
    end
end


return FBPlatform