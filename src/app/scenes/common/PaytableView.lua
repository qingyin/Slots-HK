
local PaytableView = class("PaytableView", function()
    return display.newNode()
end)

local PaytableView = PaytableView


function PaytableView:ctor(args)
    self.pageNum = args.page
    local ccbifile = args.ccbi
    self:addChild(display.newColorLayer(cc.c4b(0, 0, 0, 200)))
    self.viewNode  = CCBuilderReaderLoad(ccbifile, self)
    self:addChild(self.viewNode)

    AnimationUtil.setContentSizeAndScale(self.viewNode)

    if args.page > 1 then
        self.tabidx = 1
        self:onShowPage(self.tabidx)
    end

    self:setTouchEnabled(true)
    self:setNodeEventEnabled(true)
    self:setTouchSwallowEnabled(true)
    self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        if event.name == "began" then
            return true
        end
    end)
end

function PaytableView:onShowPage(idx)
    for i=1,self.pageNum do
        if idx == i then
            self["page"..tostring(i)]:setVisible(true)
        else
            self["page"..tostring(i)]:setVisible(false)
        end
    end
end

function PaytableView:onRemove()
    --AnimationUtil.ExitScale(self.viewNode, 0.3,
        --function()
            self:removeFromParent(true)
        --end
    --)
end

function PaytableView:onNextPage()

    self.tabidx = self.tabidx + 1
    if self.tabidx > self.pageNum then self.tabidx = 1 end

    self:onShowPage(self.tabidx)
end

function PaytableView:onPrePage()

    self.tabidx = self.tabidx - 1
    if self.tabidx < 1 then self.tabidx = self.pageNum end

    self:onShowPage(self.tabidx)
end

function PaytableView:onEnter()
    if self.nextBtn ~= nil then
        core.displayEX.newSmallButton(self.nextBtn)
        :onButtonClicked(function()
            self:onNextPage()
        end)
    end

    if self.prevBtn ~= nil then
        core.displayEX.newSmallButton(self.prevBtn)
        :onButtonClicked(function()
            self:onPrePage()
        end)
    end

    if self.exitBtn ~= nil then
        core.displayEX.newSmallButton(self.exitBtn)
        :onButtonClicked(function()
            self:onRemove()
        end)
    end

    --AnimationUtil.EnterScale(self.viewNode, 0.3)
end

function PaytableView:onExit()
    self:removeAllNodeEventListeners()
end

return PaytableView
