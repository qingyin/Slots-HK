local View = class("EditHeadView", function()
    return core.displayEX.newSwallowEnabledNode()
end)

function View:ctor()
    self.viewNode  = CCBReaderLoad("lobby/social/edit_head.ccbi", self)
    self:addChild(self.viewNode)
    self:registerUIEvent()
end

function View:registerUIEvent()

    core.displayEX.newButton(self.close_btn)
    self.close_btn.clickedCall = function()
        scn.ScnMgr.removeView(self)
    end

    core.displayEX.newButton(self.ok_btn)
    self.ok_btn.clickedCall = function()
        if self.selectId ~= nil then
            local model = app:getObject("UserModel")
            model:setPictureId(self.selectId)
            local sid = self.selectId
            EventMgr:dispatchEvent({
                name  = EventMgr.Change_Player_Head_Event,
                pictureId = sid
            })
        end

        scn.ScnMgr.removeView(self)
    end

    local addSpriteEvent = core.displayEX.addSpriteEvent
    for i = 1, 12 do
        local sp = self["player_head_sp"..i]
        addSpriteEvent(sp,function()
            self.head_selected_bg:removeFromParent(false)
            local node = sp:getParent()
            node:addChild(self.head_selected_bg)
            self.head_selected_bg:setVisible(true)
            self.head_selected_bg:setLocalZOrder(0)
            self.selectId = i
        end)
    end

end



function View:onExit()
    self = {}
end

return View
