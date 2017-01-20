local SettingView = class("SettingView", function()
    return core.displayEX.newSwallowEnabledNode()
end)

function SettingView:ctor()
    local touchlayer = display.newColorLayer(cc.c4b(0, 0, 0, 200))
    self:addChild(touchlayer)
    touchlayer:setTouchSwallowEnabled(false)

    self.viewNode  = CCBuilderReaderLoad(RES_CCBI.setting, self)
    self:addChild(self.viewNode)


    AnimationUtil.setContentSizeAndScale(self.viewNode)

    self:initUI()

    self:registerEvent()

end

function SettingView:registerEvent()

    self:addNodeEventListener(cc.NODE_TOUCH_EVENT,handler(self, self.onTouch_))

	-- on close
    core.displayEX.newSmallButton(self.btn_close) 
        :onButtonClicked(function(event)
            scn.ScnMgr.removeView(self)
        end)

	-- on pan
    core.displayEX.newButton(self.btn_go) 
        :onButtonClicked(function(event)
			device.openURL("https://www.facebook.com/bigslotsventure")
        end)

    core.displayEX.newButton(self.loginFBBtn) 
        :onButtonClicked(function(event)
           self:connectFB()
        end)

    core.displayEX.newButton(self.logoutFBBtn) 
        :onButtonClicked(function(event)
            local model = app:getObject("UserModel")
            local cls = model.class
            local properties = model:getProperties({cls.facebook})
            properties[cls.facebook] = {}
            model:setProperties(properties)
            model:serializeModel()

            core.FBPlatform.logout()

            scn.ScnMgr.replaceScene("lobby.LoginScene")
            scn.ScnMgr.removeView(self)
        end)
end

function SettingView:initUI()
	local model = app:getUserModel()
    local cls = model.class
    local properties = model:getProperties({cls.musicSign, cls.soundSign, cls.facebook,cls.noticeSign})

     if properties[cls.noticeSign] == 1 then
         self.mark_sound:setVisible(true)
         self.no_mark_sound:setVisible(false)
     else
         self.mark_sound:setVisible(false)
         self.no_mark_sound:setVisible(true)
     end


	-- if properties[cls.audioSign] == 1 then
 --        audio.setSoundsVolume(1)
 --        audio.setMusicVolume(0.35)
 --    	self.mark_music:setVisible(true)
 --        self.no_mark_music:setVisible(false)
 --    else
 --        audio.setMusicVolume(0)
 --        audio.setSoundsVolume(0)
 --    	self.mark_musicandsound:setVisible(false)
 --        self.no_mark_musicandsound:setVisible(true)
 --    end

--    if properties[cls.soundSign] == 1 then
--        audio.setSoundsVolume(1)
--        self.mark_sound:setVisible(true)
--        self.no_mark_sound:setVisible(false)
--    else
--        audio.setSoundsVolume(0)
--        self.mark_sound:setVisible(false)
--        self.no_mark_sound:setVisible(true)
--    end

    if properties[cls.musicSign] == 1 then
        audio.setMusicVolume(0.4)
        audio.setSoundsVolume(1)
        self.mark_music:setVisible(true)
        self.no_mark_music:setVisible(false)
    else
        audio.setMusicVolume(0)
        audio.setSoundsVolume(0)
        self.mark_music:setVisible(false)
        self.no_mark_music:setVisible(true)
    end

    local curPid = app:getUserModel():getCurrentPid()
    self.playerID:setString(tostring(curPid))

    local version = CCAccountManager:sharedAccountManager():AppVersion()
    self.version:setString(tostring(version))

    local islogin = core.FBPlatform.getIsLogin()
    if islogin then
        self.loginFBNode:setVisible(false)
        self.logoutFBNode:setVisible(true)

        local fb = properties[cls.facebook]
        local name = fb[cls.fb.name]
        self.nameText:setString(tostring(name))

        local fbid = fb[cls.fb.fbid]
        self:downloadFBPhoto(fbid)
    else
        self.loginFBNode:setVisible(true)
        self.logoutFBNode:setVisible(false)
    end

    -- local fb = properties[cls.facebook]
    -- local fbid = fb[cls.fb.fbid]
    -- if fbid ~= nil then
    --     self.loginFBNode:setVisible(false)
    --     self.logoutFBNode:setVisible(true)

    --     local name = fb[cls.fb.name]
    --     self.nameText:setString(tostring(name))

    --     self:downloadFBPhoto(fbid)
    -- else
    --     self.loginFBNode:setVisible(true)
    --     self.logoutFBNode:setVisible(false)
    -- end
end

function SettingView:onTouch_(event)

    if event.name == "ended" then

    	if self.mark_music:getCascadeBoundingBox():containsPoint(cc.p(event.x, event.y)) then
    		self:selectMusic()
    	elseif self.mark_sound:getCascadeBoundingBox():containsPoint(cc.p(event.x, event.y)) then
    		--self:selectSound()
            self:selectNotice()
    	end

    end

    return true
end

function SettingView:selectMusic()

    local model = app:getUserModel()
    local cls = model.class
    local properties = model:getProperties({cls.musicSign})

    if properties[cls.musicSign] == 1 then
        properties[cls.musicSign] = 0
        properties[cls.soundSign] = 0
        audio.setMusicVolume(0)
        audio.setSoundsVolume(0)
        self.mark_music:setVisible(false)
        self.no_mark_music:setVisible(true)
    else
        properties[cls.musicSign] = 1
        properties[cls.soundSign] = 1
        audio.setMusicVolume(0.4)
        audio.setSoundsVolume(1)
        self.mark_music:setVisible(true)
        self.no_mark_music:setVisible(false)
    end

    model:setProperties(properties)

    model:serializeModel()
end

function SettingView:selectSound()

    local model = app:getUserModel()
    local cls = model.class
    local properties = model:getProperties({cls.soundSign})

    if properties[cls.soundSign] == 1 then
        properties[cls.soundSign] = 0
        audio.setSoundsVolume(0)
        self.mark_sound:setVisible(false)
        self.no_mark_sound:setVisible(true)
    else
        properties[cls.soundSign] = 1
        audio.setSoundsVolume(1)
        self.mark_sound:setVisible(true)
        self.no_mark_sound:setVisible(false)
    end

    model:setProperties(properties)

    model:serializeModel()
end

function SettingView:connectFB()
    local function onComplete()
        local model = app:getObject("UserModel")
        local cls = model.class
        local properties = model:getProperties({cls.facebook})
        local fb = properties[cls.facebook]
        local fbid = fb[cls.fb.fbid] 
        local name = fb[cls.fb.name]
        if fbid ~= nil then
            SettingView.downloadFBPhoto(self,fbid)
            if self.loginFBNode then
                self.loginFBNode:setVisible(false)
                self.logoutFBNode:setVisible(true)
                self.nameText:setString(name)
            end
        end
        EventMgr:dispatchEvent({name  = EventMgr.UPDATE_TOPFB_EVENT})
        core.Waiting.logining = false
        core.Waiting.hide()
    end
    core.FBPlatform.login(onComplete)
end

function SettingView:downloadFBPhoto(fBId)
    local facebookCallBack = function(event)
        local user = event.user
        local photo = event.photo
        if photo ~= nil and photo ~= "-1" then
            if self.headSprite ~= nil and  self.logoutFBNode ~= nil then
                local head = display.newSprite(photo.path)
                local x,y = self.headSprite:getPosition()
                head:setPosition(x,y)
                self.logoutFBNode:addChild(head)
                self.headSprite:removeFromParentAndCleanup(true)

                local curPid = app:getUserModel():getCurrentPid()
                self.playerID:setString(tostring(curPid))
            end
            EventMgr:dispatchEvent({name  = EventMgr.UPDATE_TOPFB_EVENT})
        end
    end

    CCAccountManager:sharedAccountManager():init("facebook")
    CCAccountManager:sharedAccountManager():postFBListenerLua(facebookCallBack)
    CCAccountManager:sharedAccountManager():downloadPhoto(fBId)
end

function SettingView:selectNotice()
    local model = app:getUserModel()
    local cls = model.class
    local properties = model:getProperties({cls.noticeSign})

    if properties[cls.noticeSign] == 1 then
        properties[cls.noticeSign] = 0
        self.mark_sound:setVisible(false)
        self.no_mark_sound:setVisible(true)
    else
        properties[cls.noticeSign] = 1
        self.mark_sound:setVisible(true)
        self.no_mark_sound:setVisible(false)
    end

    model:setProperties(properties)

    model:serializeModel()
end

return SettingView
