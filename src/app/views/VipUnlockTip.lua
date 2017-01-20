
local VipUnlockTip = class("VipUnlockTip",function() return display.newNode() end)

function VipUnlockTip:ctor(args)
    self:addChild(cc.LayerColor:create(cc.c4b(0,0,0,200)))
    self:setNodeEventEnabled(true)
    self:setTouchEnabled(true)
    local viewNode = CCBReaderLoad("view/VipUnlockTip.ccbi",self)
    self:addChild(viewNode)
    self.need_vip_level = args.need_vip_level

    self:initUI()
    self:registerUIEvent()
end

function VipUnlockTip:initUI()

end

function VipUnlockTip:registerUIEvent()
    core.displayEX.newButton(self.btn_close):onButtonClicked(function(event)
        scn.ScnMgr.removeView(self)
    end)

    core.displayEX.newButton(self.btn_go):onButtonClicked(function(event)
        scn.ScnMgr.addView("VipView",{callback = function() end})
        scn.ScnMgr.removeView(self)
    end)
end

function VipUnlockTip:onEnter()
    local item = DICT_VIP[tostring(self.need_vip_level)]
    if item ~= nil and cc.SpriteFrameCache:getInstance():getSpriteFrame(item.picture) then
        self.vipLevelSprite:setSpriteFrame(item.picture)
    end
end

function VipUnlockTip:onExit()

end

return VipUnlockTip