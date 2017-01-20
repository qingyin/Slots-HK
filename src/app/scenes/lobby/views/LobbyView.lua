
local LobbyCell = require("app.scenes.lobby.views.LobbyCell")

local LobbyView = class("LobbyView", function()
    return display.newNode()
end)

function LobbyView:ctor(args)

    self.hasUpdate = false
    self.hasVIPbar = true

    self.curLayoutIdx = nil
    self.oldLayoutIdx = nil

    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    self.viewCenter = CCBuilderReaderLoad("lobby/lobby.ccbi", self)
    
    self:addChild(self.viewCenter)

    self.rect = cc.rect(0,0,0,0)

    self.rect.width = self.gamelistNode:getContentSize().width
    self.rect.height = self.gamelistNode:getContentSize().height 
    
    local topScale = display.width/1136
    self.top:setScale(topScale)

    local bottomScale = display.height/768

    if bottomScale > topScale then
        bottomScale = topScale
    end
    
    self:setNodeEventEnabled(true)
    self.bottom:setScale(bottomScale)

    self:Layout()

end

function LobbyView:runSpecialBonusAnimation(acName)
    self.specialBonusNode.animationManager:runAnimationsForSequenceNamed(acName)
end

function LobbyView:onEnter()
    if app.layoutId then
        self:addGameList(tostring(app.layoutId))
        self.curLayoutIdx = app.layoutId
        self.oldLayoutIdx = "1"
    else
        self:addGameList("1")
    end

    EventMgr:addEventListener(EventMgr.UPDATE_LOBBYUI_EVENT, handler(self, self.updateUIState))
end

function LobbyView:onExit()
    EventMgr:removeEventListenersByEvent(EventMgr.UPDATE_PLAYERS_EVENT)
    EventMgr:removeEventListenersByEvent(EventMgr.UPDATE_LOBBYUI_EVENT)
end

function LobbyView:updateUIState(event)
    --print("LobbyView:updateUIState")
    if self.gamesList then 
        local userModel = app:getUserModel()
        if self.hasVIPbar then
            local level = userModel:getLevel()

            for i,v in ipairs(self.gamesList.items_) do
                local cellnum = #v.cells
                
                for count = 1, cellnum do
                    local cell = v.cells[count]
                    local unit = cell.unit
                    if unit.type == "Slots" then
                        local unitLevel = tonumber(unit.unlock_condition)
                        if level >= unitLevel then
                            local down = app:getUserModel():getUnitDownLoad(unit.zipname)
                            if down ~= nil and tonumber(down.needdown)==1 and down.hasdown==1 then
                                cell.owner.downLoadSprite:setVisible(false)
                            elseif down ~= nil and tonumber(down.needdown)==1 and down.hasdown==0 then
                                cell.owner.downLoadSprite:setVisible(true)
                            end
                            cell.owner.lockSprite:setVisible(false)
                        else
                            cell.owner.downLoadSprite:setVisible(false)
                            cell.owner.lockSprite:setVisible(true)
                        end

                    elseif unit.type == "comingsoon" then
                        cell.owner.downLoadSprite:setVisible(false)
                        cell.owner.lockSprite:setVisible(false)
                    end
                end
            end
            ----------------------------------------------------
        else
            local vipLevel = userModel:getVipLevel()

            for i,v in ipairs(self.gamesList.items_) do
                local cellnum = #v.cells
                
                for count = 1, cellnum do
                    local cell = v.cells[count]
                    local unit = cell.unit
                    if unit.type == "Slots" then
                        local unitLevel = tonumber(unit.unlock_condition)
                        if vipLevel >= unitLevel then
                            local down = app:getUserModel():getUnitDownLoad(unit.zipname)
                            if down ~= nil and tonumber(down.needdown)==1 and down.hasdown==1 then
                                cell.owner.vip_down:setVisible(false)
                                cell.owner.vip_go:setVisible(true)
                            elseif down ~= nil and tonumber(down.needdown)==1 and down.hasdown==0 then
                                cell.owner.vip_down:setVisible(true)
                                cell.owner.vip_go:setVisible(false)
                            end
                        else
                            cell.owner.vip_down:setVisible(false)
                            cell.owner.vip_go:setVisible(false)
                        end

                    elseif unit.type == "comingsoon" then
                        cell.owner.vip_down:setVisible(false)
                        cell.owner.vip_go:setVisible(false)
                    end
                end
            end
            ----------------------------------------------------
        end
    end
end

function LobbyView:addGameList(layoutIdx)
    --print("addGameList:", layoutIdx)
    if tonumber(layoutIdx) == 2 then
        self.bgSprite:setVisible(false)
        self.vipbgSprite:setVisible(true)

    else
        self.bgSprite:setVisible(true)
        self.vipbgSprite:setVisible(false)

    end
    
    self.oldLayoutIdx = self.curLayoutIdx
    self.curLayoutIdx = layoutIdx

    if self.gamesList then 
        
        self.gamesList:onCleanup() 
        self.gamesList:removeAllItems()
        
        if self.hasVIPbar == true then
            self.vipNode:removeFromParent(true)
        else
            self.backNode:removeFromParent(true)
        end

    else
        self.gamesList = cc.ui.UIListView.new {
            -- bgColor = cc.c4b(200, 200, 200, 120),
            bg = nil,
            bgScale9 = false,
            viewRect = self.rect,
            direction = cc.ui.UIScrollView.DIRECTION_HORIZONTAL,
            scrollbarImgV = nil
        }
        
        self.gamesList:setPosition(0,0)
        self.gamesList:setAnchorPoint(cc.p(0.5,0.5))
        self.gamesList:ignoreAnchorPointForPosition(false)
        
        self.gamesList:addTo(self.gamelistNode)
        self.gamesList:onTouch(handler(self, self.onGamelistListener))

    end

    self:addVIPbar(layoutIdx)

    self:addGoToBackBar(layoutIdx)

    --print("self.hasVIPbar", self.hasVIPbar)
    if self.hasVIPbar then
        EventMgr:dispatchEvent({name  = EventMgr.UPDATE_HOME_EVENT})
    else
        EventMgr:dispatchEvent({name  = EventMgr.UPDATE_VIP_EVENT})
    end

-- add items
    local lobbyLayout = DICT_LAYOUT[tostring(layoutIdx)]
    if lobbyLayout == nil then
        print("layout idx is null", layoutIdx)
    end
    local cells = lobbyLayout.contain_unit
    local cols = #cells

    local startIdx = 0

    if self.hasVIPbar == true then
        startIdx = 0
    else
        startIdx = 0
    end


    for i=startIdx, cols do

        local item = self.gamesList:newItem()

        local content = display.newNode()
        local itemsize = {width=0,height=0}
        item.cells = {}

        if i > 0 then

            item.isgame = true

            local colcells = cells[i]

            local numCells = #colcells
            local mrow = self.rect.height/(2*numCells)

            for cellidx = 1, numCells do

                local unitidx = colcells[cellidx]
                local unit = DICT_UNIT[tostring(unitidx)]

                if unit ~= nil then

                    local idx = (i-1)*2 + cellidx
                    local fccbi=SUBPATH.GAMECELL..unit.ccb..FILE_SUFFIX.CCBI
                    local owner = {}
                    local cell = CCBuilderReaderLoad(fccbi, owner)
                    
                    cell.owner = owner

                    if unit.type == "Slots" then
                        local machineId = unit.dict_id
                        LobbyCell.extendSlotsCell(cell, owner, machineId)

                        if self.hasVIPbar == true and tonumber(unit.unlock_condition) > 1 then
                            self:clippingLockRegion(cell)
                        end
                    end
                    
                    local size = cell:getContentSize()

                    local scale = 2*mrow / ( size.height + 6 ) 
                    if fccbi == "lobby/cell/cell_slots_now_comingsoon.ccbi" then
                        scale = 2*mrow / ( size.height - 10)
                    end


                    if scale < 1 then
                        cell:setScale(scale)
                    end

                    itemsize.width = 35 + size.width

                    -- if tonumber(layoutIdx) == 2 then
                    --     itemsize.width = display.width*1/4 
                    -- end

                    itemsize.height = size.height + itemsize.height * (display.height/768)

                    local posY = 0

                     if numCells == 1 then
                        
                        posY = 0

                    elseif numCells == 2 then

                        if cellidx == 1 then
                            posY = mrow
                        else
                            posY = -mrow
                        end

                    elseif numCells == 3 then

                        if cellidx == 1 then
                            posY = -2*mrow
                        elseif cellidx == 2 then
                            posY = 0
                        else
                            posY = 2*mrow
                        end

                    end

                    cell:setPositionY(posY)
                    content:addChild(cell)

                    cell.isgame = true
                    cell.idx = cellidx
                    cell.unit = clone(unit)
                    cell.unitidx=unitidx
                    item.cells[#item.cells + 1] = cell

                end
            end
        else

            itemsize.width = display.width*1/4
            if tonumber(layoutIdx) == 2 then
                itemsize.width = display.width*1/4 - 75
            end
            itemsize.height = self.rect.height

        end

        item:addContent(content)
        item:setPositionY(self.rect.height/2)
        item:setItemSize(itemsize.width, self.rect.height)
        self.gamesList:addItem(item)
        
    end

    --test
    self:updateUIState()

    self.gamesList:reload()
    
    local idx = 1

    for i,v in ipairs(self.gamesList.items_) do

        if idx < 5 then
            
            local posX, posY = v:getPosition()
            v:setPositionX(posX+display.width-200)
            transition.moveTo(v, {x=posX, y=posY, time=0.1+0.1*idx, delay = 0.1,easing="SINEOUT",
                onComplete=function()
                end})
        end

        idx = idx + 1
    end
    
end

function LobbyView:addVIPbar(layoutIdx)
    if layoutIdx ~= "1" then
        self.hasVIPbar = false

        --self:addBackToMachine()
        return
    end

    self.hasVIPbar = true 

    local ccb =  "lobby/cell/cell_vip_machine.ccbi"
    local ccbNode = CCBuilderReaderLoad(ccb, self)

    self.vipNode = ccbNode

    local vipNodeY = self.gamelistNode:getContentSize().height * 0.5
    local vipNodeX = display.width*1/4 - self.vipSprite:getContentSize().width * 0.5

    self.vipSprite:setPosition(vipNodeX, vipNodeY)
    self.gamelistNode:addChild(ccbNode)
    
    self.vipSprite:setScale( 0.9 * self.gamelistNode:getContentSize().height/self.vipSprite:getContentSize().height)--display.height/768)

    self.vipSprite:setPositionX(vipNodeX-300)
    transition.moveTo(self.vipSprite, {x=vipNodeX, y=vipNodeY, time=0.3, delay = 0.1,easing="SINEOUT",
        onComplete=function()
    end})

    self.vipSprite:setNodeEventEnabled(true)
    self.vipSprite:setTouchEnabled(true)
    self.vipSprite:setTouchSwallowEnabled(true)

    self.vipSprite:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        if event.name == "began" then
            EventMgr:dispatchEvent({name  = EventMgr.UPDATE_TOPBACK_EVENT})
            self:addGameList("2")
            return true
        end
    end)

end

function LobbyView:addGoToBackBar(layoutIdx)
    if layoutIdx ~= "2" then
        self.hasVIPbar = true

        return
    end

    self.hasVIPbar = false 

    local ccb =  "lobby/cell/machine_icon_left.ccbi"
    local ccbNode = CCBuilderReaderLoad(ccb, self)
    ccbNode:setScale(0.65)

    self.backNode = ccbNode

    local size = self.backNode:getContentSize()
    self.backNode:setPositionX(-size.width)
    local originY = (self.gamelistNode:getContentSize().height - size.height*0.65)/2
    print("originY:", originY)
    self.backNode:setPositionY(originY)
    self.gamelistNode:addChild(ccbNode)

    transition.moveTo(self.backNode, {x=30, y=originY, time=0.3, delay = 0.1,easing="SINEOUT",
        onComplete=function()
    end})

    self.doorSprite:setNodeEventEnabled(true)
    self.doorSprite:setTouchEnabled(true)
    self.doorSprite:setTouchSwallowEnabled(true)

    self.doorSprite:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        if event.name == "began" then
            EventMgr:dispatchEvent({name  = EventMgr.UPDATE_BACKHOME_EVENT})
            self:addGameList("1")
            return true
        end
    end)

end

function LobbyView:onGamelistListener(event)
    local listView = event.listView
    if "clicked" == event.name then
        local p = cc.p(event.x, event.y)

        if event.item.cells == nil then return end

        local cellnum = #event.item.cells
        
        for count = 1, cellnum do
            local cell = event.item.cells[count]
            local boundingBox = cell:getCascadeBoundingBox()
            if cc.rectContainsPoint(boundingBox, p) then
                self:dispatchEvent({name = "onTapLobbyCell", cell=cell})
                return
            else
            end
        end

    elseif "moved" == event.name then
        self.bListViewMove = true
    elseif "ended" == event.name then
        self.bListViewMove = false
    else
        print("event name:" .. event.name)
    end
end

-----------------------------------------------------------
-- clippingLockRegion 
-----------------------------------------------------------
function LobbyView:clippingLockRegion(cell)
    local clippingRegion = cc.ClippingRegionNode:create()
    local x = cell.owner.pullLockBg:getPositionX()
    local y = cell.owner.pullLockBg:getPositionY()
    local width = cell.owner.pullLockBg:getContentSize().width
    local height = cell.owner.pullLockBg:getContentSize().height

    clippingRegion:setClippingRegion(cc.rect(0, 0, width+5, height))

    local pullbgRect = cell.owner.pullLockBg
    local parent = pullbgRect:getParent()

    pullbgRect:removeFromParent(false)

    clippingRegion:addChild(pullbgRect)
    --clippingRegion:addChild(cc.LayerColor:create(cc.c4b(255, 0, 0, 90)))

    parent:addChild(clippingRegion)
    pullbgRect:setPosition(x-width-10, y)

    cell.fromPoint = cc.p(x-width-10,y)
    cell.toPoint = cc.p(x-10,y)
    cell.canPullIn = true
end

return LobbyView
