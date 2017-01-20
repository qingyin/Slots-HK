local Bit = require "app.core.Bit"

local Notification = {}


local function initNotification()
    --require("framework.api.EventProtocol").extend(Notification)
    --cc(Notification):addComponent("components.behavior.EventProtocol"):exportMethods()
    
    Notification["notices"] = {}
    Notification["notices"]["1"] = Notification.registType1
    Notification["notices"]["2"] = Notification.registType2
    Notification["notices"]["3"] = Notification.registType3
    Notification["notices"]["4"] = Notification.registType4
    Notification["notices"]["5"] = Notification.registType5

end

function Notification.registNotification()

   -- if TISHEN_CONFIG.notification == false then return end

--   if User.Report.getGameState(User.Report.KEY_STATE_NOTIFICATION) == true then
--        initNotification()
--        AppNotification:sharedAppNotification():cancelAllLocalNotifications()
--
--        for key, val in pairs(dict_notification) do
--            Notification.notices[val.type](val)
--        end
--    else
--        AppNotification:sharedAppNotification():cancelAllLocalNotifications()
--    end

    initNotification()
    AppNotification:sharedAppNotification():cancelAllLocalNotifications()
    Notification.registType1(dict_notification["1"])
end

function Notification.registType1(val)
    local days = val.condition.days
    local nowTime = os.time()
    local nowDate = os.date("*t", os.time())

    local onedaySecond = 24 * 60 * 60
    --local yestodaySecond = onedaySecond + onedaySecond - ( nowDate.hour * 60 * 60 + nowDate.min * 60 + nowDate.sec )

    for i=1,#days do
        local day = days[i]
        local noticeTime = nowTime + day * onedaySecond
        local noticeTimeString = tostring(noticeTime)..":1:"..tostring(day * onedaySecond)
        AppNotification:sharedAppNotification():RegisterLocalNotification(noticeTimeString, val.content)
    end
end

function Notification.registType2(val)


--    local lastBonusTime = userModel:getLastgetbonustime()
--    local lastBonusGainSign = userModel:getLastgetbonusflag()
--    local lastBonusDate = os.date("*t", lastBonusTime)
--
--    local bit = Bit.new(lastBonusGainSign)
--    local bsign = false
--
--    if bit:getPosValue(lastBonusDate.hour) == 1 then
--        bsign = true
--    end
--
--    local nowSeconds = os.time()
--    local todayDate = os.date("*t", nowSeconds)
--
--    local onedaySecond = 24 * 60 * 60
--    local hours = val.condition.interval_hours
--
--    local hassecond = onedaySecond - ( lastBonusDate.hour * 60 * 60 + lastBonusDate.min * 60 + lastBonusDate.sec )
--    local subsecond = hours * 60 * 60 - ( hassecond - (hours * 60 * 60) * math.floor( hassecond/(hours * 60 * 60) ) )
--
--    if todayDate.day == lastBonusDate.day then
--        if bsign == false then
--            subsecond = hours * 60 * 60
--        else
--            subsecond = subsecond + onedaySecond - ( todayDate.hour * 60 * 60 + todayDate.min * 60 + todayDate.sec )
--        end
--    elseif todayDate.day > lastBonusDate.day then
--        local todaySecond = ( todayDate.hour * 60 * 60 + todayDate.min * 60 + todayDate.sec )
--        if ( todaySecond - subsecond ) >= 0 then
--            subsecond = 30
--        else
--            subsecond = subsecond - todaySecond
--        end
--    else
--        return
--    end
--
--    local noticeTimeString = tostring(nowSeconds + subsecond)..":1:"..tostring(subsecond)
--
--    local dayinfo = os.date("*t", nowSeconds + subsecond)
    local lefttime = app.freeBonusData.timeLeft
    if lefttime == 0 then
        lefttime = app.freeBonusData.totalTime
    end
    local nowTime = os.time()
    local noticeTime = nowTime + lefttime
    local noticeTimeString = tostring(noticeTime)..":1:"..tostring(lefttime)

    AppNotification:sharedAppNotification():RegisterLocalNotification(noticeTimeString, val.content)
end

function Notification.registType3(val)
    print(val.type, val.content)
    local hour = val.condition.hour
    local minute = val.condition.minute
    local hassecond = hour * 60 * 60 + minute * 60
    
    local nowSeconds = os.time()
    local todayDate = os.date("*t", nowSeconds)
    local todaysecond = todayDate.hour * 60 * 60 + todayDate.min * 60

    local noticeTimeString = tostring(nowSeconds + hassecond - todaysecond)..":2:"..tostring(hassecond - todaysecond)

    AppNotification:sharedAppNotification():RegisterLocalNotification(noticeTimeString, val.content)
end

function Notification.registType4(val)
    print(val.type, val.content)
    local day = val.condition.day_of_week
    local hour = val.condition.hour
    local minute = val.condition.minute
    local seconds = hour * 60 * 60 + minute * 60

    local nowSeconds = os.time()
    local todayDate = os.date("*t", nowSeconds)
    local wday = todayDate.wday
    
    local days = day - wday
    
    if days < 0 then
        days = days + 7
    end

    seconds = seconds + days * 24 * 60 * 60

    local noticeTimeString = tostring(nowSeconds + seconds)..":3:"..tostring(seconds)

    AppNotification:sharedAppNotification():RegisterLocalNotification(noticeTimeString, val.content)
end

function Notification.registType5(val)
    print(val.type, val.content)
    
    local y      = val.condition.year
    local m      = val.condition.month
    local d      = val.condition.day
    local h      = val.condition.hour
    local n      = val.condition.minute

    local seconds = os.time{year=y, month=m, day=d, hour=h, min=n,sec=0}

    local noticeTimeString = tostring(seconds)..":4:"..tostring(os.time())

    AppNotification:sharedAppNotification():RegisterLocalNotification(noticeTimeString, val.content)
end

return Notification