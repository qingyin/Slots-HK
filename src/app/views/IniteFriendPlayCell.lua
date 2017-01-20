local IniteFriendPlayCell = class("IniteFriendPlayCell", function()
    return display.newNode()
end)

function IniteFriendPlayCell:ctor(gift)
    self.viewNode  = CCBuilderReaderLoad(RES_CCBI.invite_friends_cell, self)
    self:addChild(self.viewNode)
    self.gift = gift
    self:initUI()
end

function IniteFriendPlayCell:initUI()

    self.btns = {}

    self.giftNum:setString(self.gift.giftId)
    self.giftSender:setSpriteFrame(HEAD_IMAGE[self.gift.pictureId+1])

    self.btns[#self.btns+1] = {btn=self.btn_collect,
    
    call=function()
        -- body
        print("IniteFriendPlayCell-IniteFriendPlayCell")
    end
    }
end


function IniteFriendPlayCell:onTouched(event)
    if event.name == "clicked" then

        for i=1,#self.btns do
            local btnevent = self.btns[i]
            print("clicked",event.x, event.y,btnevent.btn:getCascadeBoundingBox():containsPoint(cc.p(event.x, event.y)))
            if btnevent.btn:getCascadeBoundingBox():containsPoint(cc.p(event.x, event.y)) then
                btnevent.call()
                return true
            end
        end
    elseif event.name == "ended" then

        if self.clicked == false then return true end

        for i=1,#self.btns do
            local btnevent = self.btns[i]
            if btnevent.btn:getCascadeBoundingBox():containsPoint(cc.p(event.x, event.y)) then
                btnevent.btn:setHighlighted(false)
                btnevent.call()
                return true
            end
        end

    end
    return true
end

return IniteFriendPlayCell