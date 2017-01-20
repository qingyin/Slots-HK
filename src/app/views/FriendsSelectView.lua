local FriendsSelectView = class("FriendsSelectView", function()
return core.displayEX.newSwallowEnabledNode()
end)

function FriendsSelectView:ctor(list, giftType, gift)
    self.viewNode  = CCBuilderReaderLoad(RES_CCBI.givegifts_friends, self)
    self:addChild(self.viewNode)

    self.flist = list
    self.gift = gift
    self.giftType = giftType

    self:registerEvent()
    self:initUI()
end

function FriendsSelectView:registerEvent()
    -- on close
    core.displayEX.newButton(self.btn_close) 
        :onButtonClicked(function(event)
            scn.ScnMgr.removeView(self)
        end)

    -- on send
    core.displayEX.newButton(self.btn_sendgifts) 
        :onButtonClicked(function(event)

            local list = self:getSlected()

            if #list > 0 then

                net.GiftsCS:sendGift(list, self.giftType, tonumber(self.gift.gift_id), function( msg )
                    -- body
                    if msg.result == 1 then
                        local totalCoins = app:getUserModel():getCoins() - msg.costCoins
                        local totalGems = app:getUserModel():getGems() - msg.costGems
                        app:getUserModel():setCoins(totalCoins)
                        app:getUserModel():setGems(totalGems)
                        EventMgr:dispatchEvent({name  = EventMgr.UPDATE_LOBBYUI_EVENT})
                    end
                end)

                scn.ScnMgr.removeView(self)

            else
                scn.ScnMgr.addView("CommonView",{title="Select None",content="select friends please!!!"})
            end

        end)

    self:addNodeEventListener(cc.NODE_TOUCH_EVENT,handler(self, self.onTouch_))
    
end


function FriendsSelectView:onTouch_(event)

    if event.name == "ended" then
        

        if self.selectAllSprite:getCascadeBoundingBox():containsPoint(cc.p(event.x, event.y)) then

            local allvisible = self.selectAllSprite:isVisible()

            if allvisible == true then
                self.selectAllSprite:setVisible(false)
            else
                self.selectAllSprite:setVisible(true)
            end

            for i=1,#self.friendsList.items_ do
                local it = self.friendsList.items_[i]

                for j=1,#it.cells do

                    local cell = it.cells[j]
                    cell.selectAsign:setVisible(self.selectAllSprite:isVisible())

                end
             
            end

        end

    end

    return true
end
function FriendsSelectView:initUI()

    if #self.flist > 0 then
        self:addFriendsList()
    end

end

function FriendsSelectView:getSlected()

    local selfriendlist = {}

    for i=1,#self.friendsList.items_ do
        local it = self.friendsList.items_[i]

        for j=1,#it.cells do

            local cell = it.cells[j]

            local visible = cell.selectAsign:isVisible()

            if visible == true then
                selfriendlist[#selfriendlist + 1] = cell.info
            end

        end
     
    end

    return selfriendlist
end

function FriendsSelectView:addFriendsList()

    self.rect = self.friendsRect:getBoundingBox()
    
    self.friendsList = cc.ui.UIListView.new {
        -- bgColor = cc.c4b(200, 200, 200, 120),
        bg = nil,
        bgScale9 = false,
        viewRect = self.rect,
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
        scrollbarImgV = nil}
        :onTouch(handler(self, self.onFriendslistListener))
        :addTo(self.friendsRect:getParent())

-- add items
    
    local idx = 1

    local rownum = math.ceil((#self.flist )/2)

    for i=1, rownum do

        local finfo = #self.flist[i]

        local item = self.friendsList:newItem()
        local content = display.newNode()
        local itemsize = {width=0,height=0}

        item.cells = {}

        local numCells = 2
        local mcol = self.rect.width/(2*numCells)

        for cellidx = 1, numCells do

            local finfo = self.flist[i]

            if finfo then

                local idx = (i-1)*2 + cellidx
                local cell  = CCBuilderReaderLoad(RES_CCBI.givegifts_friends_cell, self)
                local size = cell:getContentSize()

                itemsize.width = itemsize.width + size.width
                itemsize.height = size.height

                local posX = 0

                if cellidx == 1 then
                    posX = -mcol
                else
                    posX = mcol
                end

                cell.headImage = self.headImage
                cell.selectAsign = self.selectAsign

                cell.info = finfo
                cell.headImage:setSpriteFrame(HEAD_IMAGE[finfo.pictureId])

                cell:setPositionX(posX)
                content:addChild(cell)
                cell.idx = cellidx
                item.cells[cellidx] = cell

            end

            idx = idx + 1
        end

        item:addContent(content)
        item:setPositionX(self.rect.width/2)
        item:setItemSize(self.rect.width, itemsize.height)

        self.friendsList:addItem(item)
    end

    self.friendsList:setDelegate(handler(self, self.friendsListDelegate))
    self.friendsList:reload()

end

function FriendsSelectView:onFriendslistListener(event)

    local listView = event.listView
    if "clicked" == event.name and event.item then
        print("event name:" .. event.name)

        for i=1,#event.item.cells do

            local cell = event.item.cells[i]

            if cell:getCascadeBoundingBox():containsPoint(cc.p(event.x, event.y)) then

                local visible = cell.selectAsign:isVisible()

                if visible == true then
                    cell.selectAsign:setVisible(false)
                else
                    cell.selectAsign:setVisible(true)
                end

            end

        end


    elseif "moved" == event.name then
        self.bListViewMove = true
    elseif "ended" == event.name then
        self.bListViewMove = false
    else
        print("event name:" .. event.name)
    end

end

function FriendsSelectView:friendsListDelegate(listView, tag, idx)
    if cc.ui.UIListView.COUNT_TAG == tag then
    elseif cc.ui.UIListView.CELL_TAG == tag then
    else
    end
end


return FriendsSelectView