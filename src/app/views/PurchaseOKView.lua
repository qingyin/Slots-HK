--声明 PurchaseOKView 类
local PurchaseOKView = class("PurchaseOKView", function()
    return ViewExtend.extend(CCLayer:create())
end)

local callback = nil

function PurchaseOKView:ctor(args)

    self.viewNode  = CCBuilderReaderLoad(GAME_CCBI.purchaseOkView,self)
    self:addChild(self.viewNode)

    self:setTouchEnabled(true)

    self:addTouchEventListener(function(event, x, y)
        return self:onTouch(event, x, y)
    end,false, GAME_TOUCH_OPCITY.POPVIEW, true)

    self.args = args

    callback = args.call
    
    local vipName = DICT_VIP[tostring(User.getProperty(User.KEY_VIPLEVEL))].alias
    self.vipLevel:setString(vipName)
    self.vipCoin:setString(tostring(args.value))
end

function PurchaseOKView:onOK()

    if self.args.type == ITEM_TYPE.NORMAL_MULITIPLE then

        local coins = User.getProperty(User.KEY_TOTALCOINS)
        User.setProperty(User.KEY_TOTALCOINS, coins + self.args.value)

    elseif self.args.type == ITEM_TYPE.GEMS_MULITIPLE then

        local gems = User.getProperty(User.KEY_TOTALGEMS)
        User.setProperty(User.KEY_TOTALGEMS, gems + self.args.value)

    end

    User.save()
    
    -- self:removeView(
    --     function()
    --         self.args.call()
    --     end
    -- )

    -- local callback = self.args.call()
    AnimationModel.ExitScale(self.viewNode, 0.3,function()
        -- self:removeView()
        -- self.removeSelf()
        self:removeFromParent()
        -- self.args.call()
        callback()
    end)

end

function PurchaseOKView:onEnter()
    self:registBtnEvent(self.okBtn,        self.onOK)
end

function PurchaseOKView:onExit()
    self:removeTouchEventListener()
end

function PurchaseOKView:onTouch(event, x, y)
    
    if event == "began" then
        self:onPress(event, x, y)
    elseif event == "moved" then
    elseif event == "ended" then
        self:onRelase(event, x, y)
    else -- cancelled
    end

    return true
end


return PurchaseOKView