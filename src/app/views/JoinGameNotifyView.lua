local JoinGameNotifyView = class("JoinGameNotifyView", function()
    return core.displayEX.newSwallowEnabledNode()
end)

function JoinGameNotifyView:ctor(args)
    self.viewNode  = CCBuilderReaderLoad("view/jointhegameview.ccbi", self)
    self:addChild(self.viewNode)

    self.msg = msg

    self:registerUIEvent()

end


function JoinGameNotifyView:registerUIEvent()

    local pbtn = core.displayEX.newButton(self.btn_join) 
        :onButtonClicked( function(event)
            app:joinPlayerGame(self.msg)

        end)

    local pbtn = core.displayEX.newButton(self.btn_notnow) 
        :onButtonClicked( function(event)

            scn.ScnMgr.removeView(self)

        end)
end

function JoinGameNotifyView:flyCoins()
    local callback = function()
        local userModel = app:getUserModel()
        userModel:setCoins(userModel:getCoins()+1000)

        EventMgr:dispatchEvent({name = EventMgr.UPDATE_LOBBYUI_EVENT})
        scn.ScnMgr.removeView(self)
    end
    AnimationUtil.MoveTo("gold.png",10,self.coinsLabel, app.coinSprite,callback)
end


return JoinGameNotifyView
