local View = class("EditPlayerView", function()
    return core.displayEX.newSwallowEnabledNode()
end)

function View:ctor(baseInfo,exInfo)
    self.viewNode  = CCBReaderLoad("lobby/social/edit_player.ccbi", self)
    self:addChild(self.viewNode)
    self:initInputText()

    if baseInfo ~= nil then

        self.headView = headViewClass.new({player=baseInfo,scale=1.5})
        self.headView:replaceHead(self.player_head_sp)

        self.name_input:setText(baseInfo.name)
    end

    if exInfo ~= nil then
        self.age_input:setText(exInfo.age)
        self.message_input:setText(exInfo.signature)
    end

    self:registerUIEvent()
end


function View:registerUIEvent()
    core.displayEX.newButton(self.btn_close)
    self.btn_close.clickedCall = function()
        scn.ScnMgr.removeView(self)
    end

    core.displayEX.newButton(self.head_portrait_btn)
    self.head_portrait_btn.clickedCall =function()
        scn.ScnMgr.addView("social.EditHeadView")
        self:setVisible(false)
    end

    core.displayEX.newButton(self.ok_btn)
    self.ok_btn.clickedCall = function()
        self:requestModify()
    end
    EventMgr:addEventListener(EventMgr.Change_Player_Head_Event, handler(self, self.changePlayerHead))
end

function View:requestModify()
    local nameStr = self.name_input:getText()
    local ageStr = self.age_input:getText()
    local messageStr = self.message_input:getText()

    local model = app:getObject("UserModel")
    local cls = model.class
    local properties = model:getProperties({cls.extinfo})

    local ei = properties[cls.extinfo]
    ei[cls.ei.signature]   = messageStr
    ei[cls.ei.age]   = ageStr
    local properties = {}
    properties[cls.extinfo] = ei
    model:setProperties(properties)
    model:serializeModel()
    model:setName(nameStr)
    local pid = model:getPid()

    net.UserCS:modifyPlayerInfo(pid,nameStr,ei,function(rdata)
        print(" liuyi return: ",rdata)
        EventMgr:dispatchEvent({name=EventMgr.Change_MyInfo_Event})
        scn.ScnMgr.removeView(self)
    end)
end

function View:changePlayerHead(event)
    if self.headView then self.headView:updateHeadImage(event.pictureId) end
    self:setVisible(true)
end

function View:initInputText()

    local input = cc.ui.UIInput.new({
        image = "EditBoxBg.png",
        size = cc.size(260, 46),
        fontSize = 12,
    })
    input:setReturnType(cc.KEYBOARD_RETURNTYPE_SEND)
    local parent = self.message_bg:getParent()
    parent:addChild(input)

    local x, y = self.message_bg:getPosition()
    input:setPosition(x, y)
    input:setText("My name is secret !!!")
    self.message_input = input

    input = cc.ui.UIInput.new({
        image = "dating_shuzhi_kuang.png",
        size = cc.size(138, 30),
        fontSize = 12,
    })
    input:setReturnType(cc.KEYBOARD_RETURNTYPE_SEND)
    parent = self.name_bg:getParent()
    parent:addChild(input)

    x, y = self.name_bg:getPosition()
    input:setPosition(x, y)
    input:setText("hello")
    self.name_input = input

    input = cc.ui.UIInput.new({
        image = "dating_shuzhi_kuang.png",
        size = cc.size(138, 30),
        fontSize = 12,
    })
    input:setReturnType(cc.KEYBOARD_RETURNTYPE_SEND)
    parent = self.age_bg:getParent()
    parent:addChild(input)

    x, y = self.age_bg:getPosition()
    input:setPosition(x, y)
    input:setText(18)
    self.age_input = input
end


function View:onExit()
    EventMgr:removeEventListenersByEvent(EventMgr.Change_Player_Head_Event)
    self = {}
end



return View
