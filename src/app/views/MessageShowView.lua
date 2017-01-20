
local MessageShowView = class("MessageShowView", function()
    return core.displayEX.newSwallowEnabledNode()
end)

function MessageShowView:ctor(val)
    self:addChild(display.newColorLayer(cc.c4b(0, 0, 0, 200)))
    self.viewNode  = CCBuilderReaderLoad(RES_CCBI.message_tb, self)
    self:addChild(self.viewNode)

    -- local size = self.bgSprite:getContentSize()
    -- local coref = (0.85*display.height)/size.height
    -- self.viewNode:setScale(coref)
    AnimationUtil.setContentSizeAndScale(self.viewNode)

    self.nameLabel:setString(val.message.title)
    self.content:setString(val.message.content)

    self.callback = val.callback

    if val.message.type == 1 then
        self.btn_ok:setVisible(true)
        self.btn_collect:setVisible(false)

        core.displayEX.newButton(self.btn_ok) 
        :onButtonClicked(function(event)
            self.callback()
            scn.ScnMgr.removeView(self)
        end)
    elseif val.message.type == 3 then
        self.btn_ok:setVisible(false)
        self.btn_collect:setVisible(true)

        core.displayEX.newButton(self.btn_collect) 
        :onButtonClicked(function(event)
            self.callback()
            scn.ScnMgr.removeView(self)
        end)
    end
    
    --self:registerEvent()

end

function MessageShowView:registerEvent()
    -- on close
    core.displayEX.newButton(self.btn_ok) 
        :onButtonClicked(function(event)
            self.callback()
            scn.ScnMgr.removeView(self)
        end)

   
end

return MessageShowView
