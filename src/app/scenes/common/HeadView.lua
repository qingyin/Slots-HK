local HeadView = class("HeadView", function()
    return display.newNode()
end)

function HeadView:ctor(val)
    self.viewNode  = CCBReaderLoad("view/share_head.ccbi", self)
    self:addChild(self.viewNode)

    if val.scale then
        self.viewNode:setScale(val.scale)
    end

    local size = self.viewNode:getContentSize()
    self:setContentSize(size)
    
    self.touchEnabled = true
    self.player = val.player

    --self.head:setSpriteFrame(HEAD_IMAGE[self.player.pictureId])

    if self.player.level then
        self.level:setString(tostring(self.player.level))
    end

end

function HeadView:getLevel()
    return tonumber(self.level:getString())
end

function HeadView:showUserName()
    self.nameNode:setVisible(true)
    self.levelNode:setVisible(false)
    self.name:setString(self.player.name)
end

function HeadView:showGameName()
    self.nameNode:setVisible(true)
    self.levelNode:setVisible(false)
    self.name:setString(ConstantTable.game[self.player.currentState + 1])
end

function HeadView:registClickHead(isme)

    if isme then
        core.displayEX.newButton(self.clickBtn) 
                :onButtonClicked(function(event)

                scn.ScnMgr.addView("social.FriendInforView")

            end)    
    else
        core.displayEX.newButton(self.clickBtn) 
            :onButtonClicked(function(event)            
            
            local function onComplete(infos)                
                scn.ScnMgr.addView("social.FriendInforView",{info=infos})
            end

            net.UserCS:getPlayerInfo(self.player.pid, onComplete)
            
        end)
    end
end

function HeadView:setButtonEnabled(val)
    self.clickBtn:setButtonEnabled(val)
end

function HeadView:onClickHead()

    local function onComplete(infos)                
        scn.ScnMgr.addView("social.FriendInforView",{info=infos})
    end

    net.UserCS:getPlayerInfo(self.player.pid, onComplete)

end

function HeadView:replaceHead(headImage)

    local parent = headImage:getParent()

    local x, y = headImage:getPosition()
    headImage:removeFromParent()

    self:setPosition(cc.p(x, y))
    
    parent:addChild(self)

end


function HeadView:updateHeadImage(pictureId)
    self.head:setSpriteFrame(HEAD_IMAGE[pictureId])
end

return HeadView

