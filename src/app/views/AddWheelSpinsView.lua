
local AddWheelSpinsView = class("AddWheelSpinsView", function()
    --return display.newLayer()
    return core.displayEX.newSwallowEnabledNode()
end)

local ASV = AddWheelSpinsView
local Purchase = core.Purchase

function ASV:ctor(args)
    self:addChild(cc.LayerColor:create(cc.c4b(0, 0, 0, 200)))

    self.rootNode  = CCBuilderReaderLoad("view/addwheelspin.ccbi", self)
    self:addChild(self.rootNode)
    self:setTouchEnabled(true)
    self:setNodeEventEnabled(true)
    self:setTouchSwallowEnabled(true)
    self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        return true
    end)

    self.buyCallback = args.buyCallback
    self.isShowing = true

    local productList = args.productList
    if productList ~= nil then
        for i=1, #productList do
            if productList[i].productType == 'W' then
                self.prodInfo = productList[i]
                break
            end
        end
    end

    self.storeHandles = {}
    self:initStore()
    
end

function ASV:onCancel()
    self.isShowing = false
    scn.ScnMgr.removeView(self)
end

function ASV:onEnter()
    core.displayEX.newButton(self.okBtn) 
        :onButtonClicked(function(event)
            self:onBuy()
        end)

    core.displayEX.newButton(self.cancelBtn) 
        :onButtonClicked(function(event)
            self:onCancel()
        end)

end

function ASV:onExit()
    self:removeAllNodeEventListeners()

    --如果是ios
    if device.platform == "ios" then
        Purchase.store:removeEventListener(self.storeHandles[Purchase.store.LOAD_PRODUCTS_FINISHED])
        Purchase:removeEventListener(self.storeHandles[Purchase.store.TRANSACTION_PURCHASED])
        Purchase:removeEventListener(self.storeHandles[Purchase.store.TRANSACTION_FAILED])
        Purchase:removeEventListener(self.storeHandles[Purchase.store.TRANSACTION_UNKNOWN_ERROR])
    end

    if device.platform == "android" then
        EventMgr:removeEventListenersByEvent(EventMgr.PURCHASE_PBFAILED_EVENT)
    end
end

function ASV:initStore()
    --如果是ios
    if device.platform == "ios" then
        if not Purchase.store:canMakePurchases() then
            --device.showAlert("IAP Error", "canMakePurchases() == false", {"Please check project config"})
            return
        end
    end

    self.busy = false

    --如果是ios
    if device.platform == "ios" then
        self.storeHandles[Purchase.store.LOAD_PRODUCTS_FINISHED]     = Purchase.store:addEventListener(Purchase.store.LOAD_PRODUCTS_FINISHED,    handler(self, self.onLoadProductsFinished))
        self.storeHandles[Purchase.store.TRANSACTION_PURCHASED]      = Purchase:addEventListener(Purchase.store.TRANSACTION_PURCHASED,      handler(self, self.onTransactionPurchased))
        self.storeHandles[Purchase.store.TRANSACTION_FAILED]         = Purchase:addEventListener(Purchase.store.TRANSACTION_FAILED,         handler(self, self.onTransactionFailed))
        self.storeHandles[Purchase.store.TRANSACTION_UNKNOWN_ERROR]  = Purchase:addEventListener(Purchase.store.TRANSACTION_UNKNOWN_ERROR,  handler(self, self.onTransactionFailed))
    end

    if device.platform == "android" then
        EventMgr:addEventListener(EventMgr.PURCHASE_PBFAILED_EVENT, handler(self, self.purchaseGooglePlayFailed))
    end

end

function ASV:onBuy()
    
    core.Waiting.show()

    if self.prodInfo ~= nil then
        --如果是ios
        if device.platform == "ios" then
            Purchase.store:loadProducts(self.prodInfo.iapProductId)
        elseif device.platform == "android" then
            local args = {}
            args.productId = self.prodInfo.prodId
            args.adId = self.prodInfo.adId
            args.view = self
            if self.prodInfo.adId ~= -1 then
                args.iapId = self.prodInfo.newIapId
            else
                args.iapId = self.prodInfo.iapId
            end

            args.payPrice = self.prodInfo.payPrice
            local callback = function(callback)
                if self.buyCallback ~= nil then
                    self.buyCallback()
                end
                scn.ScnMgr.removeView(self)
            end
            args.removeViewCall=callback

            args.iapProductId = self.prodInfo.iapProductId
            Purchase:purchaseProductWithID(args)
        end
    end

end


function ASV:onLoadProductsFinished(event)
    if self.isShowing then
        self.busy = false

        if event.productIdentifier ~= nil then
            self:onPurchase(event.productIdentifier)
        else
            self:onCancel()
        end
    end

end

function ASV:onPurchase(productId)
    if self.busy then return end

    self.busy = true
    Purchase.store:purchaseProduct(productId)
end

function ASV:onTransactionPurchased(event)
    if self.prodInfo == nil then return end

    if self.isShowing then
        self.busy = false

        local args = {}

        args.receipt = event.receipt
        args.productId = self.prodInfo.prodId
        args.adId = self.prodInfo.adId
        args.view = self

        if self.prodInfo.adId ~= -1 then
            args.iapId = self.prodInfo.newIapId
        else
            args.iapId = self.prodInfo.iapId
        end

        args.payPrice = self.prodInfo.payPrice

        local callback = function(callback)

            if self.buyCallback ~= nil then
                self.buyCallback()
            end
            scn.ScnMgr.removeView(self)

        end
        args.callBack = callback

        net.PurchaseCS:IosPurchase(args) 
    end
end

function ASV:onTransactionFailed(event)
    if self.isShowing then
        self.busy = false
        core.Waiting.hide()

        scn.ScnMgr.addView("CommonView",
            {
                title="Purchase Failed",
                content="Please try again for purchasing!",
                callback=function()
                    self:onCancel()
                end
            })
    end

end

function ASV:purchaseGooglePlayFailed()
    if self.isShowing then
        self.busy = false
        core.Waiting.hide()

        self:onCancel()
    end
end

return AddWheelSpinsView
