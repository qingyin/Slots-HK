local LobbyCell = require("app.scenes.lobby.views.LobbyCell")

local TopBar = class("TopBar", function() 
    return display.newNode()
end)

function TopBar:ctor(args)

    self.del = args.delegate
    self.onBackLobby = args.onBackLobby
    self.onVipLobby = args.onVipLobby
    self.isLobbyView = args.isLobbyView
    self:setNodeEventEnabled(true)

    app.coinSprite = self.del.coinSprite

end

function TopBar:showPigNotice()

    local model = app:getUserModel()
    local piggyBank = model:getPiggyBank()

    local fivewan = 50000
    local tenwan = 100000
    local offset = math.floor(piggyBank/tenwan)

    if piggyBank > fivewan or offset >= 1 then
        local alert = model:getPiggyBankAlert()
        if alert == 1 then
            self.del.pigNode:setVisible(true)

            model:setPiggyBankAlert(2)

            local time = 3
            local func = function()
                self.del.pigNode:setVisible(false)
            end

            self.del.pigDeclLabel:setString(tostring(piggyBank))

            local delay = cc.DelayTime:create(time)
            local callfunc = cc.CallFunc:create(func)
            local sequence = cc.Sequence:create(delay, callfunc)
            self:runAction(sequence)
        else
            self.del.pigNode:setVisible(false)
        end
    end


end

function TopBar:updateUILabel(event)
    --print("TopBar:updateUILabel")
    local model = app:getUserModel()
    local cls   =   model.class

    local properties = model:getProperties({
            cls.name, 
            cls.level, 
            cls.exp, 
            cls.vipLevel, 
            cls.vipPoint, 
            cls.coins, 
            cls.gems, 
            cls.pictureId,
            cls.hasnews,
            cls.musicSign,
            cls.soundSign,
            })
    --print("properties[cls.hasnews]:", properties[cls.hasnews])
    -- if properties[cls.hasnews] == 1 then
    --     self.del.messageHint:setVisible(true)
    --     self.del.messageHint1:setVisible(true)
    -- else
    --     self.del.messageHint:setVisible(false)
    --     self.del.messageHint1:setVisible(false)
    -- end
    if properties[cls.hasnews] >= 1 and properties[cls.hasnews] <= 2 then
        self.del.messageHint1:setVisible(true)
    else
        self.del.messageHint1:setVisible(false)
    end
    if properties[cls.hasnews] == 2 then
        self.del.messageHint:setVisible(true)
    else
        self.del.messageHint:setVisible(false)
    end

    if properties[cls.coins] then
        self.del.coinLabel:setString(number.commaSeperate(properties[cls.coins]))
    end

--    if properties[cls.gems] then
--        self.del.gemLabel:setString(tostring(properties[cls.gems]))
--    end



    if properties[cls.exp] then
        self.del.expLabel:setString(tostring(properties[cls.exp]))
    end

    if properties[cls.musicSign] == 1 then
    --if properties[cls.soundSign] == 1 then
        audio.setSoundsVolume(1)
    else
        audio.setSoundsVolume(0)
    end

    if properties[cls.musicSign] == 1 then
        audio.setMusicVolume(0.4)
    else
        audio.setMusicVolume(0)
    end


    if event then
        local currentLevel = tonumber(self.del.levelLabel:getString())
        local pc1, pc2, levelup, levelcount = AnimationUtil.getTwoPercentage(
            self.del.expProgress:getPercentage(), 
            currentLevel, 
            properties[cls.level], 
            model:getCurrentLvExp())

        AnimationUtil.progressMoveTo(self.del.expProgress, pc1, pc2, levelcount)

        if levelup == true then
            scn.ScnMgr.popView("LevelUpView",{level = properties[cls.level], pastLevel = currentLevel})

            local level = tonumber(properties[cls.level])
            local model = app:getObject("UserModel")
            local properties = model:getProperties({model.class.extinfo})

            local rateSign = properties[model.class.extinfo][model.class.ei.rateSign]
            if rateSign == nil or rateSign == 0 then
                 if level == 5 or level == 7 or level == 9 or level == 11 then
                     local task = DICT_SPECIAL_TASK["10002"]
                     local coins = tonumber(task.count)
                     scn.ScnMgr.popView("RateOnUs",{coins = coins})
                 end
            end
        end
    end

    if properties[cls.level] then
        self.del.levelLabel:setString(tostring(properties[cls.level]))
    end

    self:changeVipBtn()

    self:showPigNotice()
end

function TopBar:setMenuNodeIsVisible(isVisible)
    self.del.menusNode:setVisible(isVisible)
end

function TopBar:setHomeButtonEnabled(isEnabled)
    --print("setHomeButtonEnabled:", isEnabled)
    self.del.lobbyBtn:setVisible(isEnabled)
end

-- function TopBar:faceBookPhotoView()
--     local islogin = core.FBPlatform.getIsLogin()
--     print("islogin :", islogin)
--     if islogin then
--         self.del.headNode:setVisible(true)
--         self.del.fbBtn:setVisible(false)

--         local fbid = self:getFacebookID()
--         if fbid ~= nil then
--             self:downloadFBPhoto(fbid)
--         end 
--     else
--         self.del.fbBtn:setVisible(true)
--         self.del.headNode:setVisible(false)
--     end
-- end

function TopBar:faceBookPhotoView()
    local fbid = self:getFacebookID()
    if fbid ~= nil then
        self.del.headNode:setVisible(true)
        self.del.fbBtn:setVisible(false)
        self:downloadFBPhoto(fbid)
    else
        self.del.fbBtn:setVisible(true)
        self.del.headNode:setVisible(false)  
    end 
end

function TopBar:updateTopBarFB(event)
    --print("TopBar:updateTopBarFB")
    self:faceBookPhotoView()
end

function TopBar:updateTopBarBack(event)
    --print("TopBar:updateTopBarBack")
    self.del.menusNode:setVisible(false)
    self:setHomeButtonEnabled(true)
end

function TopBar:updateBackHome(event)
    --print("TopBar:updateBackHome")
    self.del.menusNode:setVisible(false)
    self:setHomeButtonEnabled(false)
end

function TopBar:getFacebookID()
    local model = app:getObject("UserModel")
    local cls = model.class
    local properties = model:getProperties({cls.facebook})
    local fb = properties[cls.facebook]
    local fbid = fb[cls.fb.fbid] 
    return fbid
end

function TopBar:initButton()
    -- on facebook
    core.displayEX.newSmallButton(self.del.fbBtn) 
        :onButtonClicked(function(event)
            self.del.menusNode:setVisible(false)
            self:connectFB()
        end)

    -- on menus
    core.displayEX.newSmallButton(self.del.menusBtn) 
        :onButtonClicked(function(event)
            if self.del.menusNode:isVisible() == true then
                self.del.menusNode:setVisible(false)
            else
                self.del.menusNode:setVisible(true)

                if self.del.hasVIPbar then
                    self.del.lobbyMenu:setVisible(true)
                    self.del.machineMenu:setVisible(false)
                else
                    self.del.lobbyMenu:setVisible(false)
                    self.del.machineMenu:setVisible(true)
                end
            end
        end)

    -- on message
    core.displayEX.newButton(self.del.messageBtn) 
        :onButtonClicked(function(event)
            net.MessageCS:getMessageList(function(body)
                self.del.menusNode:setVisible(false)
                scn.ScnMgr.popView("MessageView",body)
            end)

        end)

    -- on setting
    core.displayEX.newButton(self.del.optionBtn)
        :onButtonClicked(function(event)
            self.del.menusNode:setVisible(false)
            scn.ScnMgr.popView("SettingView")
        end)

    -- on achievement
    core.displayEX.newButton(self.del.lobbyBtn) 
        :onButtonClicked(function(event)
            self.del.menusNode:setVisible(false)

            if self.onBackLobby then 
                self.onBackLobby()
            else
                scn.ScnMgr.replaceScene("lobby.LobbyScene", nil, true)
            end
        end)

    if self.isLobbyView then
        if self.del.hasVIPbar then
            self:setHomeButtonEnabled(false)
        else
            self:setHomeButtonEnabled(true)
        end 
    else
        self:setHomeButtonEnabled(true)
    end

    -- on vip
    core.displayEX.newSmallButton(self.del.vipBtn) 
        :onButtonClicked(function(event)
            self.del.menusNode:setVisible(false)

            local callback = function()
                if self.onVipLobby then
                    self.onVipLobby()
                else
                    app.layoutId = 2
                    scn.ScnMgr.replaceScene("lobby.LobbyScene", nil, true)
                end
            end
            scn.ScnMgr.popView("VipView",{callback=callback})
        end)


    -- on addCoinBtn
    core.displayEX.newSmallButton(self.del.addCoinBtn) 
        :onButtonClicked(function(event)
            self.del.menusNode:setVisible(false)
            net.PurchaseCS:GetProductList(function(lists)
               scn.ScnMgr.popView("ProductsView",{productList=lists,tabidx=1})
            end)
        end)

    -- on pigBtn
    core.displayEX.newSmallButton(self.del.pigBtn) 
        :onButtonClicked(function(event)
            self.del.menusNode:setVisible(false)
            self.del.pigNode:setVisible(false)

            net.PurchaseCS:GetProductList(function(lists)
               scn.ScnMgr.popView("PigBonusView",{productList=lists})
            end)

        end)

end

function TopBar:hideMenu() 
    self.del.menusNode:setVisible(false)
end

-----------------------------------------------------------
-- LockUI
-----------------------------------------------------------
function TopBar:lockUI() 

    self.del.fbBtn:setButtonEnabled(false)
    self.del.menusBtn:setButtonEnabled(false)
    self.del.vipBtn:setButtonEnabled(false)
    self.del.addCoinBtn:setButtonEnabled(false)
    self.del.pigBtn:setButtonEnabled(false)

    self.del.messageBtn:setButtonEnabled(false)
    self.del.optionBtn:setButtonEnabled(false)
    self.del.lobbyBtn:setButtonEnabled(false)
end

-----------------------------------------------------------
-- UnLockUI
-----------------------------------------------------------
function TopBar:unLockUI() 

    self.del.fbBtn:setButtonEnabled(true)
    self.del.menusBtn:setButtonEnabled(true)
    self.del.vipBtn:setButtonEnabled(true)
    self.del.addCoinBtn:setButtonEnabled(true)
    self.del.pigBtn:setButtonEnabled(true)

    self.del.messageBtn:setButtonEnabled(true)
    self.del.optionBtn:setButtonEnabled(true)
    self.del.lobbyBtn:setButtonEnabled(true)

end

function TopBar:changeVipBtn()
    --print("TopBar:changeVipBtn")
    local model = app:getUserModel()
    local vipLevel = model:getVipLevel()
    --print("vipLevel = ",vipLevel)

    local images = {}
    images.n="dating_vip_0"..(vipLevel + 1)..".png"
    images.s="dating_vip_0"..(vipLevel + 1)..".png"
    images.d="dating_vip_0"..(vipLevel + 1)..".png"

    if cc.SpriteFrameCache:getInstance():getSpriteFrame(images.n) then
        --print("images.n:", images.n)
        core.displayEX.setButtonImages(self.del.vipBtn, images)
    end
end

function TopBar:initDeal()
    local spId = 7
    --LobbyCell.extendDealCell(self.del, spId)

    self.del.dealNode:setVisible(false)

    local secTimer, counter = 0, 1000

    self.spAdSchEntry = nil
    self.spAdScheduler = require(cc.PACKAGE_NAME .. ".scheduler")

    local function formatTimer(dtime)

        local hor, min, sec, timeStr
        dtime = math.ceil(dtime)

        local function formatTime(num)
            if num < 10 then
                num = '0'..num
            end
            return num
        end

        hor = math.modf(dtime/(60 * 60))
        min = math.modf((dtime - hor * 60 * 60)/60)
        sec = dtime - hor * 60 * 60 - min * 60

        hor = formatTime(hor)
        min = formatTime(min)
        sec = formatTime(sec)

        timeStr = hor..':'..min..':'..sec

        return timeStr
    end

    local function tick(dt)

        secTimer = secTimer + dt

        if secTimer >= 1 and counter >= 1 and self.del then
                
            secTimer = 0
            counter = counter - 1
            self.del.dealTimerLabel:setString(formatTimer(counter))

        elseif counter <= 0 or not self.del then
            if self.spAdSchEntry then
                self.spAdScheduler.unscheduleGlobal(self.spAdSchEntry) 
                self.spAdSchEntry = nil

                self.del.dealNode:setVisible(false)
            end
        end

    end


   local function callback(leftTime)
        
        counter = leftTime
        if self.spAdSchEntry then
            self.spAdScheduler.unscheduleGlobal(self.spAdSchEntry)
            self.spAdSchEntry = nil
        end
        self.spAdSchEntry = self.spAdScheduler.scheduleGlobal(tick , 0)
        self.del.dealNode:setVisible(true)
    end
    AdMgr.updataSpAdTimer(spId, callback)


    -- on deal
    core.displayEX.newButton(self.del.dealBtn) 
        :onButtonClicked(function(event)
            net.MessageCS:getMessageList(function(body)
                AdMgr.showAdListView(spId)
            end)

        end)
end

function TopBar:initExp()

    local model = app:getUserModel()
    --local exp = model:getExp()
    local exp = model:getCurrentLvExp()
    local lvl = model:getLevel()

    -- expProgress
    local expX,expY = self.del.expSprite:getPosition()
    local parent = self.del.expSprite:getParent()
    
    self.del.expSprite:removeFromParent(false)

    self.del.expProgress = display.newProgressTimer(self.del.expSprite, display.PROGRESS_TIMER_BAR)
        :pos(expX, expY)
        :addTo(parent)

    self.del.expProgress:setMidpoint(cc.p(0, 0))
    self.del.expProgress:setBarChangeRate(cc.p(1, 0))

    -- local pc1, pc2, levelup= self:getTwoPercentage(exp, lvl)
    -- self.del.expProgress:setPercentage(pc2)

    local lexp = tonumber(getNeedExpByLevel(lvl+1))
    self.del.expProgress:setPercentage(100 * exp / lexp)

end


function TopBar:updateNotice(event)

    local hasNum = tonumber(event.hasnews)

    local model = app:getUserModel()
    local cls = model.class
    local properties = model:getProperties({cls.noticeSign})
    print("---TopBar:updateNotice--properties[cls.noticeSign] =",properties[cls.noticeSign],event.hasnews)
    if properties[cls.noticeSign] == 1 then
        if hasNum == 1 or hasNum == 2 then
            local model = app:getUserModel()
            model:setProperties({hasnews=hasNum})
            model:serializeModel()

            if hasNum == 2 then
                self.del.messageHint:setVisible(true)
            end
            self.del.messageHint1:setVisible(true)
        end
    end
end

function TopBar:connectFB()
    local function onComplete()
        local fbid = TopBar.getFacebookID(self)
        --print("TopBar:connectFB fbid:", fbid)
        if fbid ~= nil then
            if self.del and self.del.headNode then
                self.del.headNode:setVisible(true)
                self.del.fbBtn:setVisible(false)
            end
            TopBar.downloadFBPhoto(self,fbid)
            EventMgr:dispatchEvent({name  = EventMgr.UPDATE_TOPFB_EVENT})
        end
        core.Waiting.logining = false
        core.Waiting.hide()
    end
    core.FBPlatform.login(onComplete)
end


function TopBar:downloadFBPhoto(fBId)
    if self.del and self.del.headBgSprite then
        self.del.headBgSprite:setVisible(true)
    end
    local facebookCallBack = function(event)
        local user = event.user
        local photo = event.photo
        if photo ~= nil and photo ~= "-1" then
            print( "TopBar down image", event.photo.id, event.photo.name, event.photo.path)
            if self.del and self.del.headBgSprite ~= nil and self.del.headNode ~= nil then
                local head = display.newSprite(photo.path, 60, 60)
                local x,y = self.del.headBgSprite:getPosition()
                head:setPosition(x,y) 
                self.del.headBgSprite:setVisible(false)
                self.del.headNode:addChild(head)
            end
        end
    end
    CCAccountManager:sharedAccountManager():init("facebook")
    CCAccountManager:sharedAccountManager():postFBListenerLua(facebookCallBack)
    CCAccountManager:sharedAccountManager():downloadPhoto(fBId)
end

function TopBar:onEnter()
    self:initExp()
    self:initDeal()

    self:setTouchAnimation()
    
    self:updateUILabel()
    self:initButton()

    self:faceBookPhotoView()

    self:showPigNotice()

    EventMgr:addEventListener(EventMgr.UPDATE_LOBBYUI_EVENT, handler(self, self.updateUILabel))
    EventMgr:addEventListener(EventMgr.SERVER_NOTICE_EVENT, handler(self, self.updateNotice))
    EventMgr:addEventListener(EventMgr.UPDATE_TOPBACK_EVENT, handler(self, self.updateTopBarBack))
    EventMgr:addEventListener(EventMgr.UPDATE_TOPFB_EVENT, handler(self, self.updateTopBarFB))
    EventMgr:addEventListener(EventMgr.UPDATE_BACKHOME_EVENT, handler(self, self.updateBackHome))
    EventMgr:addEventListener(EventMgr.UPDATE_TOP_DEAL_EVENT, handler(self, self.updateDealBtn))
end

function TopBar:setTouchAnimation() 
    self.del.vipSprite:setTouchEnabled(true)
    self.del.vipSprite:setTouchSwallowEnabled(false)

    self.del.pigSprite:setTouchEnabled(true)
    self.del.pigSprite:setTouchSwallowEnabled(false)
end

function TopBar:onExit()
    if self.spAdSchEntry ~= nil then
        self.spAdScheduler.unscheduleGlobal(self.spAdSchEntry) 
        self.spAdSchEntry = nil
    end

    EventMgr:removeEventListenersByEvent(EventMgr.UPDATE_LOBBYUI_EVENT)
    EventMgr:removeEventListenersByEvent(EventMgr.SERVER_NOTICE_EVENT)
    EventMgr:removeEventListenersByEvent(EventMgr.UPDATE_TOPBACK_EVENT)
    EventMgr:removeEventListenersByEvent(EventMgr.UPDATE_TOPFB_EVENT)
    EventMgr:removeEventListenersByEvent(EventMgr.UPDATE_BACKHOME_EVENT)
    EventMgr:removeEventListenersByEvent(EventMgr.UPDATE_TOP_DEAL_EVENT)
    collectgarbage("collect")

end

function TopBar:updateDealBtn(event)
    -- local node = self.del:getChildByTag(1010)
    -- if node then
    --     node:onExit()
    --     node:removeFromParent(true)
    --     self.del.dealNode:setVisible(false)
    -- else
    --     self.del.dealNode:setVisible(false)
    -- end
    if self.del.dealNode ~= nil then
        self.del.dealNode:setVisible(false)
        if self.spAdSchEntry then
            self.spAdScheduler.unscheduleGlobal(self.spAdSchEntry)
            self.spAdSchEntry = nil
        end
    end
end

return TopBar
