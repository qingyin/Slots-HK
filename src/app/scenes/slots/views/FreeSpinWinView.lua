
-----------------------------------------------------------
-- FreeSpinWinView 
-----------------------------------------------------------
local FreeSpinWinView = class("FreeSpinWinView", function()
    return display.newNode()
end)

-----------------------------------------------------------
-- Construct 
-- args.coins
-- args.okHandle
-----------------------------------------------------------
function FreeSpinWinView:ctor(args) 
    self:addChild(cc.LayerColor:create(cc.c4b(0, 0, 0, 200)))
    self.coins = args.coins
    self.okHandle = args.okHandle

    local ccb = "slots/freespinwin.ccbi"
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

    self.coinLabel:setString("")

    self:performWithDelay(function()
        SlotsMgr.setLabelStepCounter(self.coinLabel, 0, self.coins, 1)
        local handle = audio.playSound(RES_AUDIO.number, false)
        self:performWithDelay(function() 
            audio.stopSound(handle)

            local flyhandle = audio.playSound(RES_AUDIO.fly_coins, false)
            local callback = function()
                audio.stopSound(flyhandle)

                if device.platform == "ios" then
                    self.okBtn:setVisible(true)
                end
                self.closeBtn:setVisible(true)
            end
            --AnimationUtil.MoveTo("gold.png",10,self.coinLabel, app.coinSprite,callback)
            AnimationUtil.flyTo("gold.png",10,self.coinLabel, app.coinSprite)
            self:performWithDelay(callback, 1.5)

            end,1)
    end,0.5)

end

function FreeSpinWinView:init()
    core.displayEX.newButton(self.okBtn)
        :onButtonClicked(function() 
            self:shareFacebook()
        end)

    core.displayEX.newSmallButton(self.closeBtn)
        :onButtonClicked(function() 
            if self.okHandle then
                self.okHandle()
            end
            self:removeFromParent() 
        end)
    self.okBtn:setVisible(false)
    self.closeBtn:setVisible(false)
end

function FreeSpinWinView:onEnter()


end



-----------------------------------------------------------
-- shareFacebook 
-----------------------------------------------------------
function FreeSpinWinView:shareFacebook()
    local islogin = core.FBPlatform.getIsLogin()
    if islogin then
        self:connectToShareFacebook()
    else
        local callback = function(isConnect)
            if isConnect then
                self:connectToShareFacebook()
            else
                if self.okHandle then
                    self.okHandle()
                end
                self:removeFromParent() 
            end
        end

        scn.ScnMgr.addView("FBConnectView",{callback = callback})
    end
end

function FreeSpinWinView:connectToShareFacebook()
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

function FreeSpinWinView:showShareDialog(title, content)
    scn.ScnMgr.addView("CommonView",
        {
            title=title,
            content=content,
            callback=function()
                if self.okHandle then
                    self.okHandle()
                end
                self:removeFromParent() 
            end
        })
end

-----------------------------------------------------------
-- onExit 
-----------------------------------------------------------
function FreeSpinWinView:onExit()
    self:removeAllNodeEventListeners()
end

return FreeSpinWinView
