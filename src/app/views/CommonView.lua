local CommonView = class("CommonView", function()
    return core.displayEX.newSwallowEnabledNode()
end)

function CommonView:ctor(msg)
    self.viewNode  = CCBuilderReaderLoad("view/CommonView.ccbi", self)
    self:addChild(self.viewNode)

    self:addNodeEventListener(cc.NODE_TOUCH_EVENT,handler(self, self.onTouch_))

    if msg then
        if msg.title then
            self.title:setString(msg.title)
        end
        if msg.content then
            self.content:setString(msg.content)
        end
        if msg.color then
            self.title:setColor(msg.color)
            self.content:setColor(msg.color)
        end


        self.callback = msg.callback
        self.delayPopCall = msg.delayPopCall
    end

end


function CommonView:onTouch_(event)

    if event.name == "ended" then
        
        if self.callback ~= nil then
            self.callback()
        end

        if self.delayPopCall ~= nil then
            self:delayPopCall()
        end

        scn.ScnMgr.removeView(self)

    end

    return true
end

return CommonView
