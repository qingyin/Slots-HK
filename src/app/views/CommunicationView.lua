local CommunicationView = class("CommunicationView", function()
    return core.displayEX.newSwallowEnabledNode()
end)

function CommunicationView:ctor()
    self:addChild(display.newColorLayer(cc.c4b(0, 0, 0, 200)))
    self.viewNode  = CCBReaderLoad("view/communication.ccbi", self)
    self:addChild(self.viewNode)

    -- on okBtn
    core.displayEX.newButton(self.btn_rebind) 
        :onButtonClicked(function(event)
            scn.ScnMgr.replaceScene("lobby.LoginScene")
            scn.ScnMgr.removeView(self)
        end)

end


function CommunicationView:onEnter()

end

function CommunicationView:onExit()
end

return CommunicationView
