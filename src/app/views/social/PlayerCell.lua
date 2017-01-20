local Cell = class("PlayerCell", function()
return display.newNode()
end)

function Cell:ctor(args)
    self.viewNode  = CCBReaderLoad("lobby/social/player_cell.ccbi", self)
    self:addChild(self.viewNode)
    local size = self.viewNode:getContentSize()
    self:setContentSize(size)
    self.headSprite:setSpriteFrame(HEAD_IMAGE[args.pictureId])
    local gameName = ConstantTable.game[args.currentState + 1]
    self.gameText:setString(gameName)
    self.data = args
end

function Cell:addMe()
    net.FriendsCS:addFriend(self.data.pid)
    scn.ScnMgr.addView("CommonView",
        {
            title="add friend",
            content="have been added "..self.data.name.." as a friend ."
        })
end

function Cell:checkClick(p)
    local tSize = self.addMeBtn:getContentSize()
    local tPos = self.addMeBtn:getParent():convertToWorldSpace(cc.p(self.addMeBtn:getPosition()))
    local rect = cc.rect(tPos.x - tSize.width / 2, tPos.y - tSize.height / 2, tSize.width, tSize.height)
    local isClick  = cc.rectContainsPoint(rect, p)
    if isClick then
        self:addMe()
    else
        local function onComplete(infos)
            scn.ScnMgr.addView("social.FriendInforView",{info=infos})
        end
        net.UserCS:getPlayerInfo(self.data.pid, onComplete)
    end
end

return Cell
