local ScnAnimView = require("app.scenes.common.ScnAnimView")

-----------------------------------------------------------
-- MachineVew 
-----------------------------------------------------------
local MachineVew = class("MachineVew", function()
    return display.newNode()
end)

-----------------------------------------------------------
-- Construct 
-- args.machineId
-----------------------------------------------------------
function MachineVew:ctor(args) 

    self.machineId  = args.machineId

    local machRes = DICT_MAC_RES[tostring(self.machineId)]

    self.machine = CCBuilderReaderLoad(machRes.ccbi, self)

    self.machine:setAnchorPoint(0.5, 0.5)
    self.machine:ignoreAnchorPointForPosition(false)

    if display.height > 640 then

        local machineviewScale = 0.95 * display.height / 640
        self.machine:setScale(machineviewScale)
        
    end

    self:addChild(self.machine)
    self.multNode = self.multccb
    self.animView = ScnAnimView.new({machineScn=self.machine, animccbi=machRes.animccbi})

    self.colLayer = {}
    self.frcolLayer = {}
    self.syLayerSize = self.symbolsColsLayer:getContentSize()

    self.greyLayer:setVisible(false)
    self:setNodeEventEnabled(true)
    self.inUseGreyLayer = self.greyLayer
    self.inUseEffLayer = self.effectsLayer
    self.inUseSymLayer = self.symbolsColsLayer

    self:upMultSpriteForBase()

    self:init()

    self.baseMachineNode:setScale(0.8)

    self.animView:playOnEnter()

    self:loadSpriteFrame()

end

-----------------------------------------------------------
-- init 
-----------------------------------------------------------
function MachineVew:init()

    local clippingRegion = cc.ClippingRectangleNode:create()

    clippingRegion:setClippingRegion(cc.rect(
        self.symbolsRect:getPositionX() - self.syLayerSize.width/2, 
        self.symbolsRect:getPositionY() - self.syLayerSize.height/2,
        self.symbolsRect:getContentSize().width, 
        self.symbolsRect:getContentSize().height))

    local symbolsRect = self.symbolsRect
    local parent = symbolsRect:getParent()
    symbolsRect:removeFromParent(false)

    clippingRegion:addChild(symbolsRect)
    parent:addChild(clippingRegion)

end

-----------------------------------------------------------
-- getUIbottomPosY 
-----------------------------------------------------------
function MachineVew:getUIbottomPosY()
    local y = self.machineUIsp:getPositionY() - self.machineUIsp:getContentSize().height/2
    local pos = cc.p(0,y)
    local wPos = self.machineUIsp:getParent():convertToWorldSpace(pos)
    return wPos.y
end

-----------------------------------------------------------
-- getMachineNodePosisionY 
-----------------------------------------------------------
function MachineVew:getMachineNodePosisionY()
    return self.baseMachineNode:getPositionY()
end

-----------------------------------------------------------
-- setMachineNodePosisionY 
-----------------------------------------------------------
function MachineVew:setMachineNodePosisionY(y)
    self.baseMachineNode:setPositionY(y)
end

-----------------------------------------------------------
-- getSyLayer 
-----------------------------------------------------------
function MachineVew:getSyLayer()
   return self.inUseSymLayer
end

-- -----------------------------------------------------------
-- -- setFrLabel 
-- -----------------------------------------------------------
-- function MachineVew:setFrLabel( str )
--     self.FreeSpinCounterLabel:setString(str)
-- end

-- -----------------------------------------------------------
-- -- showFrLabel 
-- -----------------------------------------------------------
-- function MachineVew:showFrLabel()
--     self.FreeSpinCounterLabel:setVisible(true)
-- end

-- -----------------------------------------------------------
-- -- hideFrLabel 
-- -----------------------------------------------------------
-- function MachineVew:hideFrLabel()
--     self.FreeSpinCounterLabel:setVisible(false)
-- end

-----------------------------------------------------------
-- addColLayer
-----------------------------------------------------------
function MachineVew:addColLayer(col, vlayer )
    self.colLayer[col] = vlayer
	self.symbolsColsLayer:addChild(vlayer)
end

-----------------------------------------------------------
-- getSymbolLayerWidth 
-----------------------------------------------------------
function MachineVew:getSymbolLayerWidth()
	return self.syLayerSize.width
end

-----------------------------------------------------------
-- showGreyLayer 
-----------------------------------------------------------
function MachineVew:showGreyLayer()
    self.inUseGreyLayer:setVisible(true)
end

-----------------------------------------------------------
-- hideGreyLayer 
-----------------------------------------------------------
function MachineVew:hideGreyLayer()
    self.inUseGreyLayer:setVisible(false)
end

-----------------------------------------------------------
-- getSymbolLayerHeight 
-----------------------------------------------------------
function MachineVew:getSymbolLayerHeight()
	return self.syLayerSize.height
end

-----------------------------------------------------------
-- getGreyLayer 
-----------------------------------------------------------
function MachineVew:getGreyLayer()
    return self.inUseGreyLayer
end

-----------------------------------------------------------
-- getAnimtionsLayer 
-----------------------------------------------------------
function MachineVew:getAnimtionsLayer()
    return self.animtionsLayer
end

-----------------------------------------------------------
-- playShowBaseMachine 
-----------------------------------------------------------
function MachineVew:playShowBaseMachine()
    self.animView:playOnExit()
end

-----------------------------------------------------------
-- playShowFreeMachine 
-----------------------------------------------------------
function MachineVew:playShowFreeMachine()
    self.animView:playOnEnter()
end

-----------------------------------------------------------
-- addEff 
-----------------------------------------------------------
function MachineVew:addEff( eff )
    self.inUseEffLayer:addChild(eff)
end

-----------------------------------------------------------
-- enterFreeSpin 
-----------------------------------------------------------
function MachineVew:enterFreeSpin( vtime )

    local actions = {}
    local showTime = 1.5

    actions[#actions+1] = cc.DelayTime:create(vtime)
    actions[#actions+1] = cc.CallFunc:create(function()
        self:fadeInAllChildrens(self.multccb, 0)
        if self.multccb then
            self:upMultSpriteForFree()
            self.multccb.animationManager:
            runAnimationsForSequenceNamed('idle')
        end
        self.animView:playOnExit()
    end)

    actions[#actions+1] = cc.DelayTime:create(showTime)
    actions[#actions+1] = cc.CallFunc:create(function()
        self.animView:playOnEnter()
    end)

    local sq = transition.sequence(actions)
    self:runAction(sq)

    return showTime * 2 --+ vtime

end

-----------------------------------------------------------
-- backToBaseMachine 
-----------------------------------------------------------
function MachineVew:backToBaseMachine()

    local actions = {}
    local showTime = 1.5
    
    actions[#actions+1] = cc.CallFunc:create(function()
        if self.multccb then
            self:upMultSpriteForBase()
        end
        self.animView:playOnExit()
    end)

    actions[#actions+1] = cc.DelayTime:create(showTime)
    actions[#actions+1] = cc.CallFunc:create(function()
        self.animView:playOnEnter()
    end)

    local sq = transition.sequence(actions)
    self:runAction(sq)

    return  showTime * 2

end

-----------------------------------------------------------
-- fadeInAllChildrens 
-----------------------------------------------------------
function MachineVew:fadeInAllChildrens(target, fadeTime, callback)

    if not target then return end

    local function fadeIn(target)
        transition.fadeIn(target,{time = fadeTime})
    end

    local function fadeInAllChildrens(target)
        fadeIn(target)
        local childrens = target:getChildren()
        for i=1, table.getn(childrens) do
            if childrens[i]:getChildrenCount() > 0 then
                fadeInAllChildrens(childrens[i])
            else
                fadeIn(childrens[i])
            end
        end
    end

    fadeInAllChildrens(target)

    if callback then
    local actions = {}
        actions[#actions+1] = cc.DelayTime:create(fadeTime+0.1)
        actions[#actions+1] = cc.CallFunc:create(callback)

        local sq = transition.sequence(actions)
        self:runAction(sq)
    end

end

-----------------------------------------------------------
-- fadeOutAllChildrens
-----------------------------------------------------------
function MachineVew:fadeOutAllChildrens(target, fadeTime)

    if not target then return end

    local function fadeOut(target)
        transition.fadeOut(target,{time = fadeTime})
    end

    local function fadeOutAllChildrens(target)
        fadeOut(target)
        local childrens = target:getChildren()
        for i=1, table.getn(childrens) do
            if childrens[i]:getChildrenCount() > 0 then
                fadeOutAllChildrens(childrens[i])
            else
                fadeOut(childrens[i])
            end
        end
    end

    fadeOutAllChildrens(target)

end


--- for drop machine
-----------------------------------------------------------
-- setMultVisible
-----------------------------------------------------------
function MachineVew:setMultVisible(pos, lastPos)

    -- if true then return end

    if #DICT_MACHINE[tostring(self.machineId)].drop_multiple == 0 then
        return 
    end

    if pos >=1 and pos <=4 then
        local sp = self['effNode'..pos]

        if pos == 4 then
            self.multEffSprite:setVisible(true)
        else
            self.multEffSprite:setVisible(false)
        end

        if lastPos then
            self.multccb.animationManager:
            runAnimationsForSequenceNamed(lastPos..'disappear')
            
            self:runFunWithDelay(function()
                self.multccb.animationManager:
                runAnimationsForSequenceNamed(pos..'appear')
            end , 0.7)

            self:runFunWithDelay(function()

                local macName = DICT_MACHINE[self.machineId].machine_name
                local effpath = 'slots/'..string.gsub(macName, "_freespin", '')..'/effects/effect_x1lizi.ccbi'
                local eff = CCBuilderReaderLoad(effpath, {})
                local x, y = sp:getContentSize()
                eff:setPosition(sp:getPositionX(), sp:getPositionY() - 15)
                sp:getParent():addChild(eff)
                self:runFunWithDelay(function() eff:removeFromParent() end, 1) 
                
            end, 1.3 )
        else
            
            self.multccb.animationManager:
            runAnimationsForSequenceNamed(pos..'appear')

        end
    end

end

-----------------------------------------------------------
-- upMultSpriteForbase
-----------------------------------------------------------
function MachineVew:upMultSpriteForBase()

    local multiple = DICT_MACHINE[tostring(self.machineId)].drop_multiple

    if #multiple == 0 then
        return 
    end

    self:upMultSprite(multiple)

end

-----------------------------------------------------------
-- upMultSpriteForbase
-----------------------------------------------------------
function MachineVew:upMultSpriteForFree()

    local machineId = DICT_MACHINE[tostring(self.machineId)].f_machine_id
    local multiple = DICT_MACHINE[machineId].drop_multiple

    if #multiple == 0 then
        return 
    end

    self:upMultSprite(multiple)

end

-----------------------------------------------------------
-- upMultSprite
-----------------------------------------------------------
function MachineVew:upMultSprite( multiple )

    local spFramen, spFrames
    for n=1, 4 do
        local image_n = 'multiple'..multiple[n]..'_n.png'
        local image_s = 'multiple'..multiple[n]..'_s.png'
        if cc.SpriteFrameCache:getInstance():getSpriteFrame(image_n) 
            and cc.SpriteFrameCache:getInstance():getSpriteFrame(image_s) then
            spFramen = display.newSpriteFrame(image_n)
            spFrames = display.newSpriteFrame(image_s)
            self['mult_sp'..n..'_n']:setSpriteFrame(spFramen)
            self['mult_sp'..n..'_s']:setSpriteFrame(spFrames)
        end
    end

end

-----------------------------------------------------------
-- runFunWithDelay
-----------------------------------------------------------
function MachineVew:runFunWithDelay(func, dtime)
    
    local delay = cc.DelayTime:create(dtime)
    local callfunc = cc.CallFunc:create(func)
    local sequence = cc.Sequence:create(delay, callfunc)
    self:runAction(sequence)

end

-----------------------------------------------------------
-- onExit 
-----------------------------------------------------------
function MachineVew:onExit()
    self:unLoadSpriteFrame()
end


function MachineVew:loadSpriteFrame()
    if tonumber(self.machineId) ~= 1 and tonumber(self.machineId) ~= 101 then
        return
    end
    local resPath = "slots/slots_maya/slots_maya_images_machine.pvr.ccz"
    local plist = string.gsub(resPath,".pvr.ccz",".plist")
    display.addSpriteFrames(plist,resPath)

    local fullPath = cc.FileUtils:getInstance():fullPathForFilename(plist)
    local dict = cc.FileUtils:getInstance():getValueMapFromFile(fullPath)
    local spFrame,filterPng
    for k,v in pairs(dict.frames) do
        filterPng = string.find(k,"_n.png") or string.find(k,"_s.png")
        if filterPng then
            spFrame = display.newSpriteFrame(k)
            spFrame:retain()
        end
    end
end

function MachineVew:unLoadSpriteFrame()
    if tonumber(self.machineId) ~= 1 and tonumber(self.machineId) ~= 101 then
        return
    end
    local resPath = "slots/slots_maya/slots_maya_images_machine.pvr.ccz"
    local plist = string.gsub(resPath,".pvr.ccz",".plist")

    local fullPath = cc.FileUtils:getInstance():fullPathForFilename(plist)
    local dict = cc.FileUtils:getInstance():getValueMapFromFile(fullPath)
    local spFrame,filterPng
    for k,v in pairs(dict.frames) do
        filterPng = string.find(k,"_n.png") or string.find(k,"_s.png")
        if filterPng then
            spFrame = display.newSpriteFrame(k)
            spFrame:release()
        end
    end
end


return MachineVew
