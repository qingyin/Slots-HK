
require("config")
require("cocos.init")
require("framework.init")
require("app.init")

-- require("app.data.txspoker.TxsTestCase")
Notification = require "app.core.Notification"

local MyApp = class("MyApp", cc.mvc.AppBase)

function MyApp:ctor()
    MyApp.super.ctor(self)
    core.SocketNet:init()
    self:init()
    self:registGlobalEvents()

    if device.platform == "android" then
        print("MyApp--OK")
        CCAccountManager:preloadFinish()
        -- local notificationCenter = CCNotificationCenter:sharedNotificationCenter()
        -- notificationCenter:registerScriptObserver(nil, handler(self, self.onAndroidQuitGame), "APP_ANDROID_QUIT_EVENT")
    end

    app:getObject("ReportModel"):gameEvent(EventMgr.ENTER_GAME)
end

function MyApp:init()
	-- body
	self.objects_ = {}

    -- data
    core.Sqlite.init()

    print('self:isObjectExists("UserModel"):', self:isObjectExists("UserModel"))
    
    if not self:isObjectExists("UserModel") then
        -- user 对象只有一个，不需要每次进入场景都创建
        local usermodel = scn.models.UserModel.new({
            id = "UserModel"
        })
        self:setObject("UserModel", usermodel)
    end

    if not self:isObjectExists("ReportModel") then
        -- user 对象只有一个，不需要每次进入场景都创建
        local reportmodel = data.ReportModel.new({
            id = "ReportModel"
        })
        self:setObject("ReportModel", reportmodel)
    end

    --cc.Device:setKeepScreenOn(true)
end


function MyApp:run()
    cc.FileUtils:getInstance():addSearchPath("res/")
    self:preStart()

    -- scn.ScnMgr.replaceScene("lobby.LobbyScene")
    print("lobby.LoginScene")
    scn.ScnMgr.replaceScene("lobby.LoginScene")

    -- SlotsMgr.enterMachineById(2)
end

function MyApp:preStart()

    local onTick = function(dt)
        scn.ScnMgr.show()
    end
    self.schedulerEntry = cc.Director:getInstance():getScheduler():scheduleScriptFunc(onTick, 0, false)

    -- Notification.registNotification()

    -- location notice
    -- AppNotification:sharedAppNotification():cancelAllLocalNotifications();
    -- AppNotification:sharedAppNotification():RegisterLocalNotification("3:16:06","slot location notification");
end

function MyApp:setObject(id, object)
    assert(self.objects_[id] == nil, string.format("MyApp:setObject() - id \"%s\" already exists", id))
    self.objects_[id] = object
end

function MyApp:getObject(id)
    assert(self.objects_[id] ~= nil, string.format("MyApp:getObject() - id \"%s\" not exists", id))
    return self.objects_[id]
end

function MyApp:getUserModel()
    return self:getObject('UserModel')
end

function MyApp:getReportModel()
    return self:getObject('ReportModel')
end

function MyApp:isObjectExists(id)
    return self.objects_[id] ~= nil
end

function MyApp:serializeModels()
    for key, model in pairs(self.objects_) do
        if model.loadModel ~= nil and type(model.loadModel) == "function" then
            model:loadModel()
        end
    end
end


function MyApp:popDailyLogin()
    -- body
    if self.dailyLoginData and self.dailyLoginData.loginRewardState == 1 then
        scn.ScnMgr.popView("DailyLoginRewardView",self.dailyLoginData)
    end
    --scn.ScnMgr.popView("social.SocialView",{tabidx=1})
    --scn.ScnMgr.popView("gift.GiftsView",{tabidx=1})
end

function MyApp:getFreeBounsSign()
    return self.freeBouns
end

function MyApp:setFreeBounsSign(val)
    self.freeBouns = val
end

function MyApp:getFreeBouns(serverBack)
    self.freeBouns = 1
    local onComplete = function(msg)
        self.freeBonusData = msg
        print("getFreeBouns: ",tostring(msg))
        Notification.registType2(dict_notification["2"])
        serverBack()
    end

    net.TimingRewardCS:getTimingRewardState(onComplete)
end

function MyApp:updateDailyReward(serverBack)
    -- get dailylogin reward
    local function onCallBack(msg)
        self.dailyLoginData = msg
        serverBack()

        --print("updateDailyReward",  self.callNum , self.dailyLoginData)
    end

    net.DailyLoginCS:getLoginRewardState(onCallBack)
end

function MyApp:requestAfterEnterGame(callback)
    self:getUserModel():updateSerializeModel()
    
    self.callNum = 2

    local serverBack = function()
        -- body
        self.callNum = self.callNum - 1

        if self.callNum == 0 then
            pcall(callback)

            core.Waiting.logining = false
            core.Waiting.hide()
        end
    end

    self:getFreeBouns(serverBack)
    self:updateDailyReward(serverBack)
end

function MyApp:getPlayerInfo()
    -- body
    local function onComplete(lists)
        EventMgr:dispatchEvent({
            name  = EventMgr.UPDATE_PLAYERS_EVENT,
            list = lists
        })

    end

    net.FriendsCS:getOnlinePlayers(onComplete)
end

function MyApp:getFriendInfo()
    -- body
    local function onComplete(lists)
        EventMgr:dispatchEvent({
            name  = EventMgr.UPDATE_FRIENDS_EVENT,
            list = lists
        })

    end

    net.FriendsCS:getFriendsList(onComplete)
end

function MyApp:registGlobalEvents()
    -- msg notify
    core.SocketNet:registEvent(GC_MSG_NOTIFY, function(body)
        -- body
        local msg = Notify_pb.GCMsgNotify()
        msg:ParseFromString(body)

        audio.playSound("audio/message.mp3")
        --print("message notify:",msg.msgType)
        EventMgr:dispatchEvent({
            name  = EventMgr.SERVER_NOTICE_EVENT,
            hasnews = msg.msgType
        })
    end)

--    core.SocketNet:registEvent(GC_NOTIFY, function(body)
--        -- body
--        local msg = Game_pb.GCNotify()
--        msg:ParseFromString(body)
--
--        --print(tostring(msg))
--        EventMgr:dispatchEvent({
--            name  = EventMgr.UPDATE_PSTATES_EVENT,
--            playerList = msg.playerList
--        })
--
--    end)
--
--    core.SocketNet:registEvent(GC_INVITE_FRIEND, function(body)
--        -- body
--        local msg = Game_pb.GCInviteFriend()
--        msg:ParseFromString(body)
--
--        --print(tostring(msg))
--        scn.ScnMgr.popView("JoinGameNotifyView",msg)
--    end)
end


function MyApp:joinPlayerGame(info)

    local gid = info.gameId
    local unit = DICT_UNIT[tostring(gid)]
    
    local celltype = unit.type

    local onComplete = function(lists, siteId, rId)

        if celltype == "Slots" then
            SlotsMgr.joinSlotMachine(unit.dict_id,{players=lists,info={mysite=siteId, roomId =rId, gameId=tonumber(gid)}})
        elseif celltype == "BlackJack" then
            scn.ScnMgr.replaceScene("blackjack.BJController",{unit, {players=lists,info={mysite=siteId, roomId =rId, gameId=tonumber(gid)}}})
        elseif celltype == "VideoPoker" then
            scn.ScnMgr.replaceScene("videopoker.PokerController",{unit,  {players=lists,info={mysite=siteId, roomId =rId, gameId=tonumber(gid)}}})
        elseif celltype == "Texas" then
            scn.ScnMgr.replaceScene("texas.TexasController",{unit,  {players=lists,info={mysite=siteId, roomId =rId, gameId=tonumber(gid)}}})
        end

    end

    net.GameCS:joinPlayerGame(info, onComplete)
    
end

function MyApp:onEnterBackground()

    print("onEnterBackground")
    app:getObject("ReportModel"):gameEvent(EventMgr.ENTER_BACKGROUND)
    display.pause()
    core.FBPlatform.onEnterBackground()
end

function MyApp:onEnterForeground()

    print("onEnterForeground")

    app:getObject("ReportModel"):gameEvent(EventMgr.ENTER_FOREGROUND)
    display.resume()

    core.FBPlatform.onEnterForeground()
    -- self:requestAfterEnterGame()

end

return MyApp
