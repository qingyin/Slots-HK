local ProductCoinsCell = class("ProductCoinsCell", function()
    return display.newNode()
end)

-- message GCProduct {
--     required int32 prodId = 1;
--     required int32 gamePoint = 2;
--     required int32 promotions = 3;
--     required int32 totalGamePoint = 4;
--     required int32 iapId = 5;
--     optional int32 newIapId = 6;
--     required string price = 7;
--     optional string NewPrice = 8;
--     required string productType = 9;
--     required bool mostPopular = 10;
--     optional int32 adId = 11;
--     optional int32 timeLeft = 12;
--     optional int32 purchaseLimit = 13;
-- }

function ProductCoinsCell:ctor(prodInfo)

    -- print("ProductCoinsCell:")

    self.schEntryArray = {}
    self.scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
    self.rootNode  = CCBuilderReaderLoad(RES_CCBI.cashin_coins,self)
    self:addChild(self.rootNode)
    self.prodInfo = {}

    self.prodInfo.prodId            = prodInfo.prodId
    self.prodInfo.gamePoint         = prodInfo.gamePoint
    self.prodInfo.promotions        = prodInfo.promotions
    self.prodInfo.totalGamePoint    = prodInfo.totalGamePoint
    self.prodInfo.iapId             = prodInfo.iapId
    self.prodInfo.newIapId          = prodInfo.newIapId
    self.prodInfo.price             = prodInfo.price
    self.prodInfo.NewPrice          = prodInfo.NewPrice
    self.prodInfo.productType       = prodInfo.productType
    self.prodInfo.mostPopular       = prodInfo.mostPopular
    self.prodInfo.adId              = prodInfo.adId
    self.prodInfo.timeLeft          = prodInfo.timeLeft 
    self.prodInfo.purchaseLimit     = prodInfo.purchaseLimit
    self.prodInfo.oldIapProductId   = prodInfo.iapProductId
    -- self.prodInfo.iapProductId      = prodInfo.newIapProductId
    self.prodInfo.iapProductId      = prodInfo.iapProductId

    self.prodInfo.payPrice          = prodInfo.price

    local size = self.rootNode:getContentSize()

    self:setContentSize(size)


    self.totalLabel:setString(self.prodInfo.totalGamePoint)
    self.baseCoinLabel:setString(self.prodInfo.gamePoint)
    self.discountLabel:setString(tostring(self.prodInfo.promotions)..'%')
    self.oldPriceLabel:setString('$'..self.prodInfo.price)


    if self.prodInfo.adId ~= -1 then
        self.prodInfo.payPrice  = prodInfo.NewPrice
        self.prodInfo.finalIapId = prodInfo.newIapId
        self.newPriceLayer:setVisible(true)
        self.newPriceLabel:setVisible(true)
        self.newPriceLabel:setString('$'..self.prodInfo.NewPrice)
        self.discountLineSp:setVisible(true)
        self.prodInfo.iapProductId = prodInfo.newIapProductId
    else
        self.newPriceLayer:setVisible(false)
        self.prodInfo.finalIapId = prodInfo.iapId
        -- self.newPriceLabel:setVisible(false)
        self.discountLineSp:setVisible(false)
    end

    if self.prodInfo.purchaseLimit ~= -1 then
        -- print("self.prodInfo.purchaseLimit:", self.prodInfo.purchaseLimit)
        self.LimitedLayer:setVisible(true)
        self.purchaseLimitLabel:setVisible(true)
        self.purchaseLimitLabel:setString(self.prodInfo.purchaseLimit)
    else
        self.LimitedLayer:setVisible(false)
        self.purchaseLimitLabel:setVisible(false)
    end

    if self.prodInfo.timeLeft ~= -1 then
        -- print("self.prodInfo.timeLeft:", self.prodInfo.timeLeft)
        self:setTimer()
    else
        self.timerLayer:setVisible(false)
        self.timerLabel:setVisible(false)
    end
    
    --self.mostpopularSp:setVisible(self.prodInfo.mostPopular)
    

    self:addNodeEventListener(cc.NODE_EVENT, function(event)
        
        if event.name == "enter" then
            self:onEnter()
        elseif event.name == "exit" then
            self:onExit()
        end
    end)
end


function ProductCoinsCell:setTimer()

    self.timerLayer:setVisible(true)
    self.timerLabel:setString(' ')
    self.timerLabel:setVisible(true)
    
    local validTime = self.prodInfo.timeLeft

    --self.timerLabel:setString(SHMG.formatValidTimeToStr(validTime))

    local secTimer = 0
    function tick( dt )
        secTimer = secTimer + dt
        if secTimer >= 1 and validTime >= 1 then

            secTimer = 0
            validTime = validTime - 1
            self.timerLabel:setString(AdMgr.formatValidTimeToStr(validTime))

        elseif validTime <= 0 then

            self.isOnTimer = false
            self.scheduler.unscheduleGlobal(self.schEntryArray['LeftTime'])
            self.schEntryArray['LeftTime'] = nil
            self:updateAdTimeOut()
            -- self:onRemove()

        end

    end

    if validTime > 0 then
        self.schEntryArray['LeftTime'] = self.scheduler.scheduleGlobal(tick , 0)
    end
end


function ProductCoinsCell:updateAdTimeOut()
    self.prodInfo.adId = -1
    self.prodInfo.payPrice = self.prodInfo.price
    self.prodInfo.iapProductId = self.prodInfo.oldIapProductId
    self.discountLineSp:setVisible(false)
    self.newPriceLayer:setVisible(false)
    self.LimitedLayer:setVisible(false)
end


function ProductCoinsCell:onSelected(selected)
    self.selectedState:setVisible(selected)
    
    if selected == true then
        --AnimationModel.runAnimationByName(self.rootNode, "light")
    else
        --AnimationModel.runAnimationByName(self.rootNode, "normal")
    end

end

function ProductCoinsCell:onEnter()
end

function ProductCoinsCell:onExit()
    for k,v in pairs(self.schEntryArray) do
        if v ~= nil then 
            self.scheduler.unscheduleGlobal(v) 
        end
    end
end

return ProductCoinsCell
