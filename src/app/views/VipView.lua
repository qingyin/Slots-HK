local VipView = class("VipView", function()
return core.displayEX.newSwallowEnabledNode()
end)

function VipView:ctor(args)
    self:addChild(display.newColorLayer(cc.c4b(0, 0, 0, 200)))

    self.viewNode  = CCBuilderReaderLoad(RES_CCBI.vip, self)
    --self.pmdNode  = CCBuilderReaderLoad(RES_CCBI.vip_pmd, self)

    self:addChild(self.viewNode)

    self.callback = args.callback

    AnimationUtil.setContentSizeAndScale(self.viewNode)

    self:registerEvent()
    self:initUI()
end

function VipView:registerEvent()

    -- on close
    core.displayEX.newSmallButton(self.btn_close) 
        :onButtonClicked(function(event)
            scn.ScnMgr.removeView(self)
        end)

    core.displayEX.newButton(self.vipLobbyBtn) 
        :onButtonClicked(function(event)
            EventMgr:dispatchEvent({name  = EventMgr.UPDATE_TOPBACK_EVENT})
            if self.callback then
                self.callback()
                scn.ScnMgr.removeView(self)
            end
        end)
end

function VipView:initUI()
    local model = app:getUserModel()
    local vipLevel = model:getVipLevel()
    local vipPoint = model:getCurrentVipLvExp()
    local nextPoints = getVipPointsByLevel(vipLevel+1)
    --print("vipPoint:", vipPoint)
    --print("vipLevel:", vipLevel)
    --print("nextPoints:", nextPoints)

    local vipStr = vipPoint.."/"..nextPoints
    self.vippoints:setString(vipStr)

    if vipLevel <= 5 then
        local currentImage = "vip_0"..(vipLevel + 1)..".png"
        if cc.SpriteFrameCache:getInstance():getSpriteFrame(currentImage) then
            self.currentStatus:setSpriteFrame(currentImage)
        end

        local nextImage
        if vipLevel == 5 then
            nextImage = "vip_06.png"
        else
            nextImage = "vip_0"..(vipLevel + 2)..".png"
        end

        if cc.SpriteFrameCache:getInstance():getSpriteFrame(nextImage) then
            self.nextStatus:setSpriteFrame(nextImage)
        end
    else
        local image = "vip_06.png"
        if cc.SpriteFrameCache:getInstance():getSpriteFrame(image) then
            self.currentStatus:setSpriteFrame(image)
            self.nextStatus:setSpriteFrame(image)
        end
    end


    for i=1,5 do

        local cvdict = DICT_VIP[tostring(i)]
        local normal = cvdict.alias.."_normal"
        local highlight = cvdict.alias.."_highlight"

        if vipLevel == i then
            self[normal]:setVisible(true)
            self[highlight]:setVisible(true)
        end

        if i < vipLevel then
            self[normal]:setVisible(true)
            self[highlight]:setVisible(false)
        elseif i > vipLevel then
            self[normal]:setVisible(false)
            self[highlight]:setVisible(false)
        end
    end


    local barX,barY = self.progressBar:getPosition()
    local parent = self.progressBar:getParent()

    self.progressBar:removeFromParent(false)
    local progress = display.newProgressTimer(self.progressBar, display.PROGRESS_TIMER_BAR)
    :pos(barX, barY)
    :addTo(parent)

    progress:setMidpoint(cc.p(0, 0))
    progress:setBarChangeRate(cc.p(1, 0))

    progress:setPercentage(100 * vipPoint / nextPoints)

end

return VipView