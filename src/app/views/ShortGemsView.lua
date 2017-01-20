local SCV = class("ShortGemsView", function()
    return display.newNode()
end)

function SCV:ctor(args)
    self.viewNode  = CCBReaderLoad("view/shortofgems.ccbi",self)

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
end

function SCV:onBuy()
    self:onLater()
end

function SCV:onLater()
    if self.callback ~= nil then
        self.callback()
    end
    scn.ScnMgr.removeView(self)
end


function SCV:onEnter()
    core.displayEX.newButton(self.btn_buy)
    self.btn_buy.clickedCall = function()
        self:onBuy()
    end

    core.displayEX.newButton(self.btn_later)
    self.btn_later.clickedCall = function()
        self:onLater()
    end
end

function SCV:onExit()
    self:removeAllNodeEventListeners()
end

return SCV
