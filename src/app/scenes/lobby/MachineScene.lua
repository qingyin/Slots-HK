View = require("app.scenes.lobby.View")

local ccbres = "lobby.ccbi"

local MachineScene = class("MachineScene", function()
    return display.newScene("MachineScene")
end)

function MachineScene:ctor()

    local  node  = CCBReaderLoad("machine.ccbi", self)
    self:addChild(node)

    local function onCCBTestBtn()
        app:enterScene("lobby.MainScene")
    end
    self.ccbTestBtn:registerControlEventHandler(onCCBTestBtn, cc.CONTROL_EVENTTYPE_TOUCH_UP_INSIDE)

end

function MachineScene:onEnter()
end

function MachineScene:onExit()
end

return MachineScene
