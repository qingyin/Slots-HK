local SCV = class("ShortCoinsView", function()
    return display.newNode()
end)

function SCV:ctor(args)
    self:addChild(cc.LayerColor:create(cc.c4b(0, 0, 0, 200)))
    self.viewNode  = CCBReaderLoad("view/shortofcoins.ccbi",self)
    
    self:addChild(self.viewNode)
    self:setNodeEventEnabled(true)
    self:setTouchEnabled(true)
    self:setTouchSwallowEnabled(true)
    self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        if event.name == "began" then
            return true
        end
    end)

   self.callback = args.callback

   self.showContinue = args.showContinue

   self:registerEvent()

   if args.showContinue then
        self.laterBtn:setVisible(true)
        self.buyLabel:setVisible(false)
        self.continueLabel:setVisible(true)
    else
        self.buyLabel:setVisible(true)
        self.laterBtn:setVisible(false)
        self.continueLabel:setVisible(false)
    end
end

function SCV:registerEvent()
    core.displayEX.newButton(self.btn_buy) 
        :onButtonClicked(function(event)
            self:onBuy()
        end)

    self.laterBtn = core.displayEX.newButton(self.btn_later) 
        :onButtonClicked(function(event)
            self:onLater()
        end)
end

function SCV:onBuy()
    net.PurchaseCS:GetProductList(function(lists)
        scn.ScnMgr.popView("ProductsView",{productList=lists,tabidx=1})
        scn.ScnMgr.removeView(self)
    end)
end

function SCV:onLater()
    if self.callback ~= nil then
        self.callback()
    end
    scn.ScnMgr.removeView(self)
end


function SCV:onEnter()
end

function SCV:onExit()
    self:removeAllNodeEventListeners()
end

return SCV
