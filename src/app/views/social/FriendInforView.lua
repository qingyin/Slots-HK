local GiftCell = require("app.views.social.PlayerGiftCell")
local HonorCell = require("app.views.HonorCell")

local tabBase = require("app.views.TabBase")

local FriendInforView = class("FriendInforView", tabBase)

function FriendInforView:ctor(val)

    self.viewNode  = CCBReaderLoad("lobby/social/player_info.ccbi", self)
    self:addChild(self.viewNode)

    if val and val.info ~= nil then
        self.isme = false
        self.exInfo = val.info.extendInfo
        self.baseInfo = val.info
        self.tabNum=4
    else
        self.isme = true
        self.tabNum=3

        local model = app:getObject("UserModel")
        local cls = model.class
        local properties = model:getProperties({cls.pid, cls.serialNo, cls.name, cls.level, cls.exp, cls.vipLevel, cls.vipPoint, cls.coins, cls.gems, cls.money, cls.liked, cls.pictureId, cls.extinfo})

        self.exInfo=properties[cls.extinfo]
        self.baseInfo=properties
    end

    if val and val.tabidx ~= nil then
        self.selectedIdx = val.tabidx
    else
        self.selectedIdx = 1
    end
    
    self:registerUIEvent()

    self.gifted = false
    self.stats = false
    self.honor = false

    self:initExp()
    self:showProfile()
end


function FriendInforView:registerUIEvent()

    self:addTabEvent(1,function()
        self:showProfile()
    end)

    self:addTabEvent(2,function()
        self:showRecord()
    end)

    self:addTabEvent(3,function()

        print("showGift1")
        self:showGift()
    end)

    if self.isme then
        self:hideTab(4)
    else
        self:addTabEvent(4,function()
            self:showHonor()
        end)
    end

    local pbtn = core.displayEX.newButton(self.btn_close)
        :onButtonClicked( function(event)
            scn.ScnMgr.removeView(self)

        end)

    local pbtn = core.displayEX.newButton(self.invite_btn)
        :onButtonClicked( function(event)
            net.FriendsCS:addFriend(self.baseInfo.pid)
            scn.ScnMgr.addView("CommonView",
                {
                    title="add friend",
                    content="have been added "..self.baseInfo.name.." as a friend ."
                })
        end)

    core.displayEX.newButton(self.edit_btn)
    :onButtonClicked( function(event)
        scn.ScnMgr.addView("social.EditPlayerView",self.baseInfo,self.exInfo)

    end)

    core.displayEX.newButton(self.send_btn)
    :onButtonClicked( function(event)
        scn.ScnMgr.addView("gift.GiftsView",{tabidx=1,pid=self.baseInfo.pid})
    end)

    EventMgr:addEventListener(EventMgr.UPDATE_LOBBYUI_EVENT, handler(self, self.doChangePlayerInfo))

end

function FriendInforView:doChangePlayerInfo()
    
    print("doChangePlayerInfo")
    if self.headView then
        self.headView:updateUI()
    end

    local model = app:getUserModel()
    local cls   =   model.class

    self.exInfo = model:getProperties({cls.extinfo}).extinfo
    self.baseInfo = model:getProperties({
            cls.pid, 
            cls.name, 
            cls.level, 
            cls.exp, 
            cls.vipLevel, 
            cls.vipPoint, 
            cls.coins, 
            cls.gems, 
            cls.money,
            cls.pictureId,
            cls.hasnews,
            cls.hasgift})

    print("self.exInfo", self.exInfo.signature)

    if self.exInfo[cls.ei.signature] and self.signature_text then
        self.signature_text:setString(tostring(self.exInfo[cls.ei.signature]))
    end

end

function FriendInforView:initProfile()

    self.level_text:setString(self.baseInfo.level)
    self.pid_text:setString(self.baseInfo.pid)
    print("--------pid--",self.baseInfo.pid)
    self.coin_text:setString(self.baseInfo.coins)
    self.gem_text:setString(self.baseInfo.gems)

    if self.exInfo then
        self.signature_text:setString(tostring(self.exInfo.signature))
    end

    -- header
    if self.baseInfo.pictureId == nil then
        self.baseInfo.pictureId = 1
    end

    if self.headView == nil then
        self.headView = headViewClass.new({player=self.baseInfo, scale=1.0})
        self.headView:replaceHead(self.player_head_sp)
        self.headView:showUserName()
    end

    -- vip
    local from  = DICT_VIP[tostring(self.baseInfo.vipLevel)]
    local currVipPoint = self.baseInfo.vipPoint
    if from then
        self.vip_from_sp:setSpriteFrame("dating_vip_"..from.alias..".png")--from.picture)
        self.vip_from_text:setString(currVipPoint)
    else
        currVipPoint = 0
        self.vip_from_text:setString(currVipPoint)
    end
    local to  = DICT_VIP[tostring(self.baseInfo.vipLevel +1)]
    if to then
        self.vip_to_sp:setSpriteFrame("dating_vip_"..to.alias..".png")--to.picture)
        self.vip_to_text:setString("/"..to.vip_point)
    end

    -- vip Progress
    if  self.vipProgress == nil then
        local vipX,vipY = self.vip_progress_sp:getPosition()
        local parent = self.vip_progress_sp:getParent()
        self.vip_progress_sp:removeFromParent(false)
        self.vipProgress = display.newProgressTimer(self.vip_progress_sp, display.PROGRESS_TIMER_BAR)
        :pos(vipX, vipX)
        :addTo(parent)
        self.vipProgress:setMidpoint(cc.p(0, 0))
        self.vipProgress:setBarChangeRate(cc.p(1, 0))
    end
    self.vipProgress:setPercentage(100 * currVipPoint / tonumber(to.vip_point))

    if self.isme == true then
        self.player_node:setVisible(false)
        self.me_node:setVisible(true)
    else
        self.player_node:setVisible(true)
        self.me_node:setVisible(false)
    end
end


function FriendInforView:initExp()
    local exp = self.baseInfo.exp
    local lvl = self.baseInfo.level

    -- expProgress
    if  self.expProgress == nil then
        local expX,expY = self.exp_sp:getPosition()
        local parent = self.exp_sp:getParent()

        self.exp_sp:removeFromParent(false)
        self.expProgress = display.newProgressTimer(self.exp_sp, display.PROGRESS_TIMER_BAR)
        :pos(expX, expY)
        :addTo(parent)

        self.expProgress:setMidpoint(cc.p(0, 0))
        self.expProgress:setBarChangeRate(cc.p(1, 0))
    end
    self.expProgress:setPercentage(100 * exp / tonumber(getLevelExpByLevel(lvl+1)))
end

function FriendInforView:showProfile()
    self:showTab(1)
    self:initProfile()
end

function FriendInforView:showRecord()
    self:showTab(2)

    if self.stats == false then
        net.GameCS:getGameStat(self.baseInfo.pid,function(stats)
            self.stats = true
            self:addRecordList(stats)
        end)
    end

end


function FriendInforView:showGift()
    self:showTab(3)

    if self.gifted == false then
        net.GiftsCS:getGiftList(self.baseInfo.pid,1, function(gifts)
            self.gifted = true
            self:addGiftList(gifts)
        end)
    end

end

function FriendInforView:showHonor()
    self:showTab(4)

    if self.honor == false then
        net.HonorCS:getHonorList(self.baseInfo.pid,function(honorlist)
            self.honor = true
            self:addHonorList(honorlist)

        end)
    end

end

function FriendInforView:addHonorList(honorlist)

    local box = self.contentRect:getBoundingBox()
    
    self.honorsList = cc.ui.UIListView.new {
        -- bgColor = cc.c4b(200, 200, 200, 120),
        bg = nil,
        bgScale9 = false,
        viewRect = box,
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
        scrollbarImgV = nil}
        :onTouch(handler(self, self.onHonorlistListener))
        :addTo(self.tabPanel4)

-- add items

    local listnum = #honorlist

    local honorsAll = {}
    honorsAll["COMMON"] = {}
    honorsAll["SLOTS"] = {}
    honorsAll["VIDEO_POKER"] = {}
    honorsAll["TEXAS_HOLDEM"] = {}
    honorsAll["BLACK_JACK"] = {}

    for i=1,#honorlist do
        local categoryHonor = honorsAll[honorlist[i].category]
        if categoryHonor then
            categoryHonor[#categoryHonor + 1] = honorlist[i]
        end
    end

    local addSubHonor = function(key, subhonorsList)
        -- body
        local item = self.honorsList:newItem()
        local cell = CCBReaderLoad("lobby/honor/honor_cell_sp.ccbi", self)

        self.hTitle:setString(key)

        local itemsize = cell:getContentSize()
        cell:setPositionX(box.width/2)

        item:addContent(cell)
        item:setItemSize(itemsize.width, itemsize.height)
        self.honorsList:addItem(item)

        local num = #subhonorsList

        for i=1, num do

            local honor = subhonorsList[i]
            
            local item = self.honorsList:newItem()
            local cell = HonorCell.new(honor, self.isme)
            local itemsize = cell:getContentSize()
            cell:setPositionX(box.width/2)
            item:addContent(cell)
            item:setItemSize(itemsize.width, itemsize.height)
            self.honorsList:addItem(item)

        end
    end

    addSubHonor("SUMMARY", honorsAll["COMMON"])
    addSubHonor("SLOTS", honorsAll["SLOTS"])
    addSubHonor("VIDEO_POKER", honorsAll["VIDEO_POKER"])
    addSubHonor("TEXAS_HOLDEM", honorsAll["TEXAS_HOLDEM"])
    addSubHonor("BLACK_JACK", honorsAll["BLACK_JACK"])

    self.honorsList:reload()

end


function FriendInforView:onHonorlistListener(event)

    local listView = event.listView
    if "clicked" == event.name then

        local cell = event.item:getContent()

        if cell then cell:onClicked(event) end
    elseif "moved" == event.name then
        self.bListViewMove = true
    elseif "ended" == event.name then
        self.bListViewMove = false
    else
        print("event name:" .. event.name)
    end

end

function FriendInforView:addRecordList(stats)

    local box = self.contentRect:getBoundingBox()
    self.recordsList = cc.ui.UIListView.new {
        -- bgColor = cc.c4b(200, 200, 200, 120),
        bg = nil,
        bgScale9 = false,
        viewRect = box,
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
        scrollbarImgV = nil}
        :addTo(self.tabPanel2)

-- add items
    
    for i=1, 4 do
        local item = self.recordsList:newItem()
        local record = self["record"..i]
        record:setVisible(true)
        record:removeFromParent(false)

        local itemsize = record:getContentSize()

        item:addContent(record)

        item:setItemSize(itemsize.width, itemsize.height)

        self.recordsList:addItem(item)
    end

    self.recordsList:reload()

    for i=1,#stats do
        self:initrecord(stats[i])
    end

end

function FriendInforView:initrecord(stat)

    if stat.gameType == 1 then

        self["game_1_totalwinings_num"]:setString(tostring(stat.totalWin))
        self["game_1_biggestwin_num"]:setString(tostring(stat.maxWin))
        self["game_1_spinswon_num"]:setString(tostring(stat.winCnt))
        self["game_1_totalspins_num"]:setString(tostring(stat.gameCnt))
        --self["game_1_comvp"]:setString(tostring(stat.totalWin))

    elseif stat.gameType == 2 then
        
        self["game_2_handsplayed_num"]:setString(tostring(stat.handsPlayed))
        self["game_2_blackjack_num"]:setString(tostring(stat.blackJack))
        self["game_2_handspushed_num"]:setString(tostring(stat.handsPushed))
        self["game_2_handslots_num"]:setString(tostring(stat.handsLost))
        --self["game_2_comvp"]:setString(tostring(stat.totalWin))

    elseif stat.gameType == 3 then

        self["game_3_totalwinings_num"]:setString(tostring(stat.totalWin))
        self["game_3_biggestwin_num"]:setString(tostring(stat.maxWin))
        self["game_3_spinswon_num"]:setString(tostring(stat.winCnt))
        self["game_3_totalspins_num"]:setString(tostring(stat.gameCnt))


        if stat.bestSuit ~= nil then

            local bestsuit = table.unserialize(tostring(stat.bestSuit))

            if bestsuit then

                for k,v in pairs(bestsuit) do
                    print(k,v)
                end

                for i=1,5 do
                    
                    local poker = bestsuit[i]
                    for k,v in pairs(poker) do
                        print(k,v)
                    end

                    print("----", self["d_poker"..tostring(i)], poker["resName"])
                    if poker then
                        self["d_poker"..tostring(i)]:setSpriteFrame(poker["resName"])
                    end
                end
            end

        end

        --self["game_3_comvp"]:setString(tostring(stat.totalWin))

    elseif stat.gameType == 4 then

        self["game_4_handswon_num"]:setString(tostring(stat.handsWin))
        self["game_4_handsplayed_num"]:setString(tostring(stat.handsPlayed))
        self["game_4_totalwinings_num"]:setString(tostring(stat.totalWin))
        --self["game_3_comvp"]:setString(tostring(stat.totalWin))

        if stat.bestSuit ~= nil then

            local bestsuit = table.unserialize(stat.bestSuit)

            if bestsuit ~= nil then
            
                for i=1,5 do
                    local poker = bestsuit[i]

                    if poker then
                        print(poker["resName"])
                        self["v_poker"..tostring(i)]:setSpriteFrame(poker["resName"])
                        self["v_poker"..tostring(i)]:setVisible(true)
                    end
                end

            end

        end

    elseif stat.gameType == 5 then

    end

end

function FriendInforView:addGiftList(gifts)

    local num = #gifts

    if num < 1 then
        self.no_gift_label:setVisible(true)
        self.titleShow:setVisible(false)
        return
    end

    self.no_gift_label:setVisible(false)

    local box = self.giftRect:getBoundingBox()
    
    self.giftsList = cc.ui.UIListView.new {
        -- bgColor = cc.c4b(200, 200, 200, 120),
        bg = nil,
        bgScale9 = false,
        viewRect = box,
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
        scrollbarImgV = nil}
        :onTouch(handler(self, self.onGiftlistListener))
        :addTo(self.tabPanel3)

-- add items
    
    
    for i=1, num do
        local item = self.giftsList:newItem()

        local gift=gifts[i]
        local giftcell = GiftCell.new(gift)
        
        local itemsize = giftcell.viewNode:getContentSize()

        item:setPositionX(box.width/2)

        item:addContent(giftcell)
        item:setItemSize(itemsize.width, itemsize.height)

        self.giftsList:addItem(item)
    end

    self.giftsList:setDelegate(handler(self, self.giftListDelegate))
    self.giftsList:reload()
    
end

function FriendInforView:onGiftlistListener(event)

    local listView = event.listView
    if "clicked" == event.name then
        local cell = event.item:getContent()
        if cell then cell:onTouched(event) end
    elseif "moved" == event.name then
        self.bListViewMove = true
    elseif "ended" == event.name then
        self.bListViewMove = false
    else
        print("event name:" .. event.name)
    end

end

function FriendInforView:giftListDelegate(listView, tag, idx)
    if cc.ui.UIListView.COUNT_TAG == tag then
        return 50
    elseif cc.ui.UIListView.CELL_TAG == tag then
        local item
        local content

        item = self.friendsList:dequeueItem()
        if not item then
            item = self.friendsList:newItem()
            content = cc.ui.UILabel.new(
                    {text = "item"..idx,
                    size = 20,
                    align = cc.ui.TEXT_ALIGN_CENTER,
                    color = display.COLOR_WHITE})
            item:addContent(content)
        else
            content = item:getContent()
        end
        content:setString("item:" .. idx)
        item:setItemSize(120, 80)

        return item
    else
    end
end

function FriendInforView:onExit()
    EventMgr:removeEventListenersByEvent(EventMgr.UPDATE_LOBBYUI_EVENT)
    self.baseInfo = nil
    self = {}
end

return FriendInforView
