local Cell = class("FriendCell", function()
    return display.newNode()
end)

function Cell:ctor(args)
    self.data = args
    self.viewNode  = CCBReaderLoad("lobby/social/friend_cell.ccbi", self)
    self:addChild(self.viewNode)
    local size = self.viewNode:getContentSize()
    self:setContentSize(size)

    self.nameText:setString(args.name)

    local gameName = ConstantTable.game[args.currentState + 1]
    self.gameText:setString(gameName)


    local headview = headViewClass.new({player=args})
    headview:replaceHead(self.head)

end


function Cell:checkClick(p)
    local tSize = self.sendBtn:getContentSize()
    local tPos = self.sendBtn:getParent():convertToWorldSpace(cc.p(self.sendBtn:getPosition()))
    local rect = cc.rect(tPos.x - tSize.width / 2, tPos.y - tSize.height / 2, tSize.width, tSize.height)
    local isClick  = cc.rectContainsPoint(rect, p)
    if isClick then

        scn.ScnMgr.addView("gift.GiftsView",{tabidx=1,pid=self.data.pid})
    end
end

function Cell:onExit()
    self = {}
end

return Cell
