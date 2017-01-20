local ScrollViewCell = import("app.views.adListUI.AdScrollViewCell")
local AdListCell = class("AdListCell", ScrollViewCell)

function AdListCell:ctor(size, adInfo)
    
    local rowHeight = math.floor((display.height - 250))
    local colWidth = display.width/2

    local batch = display.newNode()
    self:addChild(batch)
    self.pageIndex = pageIndex
    self.buttons = {}

    local x = display.cx
    local y = display.cy

    self.adInfo = adInfo

    -- local adSp = require("app.views.AD01View").new({adId=adId})
    -- local adSp = display.newSprite(GAME_IMAGE.cell_indicator)

    -- print("***9999***")
    -- print("adInfo.adId:", adInfo.adId)
    -- print(adInfo.templateId)
    -- print(DICT_AD_TEMPLATE[tostring(adInfo.templateId)].luatabel)

    local adSp = require("app.views.adViews."..adInfo.template.luatable).new(adInfo)

    local size = adSp:getContentSize()

    -- self:setTouchEnabled(true)
    -- self.initPos = {posx=0,posy=0}
    
    self.initPos = {posx = x - size.width/2 , posy= y - size.height/2 }

    -- print("initPos:", self.initPos.posx, self.initPos.posy)

    adSp:setPosition(self.initPos.posx, self.initPos.posy)

    batch:addChild(adSp)
    self.buttons[#self.buttons + 1] = adSp

    self.adSp = adSp

    self.iniScale = 0.9

    self.adSp:setScale(self.iniScale)

    self.scheduler = require(cc.PACKAGE_NAME .. ".scheduler")

    self.scEntry = self.scheduler.scheduleGlobal(function(dt)
        self:step(dt)
    end , 0)

end

function AdListCell:updateMachineIcon()
end

function AdListCell:onTouch(event, x, y)
    -- print("AdListCell:onTouch---")
    if event == "began" then
        local button = self:checkButton(x, y)
        if button then
        end
    elseif event ~= "moved" then
    end
    return true
end

function AdListCell:onTap(x, y)
    local button = nil--self:checkButton(x, y)
    if button and self:load(button) then
        self:dispatchEvent({name = "onTapLevelIcon", btn = button, cell = self})
    end
end

function AdListCell:load(machineObj)
    return true 
end

function AdListCell:checkButton(x, y)
    local pos = cc.p(x, y)
    for i = 1, #self.buttons do
        local button = self.buttons[i]
        if button:getBoundingBox():containsPoint(pos) then
            return button
        end
    end
    return nil
end

function AdListCell:step( dt )

    local pos = self:getParent():
    convertToWorldSpace(cc.p(self:getPosition()))
    if pos.x ~= self.lastPos then
        local scale = self.iniScale - math.abs(pos.x) * 0.0005
        self.adSp:setScale(scale)
    end
    self.lastPos = pos.x 

end

function AdListCell:onExit()
    -- self.super:onExit()
    -- print("onExit:unscheduleGlobal")
    self.scheduler.unscheduleGlobal(self.scEntry)
end

return AdListCell
