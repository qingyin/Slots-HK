local DefaultAdView = class("DefaultAdView", function()
    return display.newNode() --ViewExtend.extend(CCLayer:create())
end)

local Purchase = core.Purchase
local Store = Purchase.store
local Waiting = core.Waiting

------------------------------------------------
--
-- adInfo: 
-- adInfo.adId
-- adInfo.iapId
-- adInfo.prodId
-- adInfo.templateId
-- adInfo.startTm
-- adInfo.endTm
-- adInfo.timeLeft
--
------------------------------------------------
function DefaultAdView:ctor(adInfo)

    -- ViewExtend.extend(self)

    self.schEntryArray = {}
    self.scheduler = require(cc.PACKAGE_NAME .. ".scheduler")

    self.adInfo = {}

    self.adInfo.adId            = adInfo.adId
    self.adInfo.endTm           = adInfo.endTm
    self.adInfo.startTm         = adInfo.startTm
    self.adInfo.prodId          = adInfo.prodId
    self.adInfo.iapId           = adInfo.iapId
    self.adInfo.price           = adInfo.price
    self.adInfo.newPrice        = adInfo.newPrice
    self.adInfo.timeLeft        = adInfo.timeLeft 
    self.adInfo.totalGamePoint  = adInfo.totalGamePoint
    self.adInfo.purchaseLimit   = adInfo.purchaseLimit
    self.adInfo.iapProductId    = adInfo.iapProductId
    self.adInfo.template        = adInfo.template
    self.adInfo.payPrice        = adInfo.price
    self.adInfo.discount        = adInfo.discount

    local fileFam = '.ccbi'
    local prePath = 'lobby/ad/'
    local ccbName = self.adInfo.template.ccbName

    local fullPath = cc.FileUtils:getInstance():fullPathForFilename(prePath..ccbName..fileFam)
    local ccbExist = cc.FileUtils:getInstance():isFileExist(fullPath)

    -- print("fullPath:", fullPath)
    -- print("ccbExist:", ccbExist)

    if not ccbExist then
        ccbName = self.adInfo.template.defaultCcb
    end

    print("prePath..ccbName:", prePath..ccbName)

    self.viewNode = CCBuilderReaderLoad(prePath..ccbName, self)

    self.viewNode:setAnchorPoint(0.5, 0.5)
    self.viewNode:ignoreAnchorPointForPosition(false)

    self:addChild(self.viewNode)

    self:setTouchEnabled(true)
    self:setNodeEventEnabled(true)
    self:setTouchSwallowEnabled(false)
    self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)

        -- print("lllll:", event.name)
        return true--self:onTouch(event.name, event.x, event.y)
    end)

   
    self:init()

end


---------------------------------
-- init 
---------------------------------
function DefaultAdView:init()

    -- initActiveTimer
    self:initActiveTime()

    -- initLeftTimer
    self:initLeftTime()

    -- init PurchaseLimit
    self:initPurchaseLimit()

    -- init JumpBtn
    self:initJumpBtn()

    -- init showBuyBtn
    self:initBuyBtn()

    -- init coin
    self:initCoin()

    -- init discount
    self:initDiscount()

end

---------------------------------
-- initDiscount 
---------------------------------
function DefaultAdView:initDiscount()
    if not self.adInfo.discount or not self.percentage then
        return
    end
    self.percentage:setString(self.adInfo.discount)
end

---------------------------------
-- initCoin 
---------------------------------
function DefaultAdView:initCoin()
    if self.adInfo.iapId == -1 or self.adInfo.productId == -1 then
        return
    end

    self.adInfo.payPrice = self.adInfo.newPrice

    self.priceOriginalLabel:setString('$'..number.commaSeperate(self.adInfo.price))
    self.priceDiscountLabel:setString('$'..number.commaSeperate(self.adInfo.newPrice))
    self.coinsNumberLabel:setString(number.commaSeperate(self.adInfo.totalGamePoint))

end

---------------------------------
-- initActiveTimer 
---------------------------------
function DefaultAdView:initActiveTime()
    if self.adInfo.template.showActiveTime == true then
        self.activeTimeLayer:setVisible(true)
        local lifeTime = tostring(self.adInfo.startTm)
                ..'To'..tostring(self.adInfo.endTm)
        self.activeTimeLabel:setString(lifeTime)

    else
        if self.activeTimeLayer then self.activeTimeLayer:setVisible(false) end
    end
end

---------------------------------
-- initLeftTimer 
---------------------------------
function DefaultAdView:initLeftTime()
    if self.adInfo.template.showLeftTime == true then

        self.leftTimeText:setVisible(true)
        self.leftTimeLayer:setVisible(true)
        self.leftTimeLabel:setVisible(true)
        self.leftTimeLabel:setString(' ')

        local validTime = self.adInfo.timeLeft

        local secTimer = 0
        function tick( dt )
            -- print("dt")
            secTimer = secTimer + dt

            if secTimer >= 1 and validTime >= 1 then
                    
                secTimer = 0
                validTime = validTime - 1
                -- print("validTime:", validTime)
                self.leftTimeLabel:setString(AdMgr.formatValidTimeToStr(validTime))

            elseif validTime <= 0 then

                self.isOnTimer = false
                self.scheduler.unscheduleGlobal(self.schEntryArray['LeftTime'])
                self.schEntryArray['LeftTime'] = nil
                self:onRemove()

            end

        end

        if validTime > 0 then
            self.schEntryArray['LeftTime'] = self.scheduler.scheduleGlobal(tick , 0)
        end

    else
        if self.leftTimeLayer then  self.leftTimeLayer:setVisible(false) end
    end
end

---------------------------------
-- initPurchaseLimit 
---------------------------------
function DefaultAdView:initPurchaseLimit()
    if self.adInfo.template.showPurchaseLimit == true then
        self.purchaseLimitLabel:setVisible(true)
        self.purchaseLimitLabel:setString(self.adInfo.purchaseLimit)
    else
        if self.purchaseLimitLabel then self.purchaseLimitLabel:setVisible(false) end
    end
end

---------------------------------
-- initJumpBtn
---------------------------------
function DefaultAdView:initJumpBtn()
    if self.adInfo.template.showJumpBtn == true then

        local onJump = function ()
            -- print("on jumpBtnEVN")
            local jumpBtnEVN = self.adInfo.template.jumpBtnEVN

            if jumpBtnEVN == AdMgr.EVN.CASIN then
                SHMG.showProductsView({onShowProdId = self.adInfo.prodId})
                AdMgr.closeAdListView()
            elseif jumpBtnEVN == AdMgr.EVN.FANSPAGE then
                device.openURL(FANS_PAGE_URL)
            end
            
        end

        -- print("jumpBtnEVN:", self.jumpBtn, onJumpBtnEVN)

        self.jumpBtn:setVisible(true)
        core.displayEX.newButton(self.buyBtn)
            :onButtonClicked(onJump)
        -- self:registBtnEvent(self.jumpBtn, onJumpBtnEVN)

    else

        if self.jumpBtn then self.jumpBtn:setVisible(false) end

    end
end

---------------------------------
-- initBuyBtn
---------------------------------
function DefaultAdView:initBuyBtn()
    if self.adInfo.template.showBuyBtn == true then

        self:initStoreEvn()
        local onbuy = function() 

             print("self.adInfo.iapProductId:", self.adInfo, self.adInfo.iapProductId)
             print("self.busy:", self.busy)

            if self.busy == true then return end

            if device.platform == "ios" then
                self.storeHandles = {}
                self.storeHandles[Store.LOAD_PRODUCTS_FINISHED]     = Purchase.store:addEventListener(Store.LOAD_PRODUCTS_FINISHED,    self.onLoadProductsFinished,    self)
                self.storeHandles[Store.TRANSACTION_PURCHASED]      = Purchase:addEventListener(Store.TRANSACTION_PURCHASED,     self.onTransactionPurchased,    self)
                self.storeHandles[Store.TRANSACTION_FAILED]         = Purchase:addEventListener(Store.TRANSACTION_FAILED,        self.onTransactionFailed,       self)
                self.storeHandles[Store.TRANSACTION_UNKNOWN_ERROR]  = Purchase:addEventListener(Store.TRANSACTION_UNKNOWN_ERROR, self.onTransactionFailed,       self)
            end

             if tonumber(self.adInfo.adId) == 7 then
                 EventMgr:dispatchEvent({name = EventMgr.UPDATE_TOP_DEAL_EVENT})
             end

            if device.platform == "ios" then
                --local store_products = {}
                --store_products[#store_products + 1]=self.adInfo.iapProductId
                --Purchase.store:loadProducts(store_products)
                Purchase.store:loadProducts(self.adInfo.iapProductId)
            elseif device.platform == "android" then

                local args = {}
                args.productId = self.adInfo.prodId
                args.adId = self.adInfo.adId
                args.view = self
                args.iapId = self.adInfo.iapId
                args.payPrice = self.adInfo.payPrice
                args.removeViewCall=function()
                        -- User.setProperty(User.KEY_NPSPURCHASED,true, true)
                        -- DataReport:report()
                        AdMgr.closeAdListView()
                end
                args.iapProductId = self.adInfo.iapProductId
                Purchase:purchaseProductWithID(args)
            end
        end

        self.buyBtn:setVisible(true)
        core.displayEX.newButton(self.buyBtn)
        :onButtonClicked(onbuy)

    else

        if self.buyBtn then self.buyBtn:setVisible(false) end

    end
end

---------------------------------
-- onRemove
---------------------------------
function DefaultAdView:onRemove()
    AnimationUtil.ExitScale(self.viewNode, 0.3,function()
        --self:removeView()
        --self:removeFromParent(true)
        AdMgr.closeAdListView()
    end)
end

---------------------------------
-- onTouch
---------------------------------
function DefaultAdView:onTouch(event, x, y)
    print("DefaultAdView:onTouch--")
    if event == "began" then
        self:onPress(event, x, y)
    elseif event == "moved" then
    elseif event == "ended" then
        self:onRelase(event, x, y)
    else
    end

    return true
end

---------------------------------
-- initStoreEvn
---------------------------------
function DefaultAdView:initStoreEvn()
    if device.platform == "ios" then
        if not Purchase.store:canMakePurchases() then
            device.showAlert("IAP Error", "appStore cennect faild", {"Please try agin!"})
            return
        end
    end
    
    self.busy = false

end

---------------------------------
-- onLoadProductsFinished
---------------------------------
function DefaultAdView:onLoadProductsFinished(event)

    Waiting.hide()
    self.busy = false

    if event.productIdentifier ~= nil then

        self:onPurchase(event.productIdentifier)

    else
        device.showAlert("IAP ERROR", "Load Products Error", "OK")
        Waiting.hide()
        -- self:removeView()
    end

end

---------------------------------
-- onPurchaseClicked
---------------------------------
function DefaultAdView:onPurchase(productId)
    if self.busy then return end

    self.busy = true
    Waiting.show()

    Purchase.store:purchaseProduct(productId)
end

---------------------------------
-- onTransactionPurchased
---------------------------------
function DefaultAdView:onTransactionPurchased(event)
    print("DefaultAdView:onTransactionPurchased")
    if self.adInfo == nil then return end

    self.busy = false
    --Waiting.hide()

    print("onTransactionPurchased3")

    local args = {}

    args.receipt = event.receipt
    args.productId = self.adInfo.prodId
    args.adId = self.adInfo.adId
    args.view = self
    args.iapId = self.adInfo.iapId
    args.payPrice = self.adInfo.payPrice


    args.callBack = function()  AdMgr.closeAdListView() end


    --PurchaseReport:reportPurchase(args) 

    -- if self.adInfo.showRule.showPurchaseLimit == true then

    --     self.adInfo.purchaseLimit = self.adInfo.purchaseLimit - 1
    --     self.purchaseLimitLabel:setVisible(true)
    --     self.purchaseLimitLabel:setString(self.adInfo.purchaseLimit)
        
    -- end

    print("onTransactionPurchased4")

    net.PurchaseCS:IosPurchase(args) 

    self:removeStoreEvn()

end

---------------------------------
-- onTransactionFailed
---------------------------------
function DefaultAdView:onTransactionFailed(event)

    self:removeStoreEvn()

    self.busy = false
    Waiting.hide()

end

---------------------------------
-- removeStoreEvn
---------------------------------
function DefaultAdView:removeStoreEvn()
    if device.platform == "ios" and self.storeHandles then
        Purchase.store:removeEventListener(Store.LOAD_PRODUCTS_FINISHED,  self.storeHandles[Store.LOAD_PRODUCTS_FINISHED])
        Purchase:removeEventListener(Store.TRANSACTION_PURCHASED,  self.storeHandles[Store.TRANSACTION_PURCHASED])
        Purchase:removeEventListener(Store.TRANSACTION_FAILED,  self.storeHandles[Store.TRANSACTION_FAILED])
        Purchase:removeEventListener(Store.TRANSACTION_UNKNOWN_ERROR,  self.storeHandles[Store.TRANSACTION_UNKNOWN_ERROR])
    end
end

---------------------------------
-- onEnter
---------------------------------
function DefaultAdView:onEnter()
    AnimationUtil.EnterScale(self.viewNode, 0.3)
end

---------------------------------
-- onExit
---------------------------------
function DefaultAdView:onExit()
    
    for k,v in pairs(self.schEntryArray) do
        if v ~= nil then 
            self.scheduler.unscheduleGlobal(v) 
        end
    end

    self:removeStoreEvn()
    self:removeAllNodeEventListeners()

end

return DefaultAdView