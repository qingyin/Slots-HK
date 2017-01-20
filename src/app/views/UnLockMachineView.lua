
local LUV = class("UnLockMachineView",function()
    return display.newNode()
end)

function LUV:ctor(args)
    self:addChild(cc.LayerColor:create(cc.c4b(0, 0, 0, 200)))
    self:setNodeEventEnabled(true)
    self:setTouchEnabled(true)
    self:setTouchSwallowEnabled(true)

    local viewNode = CCBReaderLoad("view/machine_unlock.ccbi",self)
    self:addChild(viewNode)

    self.icon = args.machineIcon
    self.vipPoint = args.vipPoint

    AnimationUtil.setContentSizeAndScale(viewNode)

    self:initUI()
    self:registerUIEvent()
end

function LUV:registerUIEvent()

    core.displayEX.newButton(self.btn_ok) 
        :onButtonClicked(function(event)

            if self.vipPoint ~= nil then
                local userModel = app:getUserModel()
                local viplevelup = userModel:setVipPoint(userModel:getVipPoint() + self.vipPoint)
                if viplevelup == true then
                    scn.ScnMgr.popView("VipLevelUpView")
                end
            end
            EventMgr:dispatchEvent({name=EventMgr.UPDATE_LOBBYUI_EVENT})

            scn.ScnMgr.removeView(self)
        end)
end

function LUV:initUI()
    if self.icon ~= nil and cc.SpriteFrameCache:getInstance():getSpriteFrame(self.icon) then
        self.machineIcon:setSpriteFrame(self.icon)
    end
    local userModel = app:getUserModel()
    local level = userModel:getLevel()
    self.levelLabel:setString("Level "..level)
end
function LUV:onEnter()

end

function LUV:onExit()
    self:removeAllNodeEventListeners()
end

return LUV
