local GiftsCell = class("GiftsCell", function()
    return display.newNode()
end)

function GiftsCell:ctor(gift)
    self.viewNode  = CCBuilderReaderLoad(RES_CCBI.gifts_cell, self)
    self:addChild(self.viewNode)
    self.gift = gift
    self:initUI()
end

function GiftsCell:initUI()

    self.btns = {}

    --self.giftText:setString(self.gift.fromName)
    self.giftNum:setString(self.gift.giftId)
    self.giftSender:setSpriteFrame(HEAD_IMAGE[self.gift.pictureId+1])
    --self.giftIcon:setSpriteFrame("")

    if self.gift.state == 0 then

        self.btns[#self.btns+1] = {btn=self.btn_collect,
            
            call=function()
                -- body
                net.GiftsCS:receiveGift(self.gift.id,function( msg )
                    -- body
                    if msg.result == 1 then
                        local totalCoins = app:getUserModel():getCoins() - msg.rewardCoins
                        local totalGems = app:getUserModel():getGems() - msg.rewardGems
                        app:getUserModel():setCoins(totalCoins)
                        app:getUserModel():setGems(totalGems)
                        EventMgr:dispatchEvent({name  = EventMgr.UPDATE_LOBBYUI_EVENT})
                    end

                end)

            end
            }

    elseif self.gift.state == 1 then
        self.btn_collect:setVisible(false)
    end

    
end


function GiftsCell:onTouched(event)
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

return GiftsCell