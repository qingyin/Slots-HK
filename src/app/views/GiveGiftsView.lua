local GiveGiftsCell = require("app.views.GiveGiftsCell")

local GiveGiftsView = class("GiveGiftsView", function()
    return core.displayEX.newSwallowEnabledNode()
end)

function GiveGiftsView:ctor(isme, fPid)
    self.viewNode  = CCBuilderReaderLoad(RES_CCBI.givegifts, self)
    self:addChild(self.viewNode)

    self.isme = isme
    self.fPid = fPid
    self.selectCell = nil

    self:registerEvent()
    self:initUI()
end

function GiveGiftsView:registerEvent()
    -- on close
    core.displayEX.newButton(self.btn_close) 
        :onButtonClicked(function(event)
            scn.ScnMgr.removeView(self)
        end)
    -- on select friend


    local sendGiftCall = function(isfree, giftType, gift)
        -- body

        if self.isme == true then

            local function onComplete(lists)
                if #lists > 0 then
                    scn.ScnMgr.addView("FriendsSelectView", lists, giftType, gift)
                else
                    scn.ScnMgr.addView("CommonView",{title="No Friends",content="add friends please!!!"})
                end
            end

            if isfree == false then
                net.FriendsCS:getFriendsList(onComplete)
            else
                net.FriendsCS:getAllFriends(tonumber(gift.gift_id), onComplete)
            end

            --net.FriendsCS:getAllFriends(tonumber(giftType), onComplete)

        else

            local flist = {}
            flist[#flist + 1]={pid=self.fPid}

            net.GiftsCS:sendGift(flist, giftType, tonumber(gift.gift_id), function( msg )
                        -- body
                if msg.result == 1 then
                    local totalCoins = app:getUserModel():getCoins() - msg.costCoins
                    local totalGems = app:getUserModel():getGems() - msg.costGems
                    app:getUserModel():setCoins(totalCoins)
                    app:getUserModel():setGems(totalGems)
                    EventMgr:dispatchEvent({name  = EventMgr.UPDATE_LOBBYUI_EVENT})
                end
            end)

        end
    end

    core.displayEX.newButton(self.btn_ok) 
        :onButtonClicked(function(event)

            self.giftBtns:setVisible(true)
            self.btn_ok:setVisible(false)

            if self.selectCell ~= nil and self.selectCell.gift ~= nil then
            
                local  gift = clone(self.selectCell.gift)
                local  giftType = clone(self.selectCell.giftType)

                sendGiftCall(self.selectCell.free, giftType, gift)

            end

            self:removeGiftList()

        end)


    core.displayEX.newButton(self.btn_coins) 
        :onButtonClicked(function(event)
            
            local giftType = "1"
            sendGiftCall(true, giftType, DICT_GIFT[giftType])

        end)

    core.displayEX.newButton(self.btn_gems) 
        :onButtonClicked(function(event)
            local giftType = "2"
            sendGiftCall(true, giftType, DICT_GIFT[giftType])
        end)

    core.displayEX.newButton(self.btn_freegifts) 
        :onButtonClicked(function(event)
            self.giftBtns:setVisible(false)
            self.btn_ok:setVisible(true)

            local giftType = "3"

            self:addGiftList(DICT_GIFT_MENU[giftType].contain_gifts, giftType)
        end)

    core.displayEX.newButton(self.btn_gifts) 
        :onButtonClicked(function(event)
            self.giftBtns:setVisible(false)
            self.btn_ok:setVisible(true)

            local giftType = "4"

            self:addGiftList(DICT_GIFT_MENU[giftType].contain_gifts, giftType)
        end)
end

function GiveGiftsView:initUI()
    self.giftBtns:setVisible(true)
    self.btn_ok:setVisible(false)

end

function GiveGiftsView:removeGiftList()
    self.giftsList:removeFromParent(true)
end

function GiveGiftsView:removeGiftList()
    self.giftsList:removeFromParent(true)
end

function GiveGiftsView:addGiftList(giftslist, giftType)

    local box = self.giftListRect:getBoundingBox()
    
    self.giftsList = cc.ui.UIListView.new {
        -- bgColor = cc.c4b(200, 200, 200, 120),
        bg = nil,
        bgScale9 = false,
        viewRect = box,
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
        scrollbarImgV = nil}
        :onTouch(handler(self, self.onGiftlistListener))
        :addTo(self.giftListRect:getParent())

    -- add items

    local listnum = #giftslist
    
    for i=1, listnum do
        local idx = giftslist[i]
        
        local item = self.giftsList:newItem()

        local cell = GiveGiftsCell.new(DICT_GIFT[tostring(idx)], giftType)

        local itemsize = cell:getContentSize()
        --cell:setPositionX(box.width/2)

        item:addContent(cell)
        item:setItemSize(itemsize.width, itemsize.height)

        self.giftsList:addItem(item)
    end

    self.giftsList:reload()

end



function GiveGiftsView:onGiftlistListener(event)

    local listView = event.listView

    if "clicked" == event.name and event.item then

        local cell = event.item:getContent()
        if cell then self:selectGift(cell) end

    elseif "moved" == event.name then
        self.bListViewMove = true
    elseif "ended" == event.name then
        self.bListViewMove = false
    else
        print("event name:" .. event.name)
    end

end

function GiveGiftsView:selectGift(cell)
    for i=1,#self.giftsList.items_ do
        local it = self.giftsList.items_[i]
        local icell = it:getContent()
        if icell == cell then
            icell:onSelected(true)
            self.selectCell = icell
        else
            icell:onSelected(false)
        end
    end
end

return GiveGiftsView