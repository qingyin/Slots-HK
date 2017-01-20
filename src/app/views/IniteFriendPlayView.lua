local IniteFriendPlayView = class("IniteFriendPlayView", function()
return core.displayEX.newSwallowEnabledNode()
end)

function IniteFriendPlayView:ctor(gameinfo)
    self.viewNode  = CCBuilderReaderLoad(RES_CCBI.invite_friends, self)
    self:addChild(self.viewNode)

    self.gameinfo = gameinfo
    self.inviteplayer=nil

    self:registerEvent()
    self:initUI()
end

function IniteFriendPlayView:registerEvent()
    -- on close
    core.displayEX.newButton(self.btn_close) 
        :onButtonClicked(function(event)
            scn.ScnMgr.removeView(self)
        end)

    -- on send
    core.displayEX.newButton(self.btn_sendgifts) 
        :onButtonClicked(function(event)

            if self.inviteplayer == nil then 
                return 
            end
            -- local onComplete = function(lists, siteId)
            --     scn.ScnMgr.removeView(self)
            -- end

            net.GameCS:inviteFriend({
                pid=self.inviteplayer.pid, 
                gameId=self.gameinfo.gameId, 
                roomId=self.gameinfo.roomId, 
                siteId=self.gameinfo.siteId})

            scn.ScnMgr.removeView(self)

        end)
end

function IniteFriendPlayView:initUI()
    self:addFriendsList()
end

function IniteFriendPlayView:addFriendsList()

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


    local num = math.ceil( (#self.gameinfo.friendlists) / 2 )
    
    for i=1, num do

        local item = self.friendsList:newItem()
        local content = display.newNode()
        local itemsize = {width=0,height=0}

        item.cells = {}

        local numCells = 2
        local mcol = self.rect.width/(2*numCells)

        for cellidx = 1, numCells do

            local friend = self.gameinfo.friendlists[i]
            if friend then

                local idx = (i-1)*2 + cellidx
                local cell  = CCBuilderReaderLoad(RES_CCBI.invite_friends_cell, self)
                local size = cell:getContentSize()

                cell.name=self.name
                cell.head=self.head
                cell.selectOn=self.selectOn

                itemsize.width = itemsize.width + size.width * 1.1
                itemsize.height = size.height * 1.05

                cell.pid = friend.pid
                cell.name:setString(friend.name)
                cell.head:setSpriteFrame(HEAD_IMAGE[friend.pictureId])

                local posX = 0

                if cellidx == 1 then
                    posX = -mcol
                else
                    posX = mcol
                end

                cell:setPositionX(posX)
                content:addChild(cell)
                cell.idx = cellidx
                item.cells[cellidx] = cell
            end
        end

        item:addContent(content)
        item:setPositionX(self.rect.width/2)
        item:setItemSize(self.rect.width, itemsize.height)

        self.friendsList:addItem(item)
    end

    self.friendsList:setDelegate(handler(self, self.friendsListDelegate))
    self.friendsList:reload()

end

function IniteFriendPlayView:selectOne(itemIdx, cellIdx)

    for i,v in ipairs(self.friendsList.items_) do

        for count = 1, #v.cells do
            local cell = v.cells[count]
            if cellIdx == count and i == itemIdx then
                local visible = cell.selectOn:isVisible()
                if visible == true then
                    cell.selectOn:setVisible(false)
                else
                    cell.selectOn:setVisible(true)
                    self.inviteplayer = cell
                end

            else
                cell.selectOn:setVisible(false)
            end
        end

    end

end

function IniteFriendPlayView:onFriendslistListener(event)

    local listView = event.listView
    if "clicked" == event.name then
        print("event name:" .. event.name)
        print("item idx :", event.itemPos, event.x, event.y, event.point.x, event.point.y)
        
        local p = cc.p(event.x, event.y)

        if event.item.cells == nil then return end

        local cellnum = #event.item.cells
        
        for count = 1, cellnum do
            local cell = event.item.cells[count]
            local boundingBox = cell:getCascadeBoundingBox()
            if cc.rectContainsPoint(boundingBox, p) then
                self:selectOne(event.itemPos, count)
                return
            else
                print("no contain :", count, boundingBox.x, boundingBox.y, boundingBox.width, boundingBox.height)
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

function IniteFriendPlayView:friendsListDelegate(listView, tag, idx)
    if cc.ui.UIListView.COUNT_TAG == tag then
    elseif cc.ui.UIListView.CELL_TAG == tag then
    else
    end
end


return IniteFriendPlayView