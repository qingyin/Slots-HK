local GiveGiftsCell = class("GiveGiftsCell", function()
    return display.newNode()
end)

function GiveGiftsCell:ctor(gift, giftType)
    self.viewNode  = CCBuilderReaderLoad(RES_CCBI.givegifts_give_cell, self)
    self:addChild(self.viewNode)


    local size = self.viewNode:getContentSize()
    self:setContentSize(size)

    self.giftType = tonumber(giftType)

    self.free = true

    if self.giftType == 4 then
        self.free = true
    end

    self.gift = gift
    self:initUI()
end

function GiveGiftsCell:initUI()

    --["23"] = {gift_id = "23", name = "free gift3", desc = "", item_id = "", item_cnt = "", picture = "", currency = "1000", price = "20"}

    self.price:setString(self.gift.price)
    self.content:setString(self.gift.name)
    --self.giftSender:setSpriteFrame(HEAD_IMAGE[self.gift.pictureId+1])
    --self.giftIcon:setSpriteFrame("")

    -- self.btns[#self.btns+1] = {btn=self.btn_collect,
    
    -- call=function()
    --     -- body
    --     print("GiveGiftsCell-GiveGiftsCell")
    -- end
    -- }
end

function GiveGiftsCell:onSelected(val)
    self.selectAllSprite:setVisible(val)
end


return GiveGiftsCell