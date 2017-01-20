local PigBonusView = class("PigBonusView", function()
    return core.displayEX.newSwallowEnabledNode()
end)

local Purchase = core.Purchase

function PigBonusView:ctor(args)
    self:addChild(display.newColorLayer(cc.c4b(0, 0, 0, 200)))

    self.viewNode  = CCBuilderReaderLoad(RES_CCBI.pig, self)

    self:addChild(self.viewNode)
    self:setNodeEventEnabled(true)

    self.actionNode = display.newNode()
    self:addChild(self.actionNode)

    local size = self.shine:getContentSize()
    local coref = (display.height)/size.height
    self.viewNode:setScale(coref)

    local productList = args.productList
    for i=1, #productList do
        if productList[i].productType == 'P' then
            self.prodInfo = productList[i]
            break
        end
    end

    self.isShowing = true
    self.isAnimation = false

    -------------------------------------------------------
    if device.platform == "ios" then
        self.accelerate = cc.Layer:create()
        self:addChild(self.accelerate)
        
        local function didAccelerate(x,y,z,timestamp)
            local value = 1
            if math.floor(x) > value or math.floor(y) > value or math.floor(z) > value then
                --print(x,y,z,timestamp)
                if self.isAnimation == false then
                    self:initArrayActions()
                end
            end
        end
        self.accelerate:registerScriptAccelerateHandler(didAccelerate)
        self.accelerate:setAccelerometerEnabled(true)
    elseif device.platform == "android" then
        local callback = function(flag)
            if self.isAnimation == false then
                self:initArrayActions()
            end
        end

        local phone=ShakePhone:sharedShakePhone()
        phone:setShakePhoneListenerLua(callback)
    end
    -------------------------------------------------------

    self.storeHandles = {}

    self:registerEvent()
    self:initUI()
end

function PigBonusView:registerEvent()

    -- on close
    core.displayEX.newSmallButton(self.exitBtn) 
        :onButtonClicked(function(event)
            if self.isAnimation == false then
                self:onRemove()
            end
        end)

    self.buyBtn = core.displayEX.newButton(self.breakBtn) 
        :onButtonClicked(function(event)
            self:initArrayActions()
            
        end)

    if device.platform == "android" then
        EventMgr:addEventListener(EventMgr.PURCHASE_PBSUCCEED_EVENT, handler(self, self.purchasePiggyBankSucceed2))
        EventMgr:addEventListener(EventMgr.PURCHASE_PBFAILED_EVENT, handler(self, self.purchasePiggyBankFailed))
    end
end

function PigBonusView:initUI()

    self:initStore()

    local model = app:getUserModel()
    local cls   =   model.class
    local properties = model:getProperties({cls.piggyBank})

    local coins = properties[cls.piggyBank]
    self.coinsLabel:setString(tostring(coins))
end

--------------------------------------
-- runWinAnimation 
--------------------------------------
function PigBonusView:runPigAnimation( name )

    local acName = name
    local animationMgr = self.viewNode.animationManager

    -- local flag = animationMgr:getSequenceId('win')

    -- if flag ~= -1 then
    --     acName = 'win'
    -- end

    self:runAnimationByName(acName)

end

--------------------------------------
-- runAnimationByName 
--------------------------------------
function PigBonusView:runAnimationByName( name )

    local animationMgr = self.rootNode.animationManager
    animationMgr:runAnimationsForSequenceNamed(name)

    return true
end


function PigBonusView:initStore()
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

end

function PigBonusView:onEnter()
end

function PigBonusView:onExit()    
    --如果是ios
    if device.platform == "ios" then
        Purchase.store:removeEventListener(self.storeHandles[Purchase.store.LOAD_PRODUCTS_FINISHED])
        Purchase:removeEventListener(self.storeHandles[Purchase.store.TRANSACTION_PURCHASED])
        Purchase:removeEventListener(self.storeHandles[Purchase.store.TRANSACTION_FAILED])
        Purchase:removeEventListener(self.storeHandles[Purchase.store.TRANSACTION_UNKNOWN_ERROR])
    end

    if device.platform == "android" then
        EventMgr:removeEventListenersByEvent(EventMgr.PURCHASE_PBSUCCEED_EVENT)
        EventMgr:removeEventListenersByEvent(EventMgr.PURCHASE_PBFAILED_EVENT)
    end
end

function PigBonusView:onRemove()
    self.isShowing = false
    if self.accelerate ~= nil then
        self.accelerate:unregisterScriptAccelerateHandler()
        self.accelerate:setAccelerometerEnabled(false)
    end

    scn.ScnMgr.removeView(self)
end

-----------------------------------------------------------
-- purchasePiggyBankSucceed
-----------------------------------------------------------
function PigBonusView:purchasePiggyBankSucceed(callback)
    local actions = {}

    local broken = function()
        self.buyBtn:setButtonEnabled(false)
        local model = app:getUserModel()
        local coins = model:getPiggyBank()
        self.coinsLabel:setString(tostring(coins))

        self:runPigAnimation("run")
    end

    local function onFinish()
        pcall(callback)
    end

    local flyCoins_ = function()
        self:flyCoins()
    end

    actions[#actions+1] = cc.CallFunc:create(broken)
    actions[#actions+1] = cc.DelayTime:create(3)
    actions[#actions+1] = cc.CallFunc:create(onFinish)
    actions[#actions+1] = cc.CallFunc:create(flyCoins_)

    local sq = transition.sequence(actions)
    self.actionNode:runAction(sq)   
end


-----------------------------------------------------------
-- purchasePiggyBankSucceed2
-----------------------------------------------------------
function PigBonusView:purchasePiggyBankSucceed2()
    self:purchasePiggyBankSucceed(print)
end

-----------------------------------------------------------
-- purchasePiggyBankFailed
-----------------------------------------------------------
function PigBonusView:purchasePiggyBankFailed()
    self:restore()
end

-----------------------------------------------------------
-- initArrayActions
-----------------------------------------------------------
function PigBonusView:initArrayActions()
    local actions = {}

    local burst = function()
        self.isAnimation = true
        self:runPigAnimation("crackle")
    end

    local buy_ = function()
        self:onBuy()
    end

    actions[#actions+1] = cc.CallFunc:create(burst)
    actions[#actions+1] = cc.DelayTime:create(1)
    actions[#actions+1] = cc.CallFunc:create(buy_)

    local sq = transition.sequence(actions)
    self.actionNode:runAction(sq)   
end

function PigBonusView:restore()
    self.isAnimation = false
    self:runPigAnimation("idle")
end


function PigBonusView:flyCoins()
    local handle = audio.playSound(RES_AUDIO.fly_coins, false)
    local callback = function()
        audio.stopSound(handle) 
        EventMgr:dispatchEvent({name = EventMgr.UPDATE_LOBBYUI_EVENT})
        self:onRemove()
    end
    --AnimationUtil.MoveTo("gold.png",10,self.coinsLabel, app.coinSprite,callback)
    AnimationUtil.flyTo("gold.png",10,self.coinsLabel, app.coinSprite)
    self:performWithDelay(callback, 1.5)
end

function PigBonusView:onBuy()
    
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
            args.removeViewCall=nil
            args.iapProductId = self.prodInfo.iapProductId
            Purchase:purchaseProductWithID(args)
        end
    end

end

function PigBonusView:onLoadProductsFinished(event)
    if self.isShowing then
        self.busy = false

        if event.productIdentifier ~= nil then
            self:onPurchase(event.productIdentifier)
        else
            self:onRemove()
        end
    end

end

function PigBonusView:onPurchase(productId)
    if self.busy then return end

    self.busy = true
    Purchase.store:purchaseProduct(productId)
end

function PigBonusView:onTransactionPurchased(event)
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
            self:purchasePiggyBankSucceed(callback)
        end
        args.callBack = callback

        net.PurchaseCS:IosPurchase(args) 
    end
end

function PigBonusView:onTransactionFailed(event)
    if self.isShowing then
        self.busy = false
        core.Waiting.hide()
        self:restore()
    end
end

return PigBonusView