local RateOnUs = class("RateOnUs", function()
    return core.displayEX.newSwallowEnabledNode()
end)

function RateOnUs:ctor(args)
    self:addChild(cc.LayerColor:create(cc.c4b(0, 0, 0, 200)))
    self.viewNode  = CCBuilderReaderLoad("view/rate.ccbi", self)
    self:addChild(self.viewNode)

    self.coins = args.coins
    --self.coinLabel:setString(number.commaSeperate(self.coins))
    self.isAnimation = false

    self:registerEvent()

    self.coinLabel:setString("")

    self:performWithDelay(function()
        SlotsMgr.setLabelStepCounter(self.coinLabel, 0, args.coins, 1.5)
        local handle = audio.playSound(RES_AUDIO.number, false)
        self:performWithDelay(function() 
            audio.stopSound(handle) 
            self.btn_ok:setVisible(true)
            self.btn_later:setVisible(true)
            end,1.5)
    end,0.5)
end


function RateOnUs:registerEvent()

    self.btn_ok = core.displayEX.newButton(self.btn_ok)
        :onButtonClicked(function(event)
             if self.isAnimation then return end
             self:flyCoins()
        end)

    self.btn_later = core.displayEX.newButton(self.btn_later)
        :onButtonClicked(function(event)
            if self.isAnimation then return end

            scn.ScnMgr.removeView(self)
        end)

    self.btn_ok:setVisible(false)
    self.btn_later:setVisible(false)
end

function RateOnUs:flyCoins()
    self.isAnimation = true
    local handle = audio.playSound(RES_AUDIO.fly_coins, false)
    local callback = function()
            audio.stopSound(handle) 
            local model = app:getObject("UserModel")
            local coins = model:getCoins()
            model:setCoins(coins + self.coins)
            EventMgr:dispatchEvent({name  = EventMgr.UPDATE_LOBBYUI_EVENT})

            local properties = model:getProperties({model.class.extinfo})
            local ei = properties[model.class.extinfo]
            ei[model.class.ei.rateSign] = 1
            local temp = {}
            temp[model.class.extinfo] = ei

            local models = app:getObject("UserModel")
            local properties = models:getProperties({model.class.extinfo})
            print("-----properties.rateSign=",properties[model.class.extinfo][model.class.ei.rateSign])

            CCAccountManager:downloadNewApp()

            net.UserCS:RateUsBack()

            scn.ScnMgr.removeView(self)
    end
    --AnimationUtil.MoveTo("gold.png",10,self.coinLabel, app.coinSprite,callback)
    AnimationUtil.flyTo("gold.png",10,self.coinLabel, app.coinSprite)
    self:performWithDelay(callback, 1.5)
end

return RateOnUs
