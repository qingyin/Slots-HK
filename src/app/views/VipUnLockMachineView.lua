

local LUV = class("VipUnLockMachineView",function()
    return display.newNode()
end)

function LUV:ctor(args)
    self:addChild(cc.LayerColor:create(cc.c4b(0, 0, 0, 200)))
    self:setNodeEventEnabled(true)
    self:setTouchEnabled(true)
    self:setTouchSwallowEnabled(true)

    local viewNode = CCBReaderLoad("view/vipMachine_unlock.ccbi",self)
    self:addChild(viewNode)

    self.unit = args.unit
    self.vipLevel = args.vipLevel
    self.callback = args.callback

    -- local size = viewNode:getContentSize()
    -- local coref = (0.75*display.width)/size.width
    -- viewNode:setScale(coref)
    AnimationUtil.setContentSizeAndScale(viewNode)

    self:initUI()
    self:registerUIEvent()
end

function LUV:registerUIEvent()

    core.displayEX.newButton(self.btn_ok) 
        :onButtonClicked(function(event)
            
            if self.callback ~= nil then
                self.callback()
            end
            scn.ScnMgr.removeView(self)
        end)
end

function LUV:initUI()
    if self.unit ~= nil then
        local icon = self.unit.icon
        if cc.SpriteFrameCache:getInstance():getSpriteFrame(icon) then
            self.machineIcon:setSpriteFrame(icon)
        end
    end

    if self.vipLevel ~= nil then
        local item = DICT_VIP[tostring(self.vipLevel)]
        if item ~= nil and cc.SpriteFrameCache:getInstance():getSpriteFrame(item.picture) then
            self.vipLevelSprite:setSpriteFrame(item.picture)
        end
    end
end
function LUV:onEnter()

end

function LUV:onExit()
    self:removeAllNodeEventListeners()
end

return LUV