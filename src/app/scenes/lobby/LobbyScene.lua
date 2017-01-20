local lobbyctr = import("app.scenes.lobby.controllers.LobbyController")

--声明 LobbyScene 类
local LobbyScene = class("LobbyScene", function()
    return display.newScene("LobbyScene")
end)

function LobbyScene:ctor(layoutId)

    self.ctr_ = lobbyctr.new(layoutId)

    self:addChild(self.ctr_)
    
    self:setNodeEventEnabled(true)

end

function LobbyScene:onEnter()
	app:popDailyLogin()
end

function LobbyScene:onExit()
	if self.ctr_ ~= nil then
		self.ctr_:exit()

		self.ctr_:removeFromParent(true)
		self.ctr_ = nil
	end

end

return LobbyScene
