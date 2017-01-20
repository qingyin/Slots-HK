
-----------------------------------------------------------
-- BonusDialogView 
-----------------------------------------------------------
local BonusDialogView = class("BonusDialogView", function()
    return display.newNode()
end)

-----------------------------------------------------------
-- Construct 
-- args.onComplete
-----------------------------------------------------------
function BonusDialogView:ctor(args) 
    self:addChild(cc.LayerColor:create(cc.c4b(0, 0, 0, 200)))

    local ccb = "slots/BonusGoView.ccbi"

    self.onComplete = args.onComplete
    self.ccbNode = CCBuilderReaderLoad(ccb, self)
    self:addChild(self.ccbNode)
    
    self:init()

    self:setNodeEventEnabled(true)
    self:setTouchEnabled(true)
    self:setTouchSwallowEnabled(true)
    self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        if event.name == "began" then
            return true
        end
    end)

end

-----------------------------------------------------------
-- init 
-----------------------------------------------------------
function BonusDialogView:init()
    core.displayEX.newButton(self.okBtn)
        :onButtonClicked(function() 
            self.onComplete()
            self:removeFromParent() 
        end)

end

-----------------------------------------------------------
-- onExit 
-----------------------------------------------------------
function BonusDialogView:onExit()
    self:removeAllNodeEventListeners()
end

return BonusDialogView
