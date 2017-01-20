
local LoginScene = class("LoginScene", function()
    return display.newScene("LoginScene")
end)

function LoginScene:ctor()

    local  node  = CCBReaderLoad("Login.ccbi", self)
    self:addChild(node)


    if display.width >= 1024 and display.height >= 768 then
        self.mainNode:setScale(1)
    else
        self.mainNode:setScale(0.8)
    end

    self:registerUIEvent()

    --self:addChild(display.newColorLayer(cc.c4b(0, 128, 0, 255)))

    -- local font = display.newTTFLabel({
    --             text = "me ttf AAA BBB 你好",
    --             font = "Arial",
    --             color = cc.c3b(255, 127, 0),
    --             size = 64,
    --             align = cc.TEXT_ALIGNMENT_CENTER
    --         })

    -- font:enableOutline(cc.c4b(64, 100, 64, 255), 6);

    -- font:setPosition(display.cx, display.cy)
    -- self:addChild(font)


    -- local font1 = display.newTTFLabel({
    --             text = "me ttf AAA BBB 你好",
    --             font = "Marker Felt",
    --             color = cc.c3b(255, 127, 0),
    --             size = 64,
    --             align = cc.TEXT_ALIGNMENT_CENTER
    --         })

    -- font1:enableOutline(cc.c4b(200, 100, 64, 255), 6);

    -- font1:setPosition(display.cx, display.cy-100)
    -- self:addChild(font1)


    -- local font2 = display.newTTFLabel({
    --             text = "me ttf AAA BBB 你好",
    --             font = "Marker Felt",
    --             color = cc.c3b(255, 127, 0),
    --             size = 64,
    --             align = cc.TEXT_ALIGNMENT_CENTER
    --         })

    -- font2:enableShadow(cc.c4b(255, 50, 32, 255), cc.size(4,-4))

    -- font2:setPosition(display.cx, display.cy+100)
    -- self:addChild(font2)

    -- local lf = self.fbLogin:getTitleLabelForState(cc.CONTROL_STATE_NORMAL)
    
    -- lf:enableShadow(cc.c4b(53, 119, 0, 255), cc.size(2,-2))

    -- local lg = self.guestLogin:getTitleLabelForState(cc.CONTROL_STATE_NORMAL)
    
    -- lg:enableOutline(cc.c4b(53, 119, 0, 255), 2)

    self:Layout()

end

function LoginScene:registerUIEvent()

    core.displayEX.newButton(self.fbLogin) 
        :onButtonClicked( function(event)
            core.FBPlatform.login(handler(self, self.onLobbyScene))
        end)

    core.displayEX.newButton(self.guestLogin) 
        :onButtonClicked( function(event)
            local function logined()
                self:logined()
            end
            
            net.UserAuthCS:quickLogin(logined)

        end)

end

function LoginScene:getPid()
    local model = app:getObject("UserModel")
    local cls = model.class
    local properties = model:getProperties({cls.pid, cls.fbPid})
    local pid = nil

    if self.isThirdLogin then
        pid = properties[cls.fbPid]
    else
        pid = properties[cls.pid]
    end

    return pid
end

function LoginScene:logined()
    --print("LoginScene:logined")
    -- body
    if core.SocketNet:isConnected() then

        net.UserCS:EnterGame(self:getPid(), function()
            -- body
            self:onLobbyScene()
        end)
    else
        EventMgr:addEventListener(EventMgr.SOCKET_CONNECT_EVENT, handler(self, self.connected))
        core.SocketNet:ConnectServer()
    end
    
end

function LoginScene:connected(event)
    net.UserCS:EnterGame(self:getPid(), function()
        -- body
        EventMgr:removeEventListenersByEvent(EventMgr.SOCKET_CONNECT_EVENT)
        self:onLobbyScene()
    end)
end

function LoginScene:onLobbyScene()

    app:requestAfterEnterGame(function()
        -- body
        scn.ScnMgr.replaceScene("lobby.LobbyScene")

    end)

end

function LoginScene:onEnter()
    local model = app:getObject("UserModel")
    local cls = model.class
    local properties = model:getProperties({cls.facebook})

    local fb = properties[cls.facebook]

    if fb[cls.fb.fbid] ~= nil then
        net.UserAuthCS:thirdLogin(fb[cls.fb.fbid], fb[cls.fb.name],function()
            self.isThirdLogin = true
            self:logined()
        end)
    end

end

-- function LoginScene:onEnter()

--     local model = app:getObject("UserModel")
--     local cls = model.class
--     local properties = model:getProperties({cls.facebook})

--     local fb = properties[cls.facebook]

--     if fb[cls.fb.fbid] ~= nil then
--         core.Waiting.show()
        
--         local facebookCallBack = function(ret, msg)
--             if tonumber(ret) == 1 then
--                 core.Waiting.hide()
--                 return
--             end
                    
--             local msgJson = json.decode(msg)
                                    
--             fb[cls.fb.fbid]             = msgJson.id
--             fb[cls.fb.name]             = msgJson.name
--             fb[cls.fb.token]            = msgJson.accessToken

--             local properties = {}
--             properties[cls.facebook] = fb
--             model:setProperties(properties)
--             model:serializeModel()

--             net.UserAuthCS:thirdLogin(msgJson.id, msgJson.name,function()
--                 self:logined()
--             end)

--         end

--         local permissions = "user_friends,user_photos,public_profile"
--         plugin.FacebookAgent:getInstance():login(permissions, function(ret, msg)
--             facebookCallBack(ret, msg)
--         end)
--     end

-- end

function LoginScene:onExit()
    self.isThirdLogin = false
end

return LoginScene