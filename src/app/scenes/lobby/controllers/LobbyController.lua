local TopBarClass = require("app.scenes.common.TopBar") 
local LobbyController = class("LobbyController", function() 
    return display.newNode() 
end)

-----------------------------------------------------------
-- 
-----------------------------------------------------------
function LobbyController:ctor()
    --print("LobbyController:ctor")

    self.user_ = app:getObject("UserModel")

    if app.freeBonusData then
        local onComplete = function(msg)
            app.freeBonusData.index = msg.index
            app.freeBonusData.rewardCoins = msg.rewardCoins
            app.freeBonusData.timeLeft = msg.timeLeft
            app.freeBonusData.totalTime = msg.totalTime
            app.freeBonusData.state = msg.state
        end
        net.TimingRewardCS:getTimingRewardState(onComplete)
    end

    local ViewClass = require("app.scenes.lobby.views.LobbyView")
    self.views_ = ViewClass.new({rect={0,0}}):addTo(self)
    self.views_:addEventListener("onTapLobbyCell", handler(self, self.onTapLobbyCell), self)

    self.topBarView = TopBarClass.new({delegate=self.views_, onBackLobby=handler(self, self.onBackLobby), 
        onVipLobby=handler(self, self.onVipLobby), isLobbyView = true})
    self:addChild(self.topBarView)
    self:setNodeEventEnabled(true)

    

    self:registerEvent()

end

-----------------------------------------------------------
-- 
-----------------------------------------------------------
function LobbyController:onBackLobby()
    if self.views_.oldLayoutIdx ~= nil then
        self.views_:addGameList(self.views_.oldLayoutIdx)
        self.views_.oldLayoutIdx = nil
    end

    self.topBarView:setHomeButtonEnabled(false)
end

-----------------------------------------------------------
-- 
-----------------------------------------------------------
function LobbyController:onVipLobby()
    self.views_:addGameList("2")
    self.views_.oldLayoutIdx = "1"
    self.topBarView:setHomeButtonEnabled(true)
end

function LobbyController:onEnter()
    audio.playMusic(RES_AUDIO.bg_lobby)

    self:initBonus()
end

function LobbyController:onExit() 
end

-----------------------------------------------------------
-- 
-----------------------------------------------------------
function LobbyController:exit()
    self.user_:getComponent("components.behavior.EventProtocol"):dumpAllEventListeners()
    self.views_:removeEventListenersByTag(self)
    audio.stopMusic(true)
end

-----------------------------------------------------------
-- 
-----------------------------------------------------------
function LobbyController:needDown(unit)

    local downloadFiles = {}

    local zipname = unit.zipname

    local down = app:getUserModel():getUnitDownLoad(zipname)
    
    --print("zipname",unit.zipname, unit.unit_id)

    if down ~= nil and tonumber(down.needdown)==1 and down.hasdown==0 then
         

        local files = cc.UserDefault:getInstance():getStringForKey(zipname)
        
        if files ~= nil then

            local filearray = string.split(files, ",")
            local num = math.floor(#filearray / 2)
                        
            for i=1, num do
                local df = {}
                df.name     =filearray[2*(i-1) + 1]
                df.md5      =filearray[2*(i-1) + 2]
                df.zipname = zipname

                table.insert(downloadFiles, df)
                --print(zipname, df.name, df.md5)

            end
        end

    end

    if #downloadFiles > 0 then
        scn.ScnMgr.popView("LoadingView",{downloads=downloadFiles})
        return true
    else
        --print("there is no files")
    end

    return false

end

-----------------------------------------------------------
-- 
-----------------------------------------------------------
function LobbyController:onTapLobbyCell(self, event)
    --print("LobbyController:onTapLobbyCell")

    local celltype = event.cell.unit.type
    --print("celltype:", celltype)

    if celltype ~= "Layout" then
        app.layoutId = self.views_.curLayoutIdx

        if self.views_.hasVIPbar then
            if celltype == "Slots" then
                --lock
                local unit = event.cell.unit

                local level = app:getUserModel():getLevel()
                local unitLevel = tonumber(unit.unlock_condition)
                if level < unitLevel then
                    if event.cell.canPullIn then
                        self:showLockMachineTip(event.cell)
                    end

                    return
                end

                if self:needDown(event.cell.unit) == true then
                    return
                end

            end
        else
            if celltype == "Slots" then
                --lock
                local unit = event.cell.unit

                local unitLevel = tonumber(unit.unlock_condition)
                local vipLevel = app:getUserModel():getVipLevel()
                if vipLevel < unitLevel then
                    scn.ScnMgr.addView("VipUnlockTip",{need_vip_level = unitLevel})
                    return
                end

                if self:needDown(event.cell.unit) == true then
                    return
                end

            end
        end
    else
        app.layoutId = nil
    end

    if celltype == "Layout" then
        self.views_:addGameList(event.cell.unit.dict_id)

    elseif celltype == "Store" then

        net.PurchaseCS:GetProductList(function(lists)
            scn.ScnMgr.popView("ProductsView",{productList=lists,tabidx=2})
        end)

    elseif celltype == "TimingReward" then

    elseif celltype == "AD" then
        AdMgr.showAdListView(event.cell.unit.config.special_ad_id)
    elseif celltype == "Facebook" then
       --print("Facebook")
    elseif celltype == "comingsoon" then

    elseif celltype == "Slots" then
        
        local args = {}
        local unit = event.cell.unit
        
        args.animation=true
        SlotsMgr.joinSlotMachine(unit.dict_id,args)
        
    else

    end
end

function LobbyController:showLockMachineTip(cell)
    cell.canPullIn = false

    if cell.owner ~= nil and cell.owner.pullLockBg ~= nil then
        local sequence = transition.sequence({
            cc.MoveTo:create(0.1, cc.p(cell.toPoint.x, cell.toPoint.y)),
        })
        cell.owner.pullLockBg:runAction(sequence)
    end

    self:performWithDelay(function()
        if cell.owner ~= nil and cell.owner.pullLockBg ~= nil then
            sequence = transition.sequence({
                cc.MoveTo:create(0.1, cc.p(cell.fromPoint.x, cell.fromPoint.y)),
            })
            cell.owner.pullLockBg:runAction(sequence)

            self:performWithDelay(function() 
                cell.canPullIn = true
            end,0.1)
        end

    end,3)

end

-- function LobbyController:pullOut(cell)
--     cell.canPullIn = true
--     local sequence = transition.sequence({
--         cc.MoveTo:create(0.3, cc.p(cell.fromPoint.x, cell.fromPoint.y)),
--         cc.FadeOut:create(0.1),
--     })

--     cell.owner.pullLockBg:runAction(sequence)
-- end

-- function LobbyController:pullIn(cell)
--     cell.canPullIn = false
--     local sequence = transition.sequence({
--         cc.FadeIn:create(0.1),
--         cc.MoveTo:create(0.3, cc.p(cell.toPoint.x, cell.toPoint.y)),
--     })

--     cell.owner.pullLockBg:runAction(sequence)
-- end

-----------------------------------------------------------
-- 
-----------------------------------------------------------
function LobbyController:registerEvent()
    --print("LobbyController:registerEvent")
    -- on adBtn
    core.displayEX.newButton(self.views_.adBtn) 
        :onButtonClicked(function(event)
            self.topBarView:setMenuNodeIsVisible(false)
            AdMgr.showAdListView()
        end)

    -- on giftsBtn
    core.displayEX.newButton(self.views_.giftsBtn) 
        :onButtonClicked(function(event)
            self.topBarView:setMenuNodeIsVisible(false)
            scn.ScnMgr.popView("gift.GiftsView",{tabidx=1})
        end)

end

-----------------------------------------------------------
-- initBonus
-----------------------------------------------------------
function LobbyController:initBonus()
    --print("LobbyController:initBonus")
    local function formatTimer(isecs)

        isecs = math.ceil(isecs)

        local function formatSTR(num)
            if num < 10 then
                num = '0'..num
            end
            return num
        end

        local hor = math.modf(isecs/(60 * 60))
        local min = math.modf((isecs - hor * 60 * 60)/60)
        local sec = isecs - hor * 60 * 60 - min * 60

        hor = formatSTR(hor)
        min = formatSTR(min)
        sec = formatSTR(sec)

        local timeStr = hor..':'..min..':'..sec

        return timeStr
    end

    local target = self
    local isAnimation = false

    target.scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
    target.timeleftLabel = self.views_.bonusTimerLabel
    target.collect = self.views_.smallCoinSprite
    target.luckywheel = self.views_.smallWheelNode
    target.rewardCnt = self.views_.rewardCnt
    --target.time_frame = mgr.time_frame

    -- target:setNodeEventEnabled(true)


    function target:initReward(args)

        if args then

        -- args.index = 3
        -- args.state = 1
        -- args.timeLeft = 90

            target.index = args.index
            target.state = args.state
            target.timeLeft = args.timeLeft
            target.totalTime = args.totalTime
        end

        print("initReward--------",target.index, target.state, target.timeLeft, target.totalTime)

        if target.state == 1 then
            if target.index == 4 then
                target.views_.bgNode:setVisible(false)
                target.views_.progressNode:setVisible(false)
                target.luckywheel:setVisible(true)
                target.collect:setVisible(false)

                self:runAnimation("idle")
            else
                target.views_.bgNode:setVisible(true)
                target.views_.progressNode:setVisible(true)
                target.luckywheel:setVisible(false)
                target.collect:setVisible(true)
                self:runAnimation("collect")
            end

            target.rewardCnt:setString(tostring(target.rewardCoins))
        else
            target.views_.bgNode:setVisible(true)
            --target.collect:setVisible(false)
            target.luckywheel:setVisible(false)
            target.views_.progressNode:setVisible(true)

            if isAnimation then
                
                self:runAnimation("disappear")

                local func = function()
                    isAnimation = false
                    target.collect:setVisible(false)
                end

                local delay = cc.DelayTime:create(1)
                local callfunc = cc.CallFunc:create(func)
                local sequence = cc.Sequence:create(delay, callfunc)
                self:runAction(sequence)
            else
                self:runAnimation("idle")
                target.collect:setVisible(false)
            end

            target:startTimer()
        end

        for i=1,5 do
            if i > target.index then
                target.views_["proSp"..tostring(i)]:setVisible(false) 
            else
                target.views_["proSp"..tostring(i)]:setVisible(true) 
            end
        end

        if target.state == 1 then
            target.views_["proSp"..tostring(target.index+1)]:setVisible(true) 
        end
        
    end


    function target:endTimer()
        if target.schEntry  then 
            target.scheduler.unscheduleGlobal(target.schEntry) 
            target.schEntry = nil
        end
    end
    
    function target:startTimer()

        local tick = function(dt)
            --print(dt)
            self.timeLeft = self.timeLeft - dt
            self.timeleftLabel:setString(formatTimer(self.timeLeft))

            if self.timeLeft < 0 then 
                self:endTimer()
                self.state = 1
                self:initReward()
            end
        end

        self.schEntry = self.scheduler.scheduleGlobal(tick , 0)

    end

    function target:onExit()
        self:endTimer()
    end

    target.rewardCoins = app.freeBonusData.rewardCoins
    target:initReward(app.freeBonusData)
    target.timeleftLabel:setString(formatTimer(target.timeLeft))
    target.timeleftLabel:enableOutline(cc.c4b(32, 32, 32, 255), 2)

    --- registerEvent
    --- get coin
    target.views_.smallCoinSprite:setTouchEnabled(true)
    target.views_.smallCoinSprite:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        if event.name == "began" then
            -- print("target.views_.smallCoinSprite began")
            if isAnimation then return true end
            
            local callfunction = function(msg)

                print("pickTimingReward: ",tostring(msg))

                if msg.result == 1 then

                    app.freeBonusData = {}
                    
                    app.freeBonusData.index = msg.index
                    app.freeBonusData.timeLeft = msg.timeLeft
                    app.freeBonusData.totalTime = msg.totalTime
                    app.freeBonusData.rewardCoins = msg.rewardCoins
                    app.freeBonusData.state = 0

                    isAnimation = true
                    local handle = audio.playSound(RES_AUDIO.fly_coins, false)
                    local callback = function()
                        audio.stopSound(handle) 
                        local totalCoins = app:getUserModel():getCoins() + msg.rewardCoins
                        app:getUserModel():setCoins(totalCoins)
                        EventMgr:dispatchEvent({name = EventMgr.UPDATE_LOBBYUI_EVENT})

                        print("Free Bonus Win !!!!")

                        self:initReward(app.freeBonusData)
                    end
                    --AnimationUtil.MoveTo("gold.png",10,target.rewardCnt, app.coinSprite,callback)
                    AnimationUtil.flyTo("gold.png",10,target.rewardCnt, app.coinSprite)
                    self:performWithDelay(callback, 1)

                end
            end

            net.TimingRewardCS:pickTimingReward(callfunction)
            

            return true
        end
    end)

    -- bg
    target.views_.bgNode:setTouchEnabled(true)
    target.views_.bgNode:setTouchSwallowEnabled(true)
    target.views_.bgNode:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        if event.name == "began" then
            --print("target.views_.bgNode began")
            return true
        end
    end)

    -- smallwheel
    target.views_.luckywheel:setTouchEnabled(true)
    target.views_.luckywheel:setTouchSwallowEnabled(true)
    target.views_.luckywheel:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        if event.name == "began" then
            scn.ScnMgr.popView("WheelBonus",target)
            --print("target.views_.luckywheel began")
            return true
        end
    end)


end

--------------------------------------
-- runWinAnimation 
--------------------------------------
function LobbyController:runAnimation( name )
    --print("name:", name)

    self.views_:runSpecialBonusAnimation(name)
end


return LobbyController
