
-----------------------------------------------------------
-- BonusWinView 
-----------------------------------------------------------
local BonusWinView = class("BonusWinView", function()
    return display.newNode()
end)

-----------------------------------------------------------
-- Construct 
-- args.numexpress
-- args.strexpress
-- args.totalcoins
-- args.onComplete
-----------------------------------------------------------
function BonusWinView:ctor(args) 

    self:addChild(cc.LayerColor:create(cc.c4b(0, 0, 0, 200)))

    local ccb = "slots/bonuswin.ccbi"
    self.ccbNode = CCBuilderReaderLoad(ccb, self)
    self:addChild(self.ccbNode)
    self:setNodeEventEnabled(true)
    self:setTouchEnabled(true)
    self:setTouchSwallowEnabled(true)
    self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        if event.name == "began" then
            return true
        end
    end)

    self:init()

    self.onComplete = args.onComplete
    self.isAnimation = false
    
    self.expressNum:setString(args.numexpress)
    self.expressStr:setString(args.strexpress)
    --self.winCoinsLabel:setString(tostring(args.totalcoins))

    self.winCoinsLabel:setString("")
    self:performWithDelay(function()
        SlotsMgr.setLabelStepCounter(self.winCoinsLabel, 0, args.totalcoins, 1.5)
        local handle = audio.playSound(RES_AUDIO.number, false)
        self:performWithDelay(function() 
            audio.stopSound(handle) 

            self:gushIntoCoins()
            
            end,1.5)
    end,0.5)

end

-----------------------------------------------------------
-- init 
-----------------------------------------------------------
function BonusWinView:init()

    local okBtn = self.okBtn
    self.okBtn = core.displayEX.newButton(okBtn)
        :onButtonClicked(function() 
            self:shareFacebook()
        end)

    self.closeBtn = core.displayEX.newSmallButton(self.closeBtn)
        :onButtonClicked(function() 
            self:showResult()
        end)

    self.okBtn:setVisible(false)
    self.closeBtn:setVisible(false)
end

function BonusWinView:gushIntoCoins()
    local eff = CCBuilderReaderLoad("view/smallwin.ccbi",{})
    self.actionNode:addChild(eff)

    local fun = function()
        eff:removeFromParent()
        eff = nil

        if device.platform == "ios" then
            self.okBtn:setVisible(true)
        end
        self.closeBtn:setVisible(true)
    end

    self:runFunWithDelay(self.actionNode, fun, 2)
end

function BonusWinView:runFunWithDelay(node, func, time) 
    local cFunc = cc.CallFunc:create(func)
    local delay = cc.DelayTime:create(time)
    local sequence = cc.Sequence:create(delay, cFunc)
    node:runAction(sequence)
    return sequence   
end

function BonusWinView:showResult()
    self.onComplete()
    EventMgr:dispatchEvent({name  = EventMgr.UPDATE_LOBBYUI_EVENT})
end

-----------------------------------------------------------
-- shareFacebook 
-----------------------------------------------------------
function BonusWinView:shareFacebook()
    local islogin = core.FBPlatform.getIsLogin()
    if islogin then
        self:connectToShareFacebook()
    else
        local callback = function(isConnect)
            print("--callback---")
            print("isConnect:", isConnect)
            if isConnect then
                self:connectToShareFacebook()
            else
                self:showResult()
            end
        end

        scn.ScnMgr.addView("FBConnectView",{callback = callback})
    end
end

function BonusWinView:showShareDialog(title, content)
    scn.ScnMgr.addView("CommonView",
        {
            title=title,
            content=content,
            callback=function()
                self:showResult()
            end
        })
end

function BonusWinView:connectToShareFacebook()
    local content = DICT_FACEBOOK_FEED["1"].content
    local params = {
            dialog = "shareLink",
            name   = content.name,
            caption = content.caption,
            description = content.description,
            link   = content.link,
            picture = content.picture,
        }

    core.FBPlatform.share(params, function( ret, msg )
        local invite = json.decode(msg)
        if invite ~= nil then
            --table.dump(invite, "invite")
            if invite.error_message then
                print(invite.error_message )
                self:showShareDialog("Share error", "share to Facebook failed!")
            else
                self:showShareDialog("Congratulations!", "Share Facebook Successful!")
            end
        else
            self:showShareDialog("Share error", "User canceled sharing")
        end
        
    end)
end



-----------------------------------------------------------
-- onExit 
-----------------------------------------------------------
function BonusWinView:onExit()
    self:removeAllNodeEventListeners()
end

return BonusWinView
