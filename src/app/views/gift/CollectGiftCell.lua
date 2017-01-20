local Cell = class("CollectGiftCell", function()
    return display.newNode()
end)

function Cell:ctor(args)
    --print("CollectGiftCell ctor")
    self.data = args
    self.viewNode  = CCBReaderLoad("lobby/present/collect_gift_cell.ccbi", self)
    self:addChild(self.viewNode)
    local size = self.viewNode:getContentSize()
    self:setContentSize(size)
    
    -- print(args.id)
    -- print(args.name)
    -- print(args.fromName)
    -- print(args.content)
    -- print(args.giftPicture)
    -- print(string.len(args.facebookId))
    -- print(args.itemCnt)

    self.descText:setString(args.content)
    self.valueText:setString("")
    if args.giftPicture ~= nil and cc.SpriteFrameCache:getInstance():getSpriteFrame(args.giftPicture) then
        self.giftSprite:setSpriteFrame(args.giftPicture)
    end
    self.nameText:setString(args.fromName)

    self:downloadFBPhoto(args.facebookId)

end

function Cell:downloadFBPhoto(fBId)
    local facebookCallBack = function(event)
        local user = event.user
        local photo = event.photo
        if photo ~= nil and photo ~= "-1" then
           -- print( "down image", event.photo.id, event.photo.name, event.photo.path)
           if self.fbPhoto ~= nil and self.headNode ~= nil then
                local head = display.newSprite(photo.path)
                local x,y = self.fbPhoto:getPosition()
                head:setPosition(x,y)
                self.headNode:addChild(head)
                self.fbPhoto:removeFromParentAndCleanup(true)
            end
        end
    end
    CCAccountManager:sharedAccountManager():init("facebook")
    CCAccountManager:sharedAccountManager():postFBListenerLua(facebookCallBack)
    CCAccountManager:sharedAccountManager():downloadPhoto(fBId)
end

function Cell:checkClick(p)
    local tSize = self.collectBtn:getContentSize()
    local tPos = self.collectBtn:getParent():convertToWorldSpace(cc.p(self.collectBtn:getPosition()))
    local rect = cc.rect(tPos.x - tSize.width / 2, tPos.y - tSize.height / 2, tSize.width, tSize.height)
    local isClick  = cc.rectContainsPoint(rect, p)
    return isClick
end

return Cell