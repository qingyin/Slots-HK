local ProductCoinsCell = require("app.views.ProductCoinsCell")
local ProductGemsCell = require("app.views.ProductGemsCell")

local ProductsView = class("ProductsView", function()
    return core.displayEX.newSwallowEnabledNode()
end)

local PDV = ProductsView
local Purchase = core.Purchase

function PDV:ctor(args)
    self.touchlayer = display.newColorLayer(cc.c4b(0, 0, 0, 200))
    self:addChild(self.touchlayer)
    self.touchlayer:setTouchSwallowEnabled(false)

    self.viewNode  = CCBuilderReaderLoad(RES_CCBI.cashin, self)
    self:addChild(self.viewNode)

    self.cells = {}
    self.storeHandles = {}
    self.tabidx = args.tabidx
    self.pdidx = 3

    self.isShowing = true

    self:addNodeEventListener(cc.NODE_TOUCH_EVENT,  function(event) 
        return self:onTouch(event)  
    end)

    self:addNodeEventListener(cc.NODE_EVENT, function(event)
        
        if event.name == "enter" then
            self:onEnter()
        elseif event.name == "exit" then
            self:onExit()
        elseif event.name == "cleanup" then
            self:removeAllEventListeners()
        end
    end)
    
    AnimationUtil.setContentSizeAndScale(self.viewNode)

    self.productList = args.productList

    self.onShowProdId = args.onShowProdId

    if self.onShowProdId then
        self:initShowIndex()
    end
       
    local vipinfo = DICT_VIP[tostring(app:getUserModel():getVipLevel())]
    
    local strName = "Bronze"
    local vipBenifit = "10"
    if vipinfo ~= nil then
        strName = vipinfo.alias
        vipBenifit = vipinfo.extra_coins_percent
    end
    vipBenifit = vipBenifit.."%"

    self.vipName:setString(strName)
    self.vipGain:setString(vipBenifit)
    
    self:registerUIEvent()

    self:initStore()
end


function PDV:initShowIndex()
    
    local productType
    for i=1, #self.productList do
        if self.productList[i].prodId == self.onShowProdId then
            productType = self.productList[i].productType
            break
        end
    end

    if productType == 'C' then
        self.tabidx = 1
    elseif productType == 'G' then
        self.tabidx = 2
    end

    local pdidx = 0
    for i=1, #self.productList do
        if self.productList[i].productType == productType then
            pdidx = pdidx + 1
        end
        if self.productList[i].prodId == self.onShowProdId then
            self.pdidx = pdidx
            break
        end
    end

end

function PDV:initStore()
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
    
    self.coins_products = {}


    self.selectedProduct = nil
    self.hasselectedTab = nil
    self.tabBtns = {}

    --self.coinsPanel.btn=self.coinsTabBtn

    self.coinsPanel.buybtn=self.coinsBuyBtn

    self.tabBtns[#self.tabBtns + 1] = self.coinsPanel


    self:initCoinsPanel()


    self.activeTab=self.coinsPanel

    self:tabBtn(self.activeTab)
    self:initSelectCell(self.pdidx)

end

function PDV:tabBtn(btnObj)
    
    if self.hasselectedTab ~= btnObj then
        self.hasselectedTab = btnObj
        self:initSelectCell(self.pdidx)
    end

end

function PDV:registerUIEvent()

    core.displayEX.newSmallButton(self.exitBtn) 
        :onButtonClicked(function(event)
            -- body
            self:onRemove()
        end)



    core.displayEX.newButton(self.coinsBuyBtn) 
        :onButtonClicked(function(event)
            -- body
            self:onBuy()
        end)

    EventMgr:addEventListener(EventMgr.UPDATE_PRODUCT_LIST,handler(self,self.updateProductList))
end

function PDV:onTouch(event)

    if event.name == "began" then
        self:onTouchCells(event, event.x, event.y)

    elseif event.name == "moved" then

    elseif event.name == "ended" then

    else -- cancelled

    end

    return true
end

function PDV:selectedCell(btnObj, selected)

    local cells = self.coins_products

    for i=1,#cells do
        local cell = cells[i]
        if cell == btnObj then
            cell:onSelected(selected)
        else
            cell:onSelected(false)
        end
    end

end


function PDV:initCoinsPanel()
    local products = nil
    --ios和 android模式取不同的产品列表
    if device.platform == "android" then
        products=string.split(DICT_PRODUCT_AUTH[ANDROID_APP_ID].product_ids, ",")
    elseif device.platform == "ios" then
        products=string.split(DICT_PRODUCT_AUTH[IOS_APP_ID].product_ids, ",")
    end

    local coinsSize = self.coinsCellsNode:getContentSize()
        
    local startX = coinsSize.width/2;
    local startY = coinsSize.height;
    local index = 1
    
    -- print("coins count:", #products)
    -- for i=1,#products do
    -- local dicIAP=DICT_PRODUCT[tostring(products[#products - i + 1])]

    self.coinsCellsNode:removeAllChildren()
    for i=1,#self.productList do

        local dicIAP=self.productList[i]

        if dicIAP.productType == "C" then

            local cell = ProductCoinsCell.new(dicIAP)

            self.coins_products[#self.coins_products + 1] = cell
            local size = cell:getContentSize()

            cell:setPosition(startX - size.width / 2, startY - size.height * (index) )
            self.coinsCellsNode:addChild(cell)
                        
            index = index + 1

        end
    end

end


function PDV:showPanel()
    --transition.moveTo(self.rootNode, {time = 0.5, x = self.endX, easing = "BACKOUT"})
end

function PDV:onTouchCells(event, x, y)
    local pos = cc.p(x, y)

    local cells = self.coins_products

    if cells == nil then return end

    for i=1,#cells do
        local cell = cells[i]
        local boundingBox = cell:getCascadeBoundingBox();

        if boundingBox:containsPoint(pos) then
            print(i, event.name, event.x, event.y)
            self:selectedCell(cell, true)
            self.selectedProduct = cell
            return true
        end
    end

end

function PDV:initSelectCell(idx)

    local cells = self.coins_products

    if cells == nil then return end

    for i=1,#cells do
        local cell = cells[i]

        if i == idx then
            self:selectedCell(cell, true)
            self.selectedProduct = cell
            return true
        end
    end

end

function PDV:onRemove()
    self.isShowing = false
    scn.ScnMgr.removeView(self)
end

function PDV:onGemsTab()
    self.activeTab = self.gemsPanel
end

function PDV:onCoinsTab()
    self.activeTab = self.coinsPanel
end

function PDV:onBoostsTab()
    --self.activeTab = self.boostsPanel
end

function PDV:onBuy()
    
    core.Waiting.show()

    if self.selectedProduct ~= nil then
        if self.activeTab == self.boostsPanel then
            local needgem = tonumber(self.selectedProduct.product.cost_gems)
            local gem = tonumber(app:getUserModel():getGems())
            
            if gem >= needgem then
                local viewnode =scn.ScnMgr.addView(
                    "CommonView",{title="Exchange Succeed", content="Good luck and have fun.",
                    delayPopCall=function()
                        
                        --User.setProperty(User.KEY_TOTALGEMS,gem-needgem)
                        
                        local key   = self.selectedProduct.product.item_id
                        local count = self.selectedProduct.product.count
                        print(key, count)
                        --User.Items.addItem(key, count, true)
                        --User.save()
                    end}
                )
                self:addChild(viewnode)

            else
                local viewnode =scn.ScnMgr.addView(
                    "CommonView",{title="Not Enough Gems", content="Please Buy More Gems.",
                    delayPopCall=function()
                        self.activeTab = self.gemsPanel
                        self:tabBtn(self.gemsPanel)
                        self:initSelectCell(self.pdidx)
                    end}
                )
                self:addChild(viewnode)

            end
        else
            if tonumber(self.selectedProduct.prodInfo.adId) == 7 then
                EventMgr:dispatchEvent({name = EventMgr.UPDATE_TOP_DEAL_EVENT})
            end
            --如果是ios
            if device.platform == "ios" then
                Purchase.store:loadProducts(self.selectedProduct.prodInfo.iapProductId)
            elseif device.platform == "android" then
                local args = {}
                args.productId = self.selectedProduct.prodInfo.prodId
                args.adId = self.selectedProduct.prodInfo.adId
                args.iapId = self.selectedProduct.prodInfo.finalIapId
                args.payPrice = self.selectedProduct.prodInfo.payPrice
                args.iapProductId = self.selectedProduct.prodInfo.iapProductId
                Purchase:purchaseProductWithID(args)
            end
        end
    end

end

function PDV:onEnter()
end

function PDV:onExit()    
    --如果是ios
    if device.platform == "ios" then
        Purchase.store:removeEventListener(self.storeHandles[Purchase.store.LOAD_PRODUCTS_FINISHED])
        Purchase:removeEventListener(self.storeHandles[Purchase.store.TRANSACTION_PURCHASED])
        Purchase:removeEventListener(self.storeHandles[Purchase.store.TRANSACTION_FAILED])
        Purchase:removeEventListener(self.storeHandles[Purchase.store.TRANSACTION_UNKNOWN_ERROR])
    end
    EventMgr:removeEventListenersByEvent(EventMgr.UPDATE_PRODUCT_LIST)
end

function PDV:onLoadProductsFinished(event)
    if self.isShowing then
        self.busy = false

        if event.productIdentifier ~= nil then
            self:onPurchase(event.productIdentifier)
        else
            self:onRemove()
        end
    end

end

function PDV:onPurchase(productId)
    if self.busy then return end

    self.busy = true
    Purchase.store:purchaseProduct(productId)
end

function PDV:onTransactionPurchased(event)
    if self.selectedProduct.prodInfo == nil then return end

    if self.isShowing then

        self.busy = false

        local args = {}

        args.receipt = event.receipt
        args.productId = self.selectedProduct.prodInfo.prodId
        args.adId = self.selectedProduct.prodInfo.adId
        args.view = self
        args.iapId = self.selectedProduct.prodInfo.finalIapId
        args.payPrice = self.selectedProduct.prodInfo.payPrice

        net.PurchaseCS:IosPurchase(args) 
    end
end

function PDV:onTransactionFailed(event)
    if self.isShowing then
        self.busy = false
        core.Waiting.hide()
    end
end

function PDV:updateProductList()
    if tonumber(self.selectedProduct.prodInfo.purchaseLimit) ~= 1 then
        return
    end
    net.PurchaseCS:GetProductList(function(lists)
        self.productList = lists
        self:initStore()
    end)
end


return ProductsView
