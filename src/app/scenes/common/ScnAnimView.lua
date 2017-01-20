
local ScnAnimView = class("ScnAnimView", function()
    return display.newNode()
end)

function ScnAnimView:ctor(args)

    self.machineScn = args.machineScn

    self.machineScnParent = self.machineScn:getParent()

    self.viewNode  = CCBuilderReaderLoad(args.animccbi, self)
    
    self:addChild(self.viewNode)

    self.machineScn:removeFromParent(false)

    self.machPosX, self.machPosY = self.machineScn:getPosition()

    local size = self.machineScn:getContentSize()
    -- self.machineScn:setPosition(-size.width/2, -size.height/2)


    -- self.machineNode:removeAllChildren()
    self.machineNode:addChild(self.machineScn)

    self.machineScnParent:addChild(self)

    self:setTouchEnabled(true)
    self:setNodeEventEnabled(true)
    self:setTouchSwallowEnabled(true)

    self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        if event.name == "began" then
            return true
        end
    end)

end

function ScnAnimView:playOnEnter()
    self.viewNode.animationManager:runAnimationsForSequenceNamed("enter")
end

function ScnAnimView:playOnExit()
    self.viewNode.animationManager:runAnimationsForSequenceNamed("exit")
end

function ScnAnimView:onEnterComplete()
    print("onEnterComplete")
    --self:reAttachTo()
end

function ScnAnimView:onExitComplete()
    print("onEnterComplete")
    --self:reAttachTo()
end

function ScnAnimView:reAttachTo()
    -- body
    self.machineScn:removeFromParent(false)
    self.machineScn:setPosition(self.machPosX, self.machPosY)
    self.machineScnParent:addChild(self.machineScn)
    self:removeFromParent(false)

end

function ScnAnimView:onEnter()
end

function ScnAnimView:onExit()
    print("ScnAnimView:onExit()")
end

return ScnAnimView