local DailyLoginRewardView = class("DailyLoginRewardView", function()
    return core.displayEX.newSwallowEnabledNode()
end)


local dayLight  = "label_day"
local dayDark   = "label_day_high"

-- local lableLight   = "lableLight"
-- local lableDark   = "lableDark"

local day_nocollect     = "day_noCollect"
local day_collected     = "day_collected"
local day_collectting   = "day_collectting"

local claimed   = "claimed"
local jiangliNumber   = "jiangliNumber"

local jiangli_coins   ="jiangli_coins"

local crown   = "crown"

function DailyLoginRewardView:ctor(args)
    self:addChild(cc.LayerColor:create(cc.c4b(0, 0, 0, 200)))
    self.viewNode  = CCBuilderReaderLoad(RES_CCBI.dailybonus, self)
    self:addChild(self.viewNode)

    self.args = args

    self.days = 7
    self.isAnimation = false

    print("logindays:", self.args.loginDays, self.days, math.floor( self.args.loginDays / self.days ))

    if self.args.loginDays > 7 then 
        self.args.loginDays = self.args.loginDays - self.days * math.floor( self.args.loginDays / self.days )
    end

    self:init()

    self:registerEvent()

    AnimationUtil.EnterScale(self.viewNode, 0.3)

end

function DailyLoginRewardView:onRemove()
    AnimationUtil.ExitScale(self.viewNode, 0.3,
        function()
            scn.ScnMgr.removeView(self)
        end
    )
end

function DailyLoginRewardView:init()

    for i=1,self.days do

        if i > self.args.loginDays then
            self[day_nocollect..tostring(i)]:setVisible(true)
            self[day_collected..tostring(i)]:setVisible(false)
            self[day_collectting..tostring(i)]:setVisible(false)

            self[claimed..tostring(i)]:setVisible(false)
            self[dayDark..tostring(i)]:setVisible(false)

        elseif i < self.args.loginDays then

            self[day_nocollect..tostring(i)]:setVisible(false)
            self[day_collected..tostring(i)]:setVisible(true)
            self[day_collectting..tostring(i)]:setVisible(false)
            self[claimed..tostring(i)]:setVisible(true)
            self[dayDark..tostring(i)]:setVisible(false)

        else
            self[day_nocollect..tostring(i)]:setVisible(false)
            self[day_collected..tostring(i)]:setVisible(false)
            self[day_collectting..tostring(i)]:setVisible(true)


            if self.args.loginRewardState == 0 then
                self[claimed..tostring(i)]:setVisible(true)
            else
                self[claimed..tostring(i)]:setVisible(false)
                self[dayDark..tostring(i)]:setVisible(true)
            end
        end

    end

    if self.args.loginDays == self.days then
        self[crown..tostring(self.days)]:setVisible(true)
    else
        self[crown..tostring(self.days)]:setVisible(false)
    end
end

function DailyLoginRewardView:registerEvent()
    -- on close
    core.displayEX.newButton(self.collectRewardBtn) 
        :onButtonClicked(function(event)
            if self.isAnimation then return end

            if self.args.loginRewardState == 0 then
                self:onRemove()
                return
            end
            
            --local count = tonumber(self[jiangliNumber..tostring(self.args.loginDays)]:getString())
            local coinLabel = self[jiangli_coins..tostring(self.args.loginDays)]
            local count = tonumber(coinLabel:getString())

            local rtype = ITEM_TYPE.NORMAL_MULITIPLE 

            local function onCallBack(msg)
                if msg.result == 1 then
                    self.isAnimation = true
                    local handle = audio.playSound(RES_AUDIO.fly_coins, false)
                    local callback = function()
                        audio.stopSound(handle) 
                        self.args.loginRewardState = 0

                        app.dailyLoginData = nil

                        if rtype == ITEM_TYPE.NORMAL_MULITIPLE then
                            local totalCoins = app:getUserModel():getCoins() + msg.rewardCoins
                            app:getUserModel():setCoins(totalCoins)
                        end

                        EventMgr:dispatchEvent({name  = EventMgr.UPDATE_LOBBYUI_EVENT})

                        self:onRemove()
                    end

                    --AnimationUtil.MoveTo("gold.png",10,coinLabel, app.coinSprite,callback)
                    AnimationUtil.flyTo("gold.png",10,coinLabel, app.coinSprite)
                    self:performWithDelay(callback, 1.5)

                end

            end
            net.DailyLoginCS:receiveLoginReward(rtype, count, onCallBack)

        end)
end

return DailyLoginRewardView
