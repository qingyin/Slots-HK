local Cell = class("ChargeGiftCell", function()
    return display.newNode()
end)

function Cell:ctor(args)
    self.viewNode  = CCBReaderLoad("lobby/present/charge_gift_cell.ccbi", self)
    self:addChild(self.viewNode)
    local size = self.viewNode:getContentSize()
    self:setContentSize(size)
    self.gift = args
    self.valueText:setString(args.price)
    self.giftSprite:setSpriteFrame(args.picture)
end

return Cell
