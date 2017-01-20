local ChatView = class("ChatView", function()
    return core.displayEX.newSwallowEnabledNode()
end)

function ChatView:ctor(msg)
    self.viewNode  = CCBuilderReaderLoad("view/ChatView.ccbi", self)
    self:addChild(self.viewNode)

    self:initInputText()

end

function ChatView:initInputText()
    -- body
    local editboxSign = cc.ui.UIInput.new({
        image = "EditBoxBg.png",
        size = cc.size(650, 60),
        x = display.cx,
        y = display.cy,
        listener = function(event, editbox)
            if event == "began" then
                printf("editBox1 event began : text = %s", editbox:getText())
            elseif event == "ended" then
                printf("editBox1 event ended : %s", editbox:getText())
            elseif event == "return" then
                printf("editBox1 event return : %s", editbox:getText())

                net.ChatCS:chatMessage(editbox:getText())

                --self:setVisible(false)
                self:performWithDelay(function()
                    scn.ScnMgr.removeView(self)
                end,0.5)

            elseif event == "changed" then
                printf("editBox1 event changed : %s", editbox:getText())
            else
                printf("EditBox event %s", tostring(event))
            end
        end
    })

    editboxSign:setReturnType(cc.KEYBOARD_RETURNTYPE_SEND)
    self:addChild(editboxSign)
    editboxSign:setPosition(display.cx, 100)
    editboxSign:setText("")
end

return ChatView
