local MessageShowView = require("app.views.MessageShowView")

local MessageCell = class("MessageCell", function()
    return display.newNode()
end)

--1通知 2奖励消息 3奖励消息长
local msgtype ={
    system = 1,
    reward_collect = 2,
    reward = 3,
}
function MessageCell:ctor(msg)
    self.viewNode  = CCBuilderReaderLoad(RES_CCBI.message_cell, self)
    self:addChild(self.viewNode)
    print(msg.type,msg.title,msg.shortContent,msg.content,msg.state,msg.picture,msg.itemId,msg.itemCnt)
    self.msg = msg
    self:initUI()
end

function MessageCell:initUI()

    self.btns = {}

    if self.msg.type == msgtype.system then
        self:initSystemUI()
    elseif self.msg.type == msgtype.reward_collect then
        self:initRewardCollectUI()
    elseif self.msg.type == msgtype.reward then
        self:initRewardUI()
    end

end

function MessageCell:initSystemUI()

    self.reward_collect:setVisible(false)
    self.reward:setVisible(false)
    self.system:setVisible(true)
    --self.title_system:setString(self.msg.title)
    self.text_system:setString(self.msg.shortContent)

    self.btns[#self.btns+1] = {btn=self.btn_system,
    
    call=function()
        -- body
        net.MessageCS:receiveMsg(self.msg.id, 1, function( msg )
                -- body
                scn.ScnMgr.addView("MessageShowView",{message=self.msg, callback=function()
                    -- body
                    --self:removeSelf()
                end})
            end)
    end

    }
end

function MessageCell:initRewardUI()

    self.reward_collect:setVisible(false)
    self.reward:setVisible(true)
    self.system:setVisible(false)

    --self.title_reward:setString(self.msg.title)
    self.text_reward:setString(self.msg.shortContent)
    if self.msg.picture ~= nil and cc.SpriteFrameCache:getInstance():getSpriteFrame(self.msg.picture) then
        self.image_reward:setSpriteFrame(self.msg.picture)
    end

    self.btns[#self.btns+1] = {btn=self.btn_reward,
    
    call=function()
        -- body
        net.MessageCS:receiveMsg(self.msg.id, 2, function( msg )
                -- body
                scn.ScnMgr.addView("MessageShowView",{message=self.msg, callback=function()
                    -- body
                    print("-----MessageShowView-message=self.msg2---",msg.result,type(msg.result))
                    if tonumber(msg.result) == 1 then
                        local handle = audio.playSound(RES_AUDIO.fly_coins, false)
                        local callback = function()
                            audio.stopSound(handle)
                            print("msg.rewardCoins:",msg.rewardCoins)
                            print("msg.rewardGems:",msg.rewardGems)
                            local totalCoins = app:getUserModel():getCoins() + msg.rewardCoins
                            app:getUserModel():setCoins(totalCoins)

                            local totalGems = app:getUserModel():getGems() + msg.rewardGems
                            app:getUserModel():setGems(totalGems)
                            EventMgr:dispatchEvent({name  = EventMgr.UPDATE_LOBBYUI_EVENT})
                            self:removeSelf()
                        end
                        print("self.text_reward---",self.text_reward or "nil")
                        --AnimationUtil.MoveTo("gold.png",10,self.text_reward, app.coinSprite,callback)
                        AnimationUtil.flyTo("gold.png",10,self.text_reward, app.coinSprite)
                        self:performWithDelay(callback, 1.5)
                    end
                end})
            end)

    end

    }
end

function MessageCell:initRewardCollectUI()

    self.reward_collect:setVisible(true)
    self.reward:setVisible(false)
    self.system:setVisible(false)

    --self.title_reward:setString(self.msg.title)
    self.text_reward:setString(self.msg.shortContent)

    if self.msg.picture ~= nil and cc.SpriteFrameCache:getInstance():getSpriteFrame(self.msg.picture) then
        self.image_reward:setSpriteFrame(self.msg.picture)
    end

    self.btns[#self.btns+1] = {btn=self.btn_reward,

        call=function()
            -- body
            net.MessageCS:receiveMsg(self.msg.id, 2, function( msg )
                -- body
                print("-----MessageShowView-message=self.msg---",msg.result,type(msg.result))
                if tonumber(msg.result) == 1 then
                    local handle = audio.playSound(RES_AUDIO.fly_coins, false)
                    local callback = function()
                        audio.stopSound(handle)
                        print("msg.rewardCoins:",msg.rewardCoins)
                        print("msg.rewardGems:",msg.rewardGems)
                        local totalCoins = app:getUserModel():getCoins() + msg.rewardCoins
                        app:getUserModel():setCoins(totalCoins)

                        local totalGems = app:getUserModel():getGems() + msg.rewardGems
                        app:getUserModel():setGems(totalGems)
                        EventMgr:dispatchEvent({name  = EventMgr.UPDATE_LOBBYUI_EVENT})
                        self:removeSelf()
                    end
                    print("self.text_reward------1111--",self.text_reward or "nil")
                    --AnimationUtil.MoveTo("gold.png",10,self.text_reward, app.coinSprite,callback)
                    AnimationUtil.flyTo("gold.png",10,self.text_reward, app.coinSprite)
                    self:performWithDelay(callback, 1.5)
                end
            end)

        end

    }
end

function MessageCell:removeSelf()
    self.msgsListNode:removeItem(self.item,true)
end


function MessageCell:onTouched(event)
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

return MessageCell