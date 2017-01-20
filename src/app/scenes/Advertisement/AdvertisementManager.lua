require "app.interface.pb.Advertisement_pb"

local AdvertisementManager = class("AdvertisementManager")

local AM = AdvertisementManager

AM.EVN = {
   CASIN = 'CASIN',
   FANSPAGE = 'FANSPAGE',
}

function AM.formatValidTimeToStr( validTime )
   
    local day = math.floor(validTime / (24 * 60 * 60))
    local hour = math.floor((validTime - day * 24 * 60 * 60) / (60 * 60))
    local min = math.floor((validTime - (day * 24 * 60 * 60 + hour * 60 * 60)) / 60)
    local sec = validTime - (day * 24 * 60 * 60 + hour * 60 * 60 + min * 60)

    if min < 10 then min = '0'..min end
    if sec < 10 then sec = '0'..sec end

    local str
    if day > 0 then
        str = tostring(day)..' days '..tostring(hour)..':'..tostring(min)..':'..tostring(sec)
    else
        str = tostring(hour)..':'..tostring(min)..':'..tostring(sec)
    end

    return str

end


function AM.showAdListView(onShowAdId)

    local callback = function(adList)

        local rect = cc.rect(display.left, display.bottom, display.width, display.height)
        local adListView = import("app.views.adListUI.AdList").new(rect, adList)
        AM.adListView = adListView

        adListView:setTouchEnabled(true)    
        display.getRunningScene():addChild(adListView)

        if onShowAdId then
            local index = 0
            for i=1,#adList do
                index = index + 1
                if onShowAdId == adList[i].adId then
                    adListView:scrollToCell(index)
                    break
                end
            end
        end
        -- adListView:scrollToCell(2)

    end

    AM.getAdConfigFromServer(callback)
    
end

function AM.closeAdListView()

    if AM.adListView then
        AM.adListView:removeFromParent()
        AM.adListView = nil
    end

end

function AM.getAdConfigFromServer( callback )

    core.Waiting.show()

    local serverCallback = function(responseCode,rdata)
        core.Waiting.logining = false
        core.Waiting.hide()
        if tonumber(responseCode) ~= 200 then

            -- scn.ScnMgr.popView("CommonView",
            --     {
            --         title="Server Connect", 
            --         content="Server Connect error, please check your net!!!"
            --     })
            scn.ScnMgr.popView("CommunicationView")
            return
        end

        local body = core.NetPacket.subPacketBody(rdata)
        local msg = Advertisement_pb.GCGetAdList()
        msg:ParseFromString(body)

        for i=1,#msg.adList do
            if msg.adList[i].templateId == 1001 then
                User:dispatchEvent({
                    name = User.EVENT_UPDATE_ADTIMER, 
                    validTime = msg.adList[i].timeLeft,
                    onShowAdId = msg.adList[i].adId
                })
            end
        end

        -- for i=1,#msg.adList do
        --     print("adlist 99:", i)
        --     print(msg.adList[i])
        --     print("adlist 99 end:")
        -- end
        
        -- print("msg.systemTimestamp:", msg.systemTimestamp)
        -- print("---")
        
        if #msg.adList ~= 0 then
            callback((msg.adList))
        end
        
    end
    
    local userModel = app:getUserModel()
    local req = Advertisement_pb.CGGetAdList()

    req.pid     = userModel:getCurrentPid()
    req.coins   = userModel:getCoins()
    req.gems    = userModel:getGems()
    req.vipLevel= userModel:getVipLevel()

    core.HttpNet.sendCommonProtoMessage(CG_GET_AD_LIST, 1, req, serverCallback)

end

-- update special ad timer
function AM.updataSpAdTimer(spAdId, callback)

    local serverCallback = function(responseCode,rdata)
        if tonumber(responseCode) ~= 200 then
            return
        end

        local body = core.NetPacket.subPacketBody(rdata)
        local msg = Advertisement_pb.GCGetAdList()
        msg:ParseFromString(body)

        for i=1,#msg.adList do

            if msg.adList[i].adId == spAdId then
                -- User:dispatchEvent({
                --     name = User.EVENT_UPDATE_ADTIMER, 
                --     validTime = msg.adList[i].timeLeft,
                --     onShowAdId = msg.adList[i].adId
                -- })
                callback(msg.adList[i].timeLeft)
                return
            end

        end
        
    end
    
    local userModel = app:getUserModel()
    local req = Advertisement_pb.CGGetAdList()

    req.pid     = userModel:getCurrentPid()
    req.coins   = userModel:getCoins()
    req.gems    = userModel:getGems()
    req.vipLevel= userModel:getVipLevel()

    core.HttpNet.sendCommonProtoMessage(CG_GET_AD_LIST, 1, req, serverCallback)

end

return AdvertisementManager