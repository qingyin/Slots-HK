
require "app.interface.pb.Purchase_pb"
require "app.interface.pb.CasinoMessageType"

local PurchaseCS = {}

function PurchaseCS:GetProductList(callfunction)


    local function callBack(rdata)
        core.Waiting.hide()

        local msg = Purchase_pb.GCGetProductList()
        msg:ParseFromString(rdata)

        callfunction(msg.productList)


    end

    local pid = app:getUserModel():getCurrentPid()

    local req= Purchase_pb.CGGetProductList()

    req.pid = pid

    if device.platform == "android" then
        req.appId = ANDROID_APP_ID
    elseif device.platform == "ios" then
        req.appId = IOS_APP_ID
    end

    core.SocketNet:sendCommonProtoMessage(CG_GET_PRODUCT_LIST,GC_GET_PRODUCT_LIST,pid,req,callBack,true)
end

function PurchaseCS:IosPurchase(args)
    --print("PurchaseCS:IosPurchase")
    --puts(args)
    local model = app:getUserModel()
    local pid = model:getCurrentPid()

    local adId  = args.adId
    local view  = args.view
    local iapId = args.iapId
    local receipt = args.receipt
    local productId = args.productId
    local argCallBack = args.callBack

    local function callBack(rdata)
        core.Waiting.hide()

        local msg = Purchase_pb.GCIosPurchase()
        msg:ParseFromString(rdata)
        --print("PurchaseCS:IosPurchase")
        --print(tostring(msg))
        --print("msg.result:", msg.result)
        if msg.result == 1000 then --IOS充值校验成功
            local itemsBuy = msg.purchaseItems
            local num = #itemsBuy
            local vipCount = 0
            local itemId = nil

            for i = 1, num do

                local itemBuy=itemsBuy[i]
                vipCount = itemBuy.vipCount
                itemId = itemBuy.itemId
                --print("itemBuy.itemId:", itemId)
                if itemBuy.itemId == ITEM_TYPE.NORMAL_MULITIPLE then

                    local coins = model:getCoins()
                    model:setCoins(coins + itemBuy.count)
                    EventMgr:dispatchEvent({name = EventMgr.UPDATE_LOBBYUI_EVENT})

                elseif itemBuy.itemId == ITEM_TYPE.GEMS_MULITIPLE then

                    local gems =  model:getGems()
                    model:setGems(gems + itemBuy.count)
                    EventMgr:dispatchEvent({name = EventMgr.UPDATE_LOBBYUI_EVENT})
                elseif itemBuy.itemId == ITEM_TYPE.PIGGYBANK_MULITIPLE then
                    local piggyBank = model:getPiggyBank()
                    if piggyBank > 0 then
                        local coins = model:getCoins()
                        model:setCoins(coins + piggyBank)
                    end
                    model:setPiggyBank(itemBuy.count)
                    model:setPiggyBankAlert(0)
                end
            end
            
            --向appsflyer汇报
            --local productId = transaction.productIdentifier
            
            --set spin count after buy
            initBuyCoinsPool()
            model:setSpincountafterbuy(0)
            model:serializeModel()

            --print("itemId: ", itemId)
            --pig purchase
            
            scn.ScnMgr.addView("CommonView", {title="Congratulations!", content="Purchase Successful!", delayPopCall=function()

                    local vp = model:getVipPoint()
                    local vipup = model:setVipPoint(vp + msg.vipPoint)

                    local showResult = function()
                        if vipCount ~= nil and vipCount > 0 then
                            if vipup == true then
                                local callback = function()
                                    EventMgr:dispatchEvent({name=EventMgr.UPDATE_LOBBYUI_EVENT})
                                    scn.ScnMgr.popView("VipLevelUpView")
                                end
                                scn.ScnMgr.addView("VipExtraCoinsView", {vipCount = vipCount, callback = callback})
                            else
                                scn.ScnMgr.addView("VipExtraCoinsView", {vipCount = vipCount})
                            end
                        else
                            if vipup == true then
                                EventMgr:dispatchEvent({name=EventMgr.UPDATE_LOBBYUI_EVENT})
                                scn.ScnMgr.addView("VipLevelUpView")
                            end
                        end
                    end

                    --pig purchase
                    if itemId == ITEM_TYPE.PIGGYBANK_MULITIPLE then
                        if argCallBack ~= nil then 
                            --print("argCallBack")
                            argCallBack(showResult) 
                        end

                    else
                        showResult()

                        if argCallBack ~= nil then argCallBack() end
                    end

            end} )
            

        elseif msg.result == 1002 then  -- IOS校验失败

            -- scn.ScnMgr.addView("CommonView", {title="Failed!", content="Purchase Failed!", callback=function()
            --     EventMgr:dispatchEvent({name = EventMgr.PURCHASE_PBFAILED_EVENT})     
            -- end} )
            
        elseif msg.result == 1003 then
        elseif msg.result == 1004 then

        end


    end

    local req= Purchase_pb.CGIosPurchase()

    req.pid = pid
    req.appId = IOS_APP_ID
    req.receipt = receipt
    req.prodId = productId
    req.iapId = iapId
    req.adId = adId
    req.deviceType   = device.model
    req.clientType   = 1
    req.gameVersion = CCAccountManager:sharedAccountManager():AppVersion()

    core.SocketNet:sendCommonProtoMessage(CG_IOS_PURCHASE,GC_IOS_PURCHASE,pid,req,callBack, true)
end


function PurchaseCS:getOrderPayload(playCallBackFun)
    core.Waiting.show()
    local function callBack(rdata)
        core.Waiting.hide()

        local msg = Purchase_pb.GCGetOrderPayload()
        msg:ParseFromString(rdata)

        print("server back", tostring(msg))
        
        playCallBackFun(msg.payload)
    end

    local model = app:getUserModel()
    local pid = model:getCurrentPid()

    local req = Purchase_pb.CGGetOrderPayload()
    req.pid = pid
    core.SocketNet:sendCommonProtoMessage(CG_GET_ORDER_PAYLOAD, GC_GET_ORDER_PAYLOAD, pid, req, callBack, true)
end

function PurchaseCS:googlePlayPurchase(args)

    core.Waiting.show()

    local model = app:getUserModel()
    local pid = model:getCurrentPid()

    local receipt= args.receipt
    local signature= args.signature
    local adId = args.adId
    local prodId = args.productId
    local iapId = args.iapId
    local playCallBackFun=args.playCallBackFun

    local function callBack(rdata)
        
        core.Waiting.hide()

        local msg = Purchase_pb.GCGooglePlayPurchase()
        msg:ParseFromString(rdata)

        print("server back", tostring(msg))
        
        playCallBackFun(msg)
    end

    print("pid:",pid)
    print("appId:",ANDROID_APP_ID)
    print("receipt:",receipt)
    print("signature:",signature)
    print("adId:", adId)


    local req = Purchase_pb.CGGooglePlayPurchase()
    req.pid = pid
    req.appId=ANDROID_APP_ID
    req.receipt= receipt
    req.signature= signature
    req.adId = adId
    req.prodId = prodId
    req.iapId = iapId
    req.deviceType   = device.model
    req.clientType   = 2
    req.gameVersion  = CCAccountManager:sharedAccountManager():AppVersion()

    core.SocketNet:sendCommonProtoMessage(CG_GOOGLE_PLAY_PURCHASE, GC_GOOGLE_PLAY_PURCHASE,  pid, req, callBack, true)

end

return PurchaseCS
