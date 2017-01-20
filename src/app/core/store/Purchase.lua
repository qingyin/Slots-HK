local Store = require("app.core.store.Store")

local Purchase = class("Purchase")
local intancne

function Purchase:ctor()
    
    print("Purchase:ctor")
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()

    self.store = Store.new()

    self.store:addEventListener(Store.TRANSACTION_PURCHASED,     handler(self, self.onTransactionPurchased))
    self.store:addEventListener(Store.TRANSACTION_FAILED,        handler(self, self.onTransactionFailed))
    self.store:addEventListener(Store.TRANSACTION_TIMEOUT,       handler(self, self.onTransactionTimeout))
    self.store:addEventListener(Store.TRANSACTION_UNKNOWN_ERROR, handler(self, self.onTransactionUnknownError))

end

function Purchase:exit()
    self.store:removeAllEventListeners()
end

function Purchase:onTransactionPurchased(event)

    print("onTransactionPurchased2")

    self:dispatchEvent(event)

end

function Purchase:onTransactionFailed(event)
    -- local transaction = event.transaction
    -- local msg = string.format("errorCode = %s\nerrorString = %s",
                              -- tostring(transaction.errorCode),
                              -- tostring(transaction.errorString))
    
    --device.showAlert("IAP Purchased", msg, {"OK"})
    --SCNM.popView("CommonView",{title="IAP Purchased", content=msg})
    print("Purchase:onTransactionFailed")

    self:dispatchEvent(event)
end


function Purchase:onTransactionTimeout(event)
    --device.showAlert("IAP Error", "Unknown error", {"OK"})
    self:dispatchEvent(event)
end

function Purchase:onTransactionUnknownError(event)
    --device.showAlert("IAP Error", "Unknown error", {"OK"})
    self:dispatchEvent(event)
end

return Purchase
