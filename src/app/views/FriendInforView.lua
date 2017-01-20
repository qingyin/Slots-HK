local GiftCell = require("app.views.GiftsCell")
local HonorCell = require("app.views.HonorCell")

local FriendInforView = class("FriendInforView", function()
    return core.displayEX.newSwallowEnabledNode()
end)

function FriendInforView:ctor(val)
    self.viewNode  = CCBuilderReaderLoad(RES_CCBI.friendInfos, self)
    self:addChild(self.viewNode)

    self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event) return self:onTouch(event)  end)


    if val and val.info ~= nil then
        self.isme = false
        self.exInfo = val.info.extendInfo
        self.baseInfo = val.info
    else
        self.isme = true
        local model = app:getObject("UserModel")
        local cls = model.class
        local properties = model:getProperties({cls.pid, cls.serialNo, cls.name, cls.level, cls.exp, cls.vipLevel, cls.vipPoint, cls.coins, cls.gems, cls.money, cls.liked, cls.pictureId, cls.extinfo})

        self.exInfo=properties[cls.extinfo]
        self.baseInfo=properties
    end

    if val and val.tabidx ~= nil then
        self.selIdx = val.tabidx
    else
        self.selIdx = 1
    end
    
    self:registerUIEvent()
    
    --self:initInputText()

    self:initExp()

    self:initFB()

    self:initProfile()

    self:initTab()

end


function FriendInforView:registerUIEvent()

    local pbtn = core.displayEX.newButton(self.btn_close) 
        :onButtonClicked( function(event)

            scn.ScnMgr.removeView(self)

        end)

    local pbtn = core.displayEX.newButton(self.btn_lnvite) 
        :onButtonClicked( function(event)
            --scn.ScnMgr.addView("FriendsSelectView")
            net.FriendsCS:addFriend(self.baseInfo.pid)
        end)


    local pbtn = core.displayEX.newButton(self.btn_usergift) 
        :onButtonClicked( function(event)

            scn.ScnMgr.addView("GiveGiftsView", self.isme, self.baseInfo.pid)

        end)
end

function FriendInforView:initTab()

    self.gifted = false
    self.stats = false
    self.honor = false

    self:showTab(self.selIdx)

    --self:addHonorList()
    --self:addRecordList()
    --self:addGiftList()
end

function FriendInforView:initProfile()

    self.lavelnum:setString(tostring(self.baseInfo.level))
    self.friendcodenum:setString(tostring(self.baseInfo.pid))
    self.goldnum:setString(tostring(self.baseInfo.coins))
    self.chipnum:setString(tostring(self.baseInfo.gems))
    self.nameLabel:setString(tostring(self.baseInfo.name))

    self.baseInfo.pictureId = 1
    self.headBg:setSpriteFrame(HEAD_IMAGE[self.baseInfo.pictureId])

    local nvdict  = DICT_VIP[tostring(self.baseInfo.vipLevel+3)]
    if nvdict then
        local nextImage = "text_"..nvdict.alias.."_vip.png"
        self.vipImge:setSpriteFrame(nextImage)
    end

    if self.isme == true then
        self.btn_lnvite:setVisible(false)
    end

    self:initPraise()


    self.headBg:setTouchEnabled(true)
    self.headBg:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        if event.name == "began" then
            return true
        end
        if event.name == "ended" then
            --scn.ScnMgr.popView("DailyLoginRewardView")
        end
    end)

end

function FriendInforView:initPraise()
    if self.isme == true then
        
        self.praise_time:setVisible(false)
        self.praise_num:setString(tostring(self.baseInfo.liked))

        self.praise_disable:setVisible(true)
        self.praise:setVisible(false)

    elseif self.isme == false then

        if self.baseInfo.likeCountdown == 0 then
            
            self.praise_time:setVisible(false)
            self.praise_disable:setVisible(false)
            self.praise:setVisible(true)

            core.displayEX.newButton(self.praise) 
            :onButtonClicked( function(event)

                net.UserCS:like(self.baseInfo.pid, function(msg)
                    -- body
                    if msg.result == 1 then
                        self.baseInfo.liked = msg.totalLiked
                        self.baseInfo.likeCountdown = msg.leftSeconds

                        self.praise_num:setString(tostring(self.baseInfo.liked))

                        local timestr = core.displayEX.formatTimer(self.baseInfo.likeCountdown)
                        
                        self.praise_time:setVisible(true)
                        self.praise_time:setString(timestr)
                        self.praise_disable:setVisible(true)
                        self.praise:setVisible(false)

                    end
                end)

            end)

        else
            local timestr = core.displayEX.formatTimer(self.baseInfo.likeCountdown)
            
            self.praise_time:setVisible(true)
            self.praise_time:setString(timestr)
            self.praise_disable:setVisible(true)
            self.praise:setVisible(false)

        end
        
        self.praise_num:setString(tostring(self.baseInfo.liked))

    end
end

function FriendInforView:initFB()

    -- if  CCAccountManager:sharedAccountManager():isLogged() then
        
    --     local model = app:getObject("UserModel")
    --     local cls = model.class
    --     local properties = model:getProperties({cls.facebook})
    --     local fb = properties[cls.facebook]

    --     print("Friend Infor View--", cls.fb.gender, fb[cls.fb.gender])
    --     print("Friend Infor View--", cls.fb.location, fb[cls.fb.location])

    --     self.pwrsonal_import:setString(fb[cls.fb.gender])
    --     self.hometown_import:setString(fb[cls.fb.location])

    -- end

end

function FriendInforView:initExp()
    local model = app:getUserModel()

    local exp = self.baseInfo.exp
    local lvl = self.baseInfo.level

    -- expProgress
    local expX,expY = self.usersignature_exp:getPosition()
    local parent = self.usersignature_exp:getParent()
    
    self.usersignature_exp:removeFromParent(false)

    self.expProgress = display.newProgressTimer(self.usersignature_exp, display.PROGRESS_TIMER_BAR)
        :pos(expX, expY)
        :addTo(parent)

    self.expProgress:setMidpoint(cc.p(0, 0))
    self.expProgress:setBarChangeRate(cc.p(1, 0))

    self.expProgress:setPercentage(100 * exp / tonumber(getLevelExpByLevel(lvl+1)))
    
end

function FriendInforView:onTouch(event)

    local p = cc.p(event.x, event.y)

    local idx = 0

    for i=1,5 do
        
        local tab = self["tab"..tostring(i)]
        local boundingBox = tab:getCascadeBoundingBox()

        if cc.rectContainsPoint(boundingBox, p) and i ~= self.selIdx then
            self:showTab(i)
        end

    end

end

function FriendInforView:showTab(idx)
    self.selIdx = idx
    for i=1,5 do
        local tab = self["tab"..tostring(i)]
        local tabPanel = self["tabPanel"..tostring(i)]

        print(self.gifted)

        if idx == 5 and i == 5 and self.gifted == false then

            print(self.gifted)
            
            net.GiftsCS:getGiftList(function(gifts)
                    -- body
                    self.gifted = true
                    if idx == i then
                        tabPanel:setVisible(true)
                        tab:setOpacity(255)
                    else
                        tabPanel:setVisible(false)
                        tab:setOpacity(0)
                    end

                    self:addGiftList(gifts)
                    print("net.GiftsCS:getGifts")
                end)

        elseif idx == 4 and i == 4 and self.stats == false then

            net.GameCS:getGameStat(function(stats)
                    -- body
                    self.stats = true
                    if idx == i then
                        tabPanel:setVisible(true)
                        tab:setOpacity(255)
                    else
                        tabPanel:setVisible(false)
                        tab:setOpacity(64)
                    end

                    self:addRecordList(stats)
                    print("net.GameCS:getGameStat")
                end)

        elseif idx == 2 and i == 2 and self.honor == false then

            net.HonorCS:getHonorList(function(honorlist)
                    -- body
                    self.honor = true
                    if idx == i then
                        tabPanel:setVisible(true)
                        tab:setOpacity(255)
                    else
                        tabPanel:setVisible(false)
                        tab:setOpacity(64)
                    end

                    self:addHonorList(honorlist)

                    print("net.HonorCS:getHonorList")
                end)

        else
            if idx == i then
                tabPanel:setVisible(true)
                tab:setOpacity(255)
            else
                tabPanel:setVisible(false)
                tab:setOpacity(64)
            end
        end
    end
end

function FriendInforView:addHonorList(honorlist)

    local box = self.honorRect:getBoundingBox()
    
    self.honorsList = cc.ui.UIListView.new {
        -- bgColor = cc.c4b(200, 200, 200, 120),
        bg = nil,
        bgScale9 = false,
        viewRect = box,
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
        scrollbarImgV = nil}
        :onTouch(handler(self, self.onHonorlistListener))
        :addTo(self.honorRect:getParent())

-- add items

    local listnum = #honorlist
    
    for i=1, listnum do
        local honor = honorlist[i]
        
        local item = self.honorsList:newItem()

        local cell = HonorCell.new(honor, self.isme)

        local itemsize = cell:getContentSize()
        cell:setPositionX(box.width/2)

        item:addContent(cell)
        item:setItemSize(itemsize.width, itemsize.height)

        self.honorsList:addItem(item)
    end

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

    local box = self.recordRect:getBoundingBox()
    
    self.recordsList = cc.ui.UIListView.new {
        -- bgColor = cc.c4b(200, 200, 200, 120),
        bg = nil,
        bgScale9 = false,
        viewRect = box,
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
        scrollbarImgV = nil}
        :addTo(self.recordRect:getParent())

-- add items
    
    for i=1, 5 do
        local item = self.recordsList:newItem()

        local record = self["record"..tostring(i)]
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


        -- if stat.bestSuit ~= nil then

        --     local bestsuit = table.unserialize(tostring(stat.bestSuit))

        --     for k,v in pairs(bestsuit) do
        --         print(k,v)
        --     end

        --     for i=1,5 do
                
        --         local poker = bestsuit[i]

        --         print("----", self["d_poker"..tostring(i)], poker["resName"])
        --         if poker then
        --             self["d_poker"..tostring(i)]:setSpriteFrame(poker["resName"])
        --         end
        --     end

        -- end

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

    local box = self.giftRect:getBoundingBox()
    
    self.giftsList = cc.ui.UIListView.new {
        -- bgColor = cc.c4b(200, 200, 200, 120),
        bg = nil,
        bgScale9 = false,
        viewRect = box,
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
        scrollbarImgV = nil}
        :onTouch(handler(self, self.onGiftlistListener))
        :addTo(self.giftRect:getParent())

-- add items
    
    local num = #gifts
    
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

function FriendInforView:initInputText()
    -- body

    local editboxSign = cc.ui.UIInput.new({
        image = "EditBoxBg.png",
        size = cc.size(650, 60),
        x = display.cx,
        y = display.cy,
        listener = function(event, editbox)
            if event == "began" then
                printf("editBox1 event began : text = %s", editbox:getText())
            elseif event == "ended" then
                printf("editBox1 event ended : %s", editbox:getText())
            elseif event == "return" then
                printf("editBox1 event return : %s", editbox:getText())
            elseif event == "changed" then
                printf("editBox1 event changed : %s", editbox:getText())
            else
                printf("EditBox event %s", tostring(event))
            end
        end
    })

    editboxSign:setReturnType(cc.KEYBOARD_RETURNTYPE_SEND)
    self.tabPanel1:addChild(editboxSign)

    local x, y = self.usrSignature_bg:getPosition()
    editboxSign:setPosition(x, y)
    editboxSign:setText("this is good slots game input test let go to the farmer !!!")
end

return FriendInforView
