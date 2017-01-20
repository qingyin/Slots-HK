local FBConnectView = class("FBConnectView", function()
    return core.displayEX.newSwallowEnabledNode()
end)

function FBConnectView:ctor(args)
    print("FBConnectView:ctor")
    self:addChild(cc.LayerColor:create(cc.c4b(0, 0, 0, 200)))
    self:setNodeEventEnabled(true)
    self:setTouchEnabled(true)
    self:setTouchSwallowEnabled(true)

    self.viewNode  = CCBuilderReaderLoad("view/facebook_connect.ccbi", self)
    self:addChild(self.viewNode)

    
    -- self.coins = args.coins
    -- self.coinLabel:setString(self.coins)

    self.callback = args.callback
    self.isConnect = false

    self:registerEvent()
end


function FBConnectView:registerEvent()

    core.displayEX.newButton(self.fbBtn) 
        :onButtonClicked(function(event)
            if self.isConnect then return end

            self:connectFB() 
        end)

    core.displayEX.newButton(self.fbLaterBtn) 
        :onButtonClicked(function(event)
            if self.isConnect then return end

            if self.callback then
                self.callback(false)
            end
            scn.ScnMgr.removeView(self)
        end)

end

function FBConnectView:connectFB()
    self.isConnect = true
    local function onComplete()
        self.isConnect = false
        if self.callback then
            self.callback(true)
        end

        EventMgr:dispatchEvent({name  = EventMgr.UPDATE_LOBBYUI_EVENT})
        EventMgr:dispatchEvent({name  = EventMgr.UPDATE_TOPFB_EVENT})

        core.Waiting.logining = false
        core.Waiting.hide()
        scn.ScnMgr.removeView(self)
    end
    core.FBPlatform.login(onComplete)

end


return FBConnectView
