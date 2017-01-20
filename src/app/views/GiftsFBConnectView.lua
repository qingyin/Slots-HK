local GiftsFBConnectView = class("GiftsFBConnectView", function()
    return core.displayEX.newSwallowEnabledNode()
end)

function GiftsFBConnectView:ctor()
    print("GiftsFBConnectView:ctor")
    local touchlayer = display.newColorLayer(cc.c4b(0, 0, 0, 200))
    self:addChild(touchlayer)

    self.viewNode  = CCBuilderReaderLoad("lobby/present/nogifts.ccbi", self)
    self:addChild(self.viewNode)

    -- local size = self.bgSprite:getContentSize()
    -- local coref = (0.85*display.height)/size.height
    -- self.viewNode:setScale(coref)
    AnimationUtil.setContentSizeAndScale(self.viewNode)

    self:registerEvent()

end


function GiftsFBConnectView:registerEvent()
    core.displayEX.newSmallButton(self.btn_close) 
        :onButtonClicked(function(event)
            scn.ScnMgr.removeView(self)
        end)


    core.displayEX.newButton(self.fbBtn) 
        :onButtonClicked(function(event)
            self:connectFB()
            scn.ScnMgr.removeView(self)
        end)

end

function GiftsFBConnectView:connectFB()
    local function onComplete()
        --print("GiftsFBConnectView addFacebookFriends onCpmplete")
        EventMgr:dispatchEvent({name  = EventMgr.UPDATE_TOPFB_EVENT})
        core.Waiting.logining = false
        core.Waiting.hide()
    end

    core.FBPlatform.login(onComplete)

end

return GiftsFBConnectView
