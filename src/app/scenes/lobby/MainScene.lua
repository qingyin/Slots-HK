View = require("app.scenes.lobby.View")

local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

function MainScene:ctor()

    local  node  = CCBReaderLoad("test/machine.ccbi", self)
    self:addChild(node)

    core.displayEX.newButton(self.serverBtn):onButtonClicked(function(event)
            local function httpbk()
                print("server call back function call")
            end

            net.UserAuthCS:quickLogin(httpbk)
        end)

    core.displayEX.newButton(self.ccbLobbyBtn)
        :onButtonClicked(function(event)
            app:enterScene("lobby.LobbyScene")
        end)
        
    self.ccbNode = nil

    core.displayEX.newButton(self.ccbAnimationBtn)
        :onButtonClicked(function(event)

        if self.ccbNode == nil then
            self.ccbNode  = View.new()

            self:addChild(self.ccbNode)
        else
            self.ccbNode:removeFromParent()
            self.ccbNode = nil
            display.removeUnusedSpriteFrames()

        end

        end)

end



function MainScene:onEnter()

    net.UserCS:getPlayerInfo(app:getUserModel():getPid(), print,false)
end

function MainScene:onExit()
end

return MainScene
