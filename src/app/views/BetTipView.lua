local BTV = class("BetTipView", function()
    return display.newNode()
end)

function BTV:ctor(args)
    self.viewNode  = CCBReaderLoad("view/bet_tip.ccbi",self)
    self:addChild(self.viewNode)
    self:setNodeEventEnabled(true)
    self.callback = args.callback
--    self:setTouchEnabled(true)
--    self:setTouchSwallowEnabled(true)
--    self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
--        if event.name == "began" then
--            return true
--        end
--    end)
end

function BTV:onEnter()
    core.displayEX.newButton(self.btn_OK)
    self.btn_OK.clickedCall = function()
        self.callback()
        scn.ScnMgr.removeView(self)
    end
    
    core.displayEX.newButton(self.btn_cancel)
    self.btn_cancel.clickedCall = function()
        scn.ScnMgr.removeView(self)
    end
end

function BTV:onExit()
    self:removeAllNodeEventListeners()
end

return BTV
