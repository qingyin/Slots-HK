--声明 RateTaskView 类
local RateTaskView = class("RateTaskView", function()
    return display.newLayer()
end)

function RateTaskView:ctor(args)

    self.viewNode  = CCBuilderReaderLoad("view/rate.ccbi",self)
    self:addChild(self.viewNode)

    self:setTouchEnabled(true)
    self:setNodeEventEnabled(true)
    self:setTouchSwallowEnabled(true)
    self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        return true
    end)
    
    self.args=args

end

function RateTaskView:onLater()
    scn.ScnMgr.removeView(self)
end

function RateTaskView:onOK()

    --User.Tasks.finishSpecialTask(self.args.value)
    
    --CCAccountManager:downloadNewApp()
    scn.ScnMgr.removeView(self)

end

function RateTaskView:onEnter()

    core.displayEX.newButton(self.btn_later)
    self.btn_later.clickedCall = function()
        self:onLater()
    end

    core.displayEX.newButton(self.btn_ok)
    self.btn_ok.clickedCall = function()
        self:onOK()
    end

end

function RateTaskView:onExit()
    self:removeAllNodeEventListeners()
end


return RateTaskView