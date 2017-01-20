
local PurchaseGooglePlay = class("PurchaseGooglePlay")
local GooglePlayAppKey = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAmuEyFs+Otlbx2vLh2a18s/ho8M98XUcrQ7JNeOnA+bSyixPQyoH/DiH6dHiDGBhUkS7hngjGk5ZQZL3i1gEo4L+H0rUe8Xjm5uCLHxPPyuQEEjvX8OdVCP9b4EBRkxeP8ledqHFa1gxUQg6BthA31iVBOtpWuxg0AatgJxckehCVB7VypzPVLlbALhzsGGnhNmB+pstcnZonQc39/56lh8h7Qh2bFwlhF3u90WD6/b+oY0EoKPmWzTH8Ra0zwXSAsZhRO39hAgdgJHTd+QeB9E3EMmSFoN4lbPlB0lUso1/ClDqOpB8OGmSAmmTqrXsb0KcTiQXAxlWuvXOP/Rr4PQIDAQAB"

-----------------------------------------------------------
-- Construct
-----------------------------------------------------------
function PurchaseGooglePlay:ctor()
    
    self.iap = plugin.PluginManager:getInstance():loadPlugin("IAPGooglePlay")
    self:init()

end

-----------------------------------------------------------
-- 
-----------------------------------------------------------
function PurchaseGooglePlay:init()

    local pPlayStoreInfo = {}
    pPlayStoreInfo["GooglePlayAppKey"] = GooglePlayAppKey
    self.iap:configDeveloperInfo(pPlayStoreInfo)
    self.iap:setDebugMode(true)

end

-----------------------------------------------------------
-- 
-----------------------------------------------------------
function PurchaseGooglePlay:purchaseProductWithID(args)

    local function getOrderPayloadCallBack(payload)

        local onGooglePlayCallback = function(ret, msg)

            if ret == 0 then -- success

                local msgJson = json.decode(msg)
                args.receipt = msgJson.receipt
                args.signature = msgJson.signature
                args.playCallBackFun = function(vagrs) 
                    self:onOurPurchaseServerCallback(vagrs, args.removeViewCall) 
                end

                print("onGooglePlayCallback11:", msg)

                net.PurchaseCS:googlePlayPurchase(args)

            else
                scn.ScnMgr.addView("CommonView", {title="GooglePlay Error", content=msg})
                core.Waiting.hide()
                EventMgr:dispatchEvent({name = EventMgr.PURCHASE_PBFAILED_EVENT})
            end

        end

        self.iap:payForProduct({
            productId = args.iapProductId,
            payload = payload
            }, onGooglePlayCallback)
    end
    
    net.PurchaseCS:getOrderPayload(getOrderPayloadCallBack)

end

-----------------------------------------------------------
-- 
-----------------------------------------------------------
function PurchaseGooglePlay:onOurPurchaseServerCallback(msg, argCallBack)

    if msg.result == 1000 then

        local itemsBuy = msg.purchaseItems
        local num = #itemsBuy
        local vipCount = 0
        local itemId = nil

        local model = app:getUserModel()

        for i = 1, num do
            
            local itemBuy=itemsBuy[i]
            vipCount = itemBuy.vipCount
            itemId = itemBuy.itemId
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

        --set spin count after buy
        initBuyCoinsPool()
        model:setSpincountafterbuy(0)
        model:serializeModel()

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
                EventMgr:dispatchEvent({name = EventMgr.UPDATE_PRODUCT_LIST})
            end

            --pig purchase
            if itemId == ITEM_TYPE.PIGGYBANK_MULITIPLE then
                EventMgr:dispatchEvent({name = EventMgr.PURCHASE_PBSUCCEED_EVENT})
                if argCallBack ~= nil then argCallBack() end
            else
                showResult()
                if argCallBack ~= nil then argCallBack() end
            end

        end} )

    elseif msg.result == 1002 then 
    elseif msg.result == 1003 then
    elseif msg.result == 1004 then
    end
end

return PurchaseGooglePlay
