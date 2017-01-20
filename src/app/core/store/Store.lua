
local Store = class("Store")

Store.LOAD_PRODUCTS_FINISHED    = "LOAD_PRODUCTS_FINISHED"
Store.TRANSACTION_PURCHASED     = "TRANSACTION_PURCHASED"
Store.TRANSACTION_FAILED        = "TRANSACTION_FAILED"
Store.TRANSACTION_CANCEL        = "TRANSACTION_CANCEL"
Store.TRANSACTION_TIMEOUT       = "TRANSACTION_TIMEOUT"
Store.TRANSACTION_UNKNOWN_ERROR = "TRANSACTION_UNKNOWN_ERROR"

function Store:ctor()
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()

    self.provider = plugin.PluginManager:getInstance():loadPlugin("IOSIAP")
    self.provider:setDebugMode(true)
    --self.provider:callFuncWithParam("setServerMode")

    --self.provider.init(handler(self, self.transactionCallback))
    self.products = {}
end

function Store:canMakePurchases()
    --return self.provider.canMakePurchases()
    return true
end

function Store:loadProducts(productsId)
    print("---loadProducts:---",productsId)

    self.provider:setCallback(function(ret, productID)
        print("TestIAPScene:ctor",ret, productID)
        if ret == 1 then
            productID = nil
        end

        --local productsTable = json.decode(products)

        --table.dump(productsTable, "productsTable")

        self:dispatchEvent({
            name = Store.LOAD_PRODUCTS_FINISHED,
            productIdentifier = productID,
        })

    end)

    self.provider:callFuncWithParam("requestProducts", productsId)

end

function Store:getProductDetails(productId)
    local product = self.products[productId]
    if product then
        return clone(product)
    else
        return nil
    end
end

function Store:cancelLoadProducts()
    self.provider.cancelLoadProducts()
end

function Store:isProductLoaded(productId)
    return self.provider.isProductLoaded(productId)
end

function Store:purchaseProduct(productId)
    --self.provider.purchase(productId)
    -- kPaySuccess = 0,
    -- kPayFail,
    -- kPayCancel,
    -- kPayTimeOut,
    self.provider:payForProduct({productId = productId}, function(ret, receiptVal)
        --cclog("%d, %s", ret, products)

        print("receipt", receiptVal)

        if ret == 0 then
            print("onTransactionPurchased1")

            self:dispatchEvent({
                name = Store.TRANSACTION_PURCHASED,
                receipt = receiptVal,
            })
            EventMgr:dispatchEvent({name = EventMgr.UPDATE_PRODUCT_LIST})
        elseif ret == 1 then

            self:dispatchEvent({
                name = Store.TRANSACTION_FAILED,
                receipt = receiptVal,
            })
        elseif  ret == 2 then

            self:dispatchEvent({
                name = Store.TRANSACTION_CANCEL,
                receipt = receiptVal,
            })
        elseif  ret == 3 then

            self:dispatchEvent({
                name = Store.TRANSACTION_TIMEOUT,
                receipt = receiptVal,
            })
        else
            self:dispatchEvent({
                name = Store.TRANSACTION_UNKNOWN_ERROR,
                receipt = receiptVal,
            })
        end

    end)
end


return Store
