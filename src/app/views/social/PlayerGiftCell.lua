local Cell = class("PlayerGiftCell", function()
    return display.newNode()
end)

function Cell:ctor(args)
    self.data = args
    self.viewNode  = CCBReaderLoad("lobby/social/player_gift_cell.ccbi", self)
    self:addChild(self.viewNode)
    local size = self.viewNode:getContentSize()
    self:setContentSize(size)

    self.descText:setString(args.content)
    self.valueText:setString(args.itemCnt)

    self.giftSprite:setSpriteFrame(args.giftPicture)

    local headview = headViewClass.new({player={
        name=args.fromName,
        pictureId=args.pictureId,
        }})
    headview:replaceHead(self.head)
    headview:showUserName()
end

return Cell
