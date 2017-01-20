
local displayEX = {}

function displayEX.spinButton(btn,sound)

    local soundSrc = RES_AUDIO.btn_default
    if sound then soundSrc=sound end

    displayEX.extendButton(btn, soundSrc)
    return btn
end

function displayEX.newButton(btn,sound)

    local soundSrc = RES_AUDIO.btn_click
    if sound then soundSrc=sound end

    displayEX.extendButton(btn, soundSrc)
    return btn
end

function displayEX.newSmallButton(btn, sound)
    local soundSrc = RES_AUDIO.btn_click
    if sound then soundSrc=sound end

    displayEX.newButton(btn, soundSrc) 
    
    function btn:checkTouchInSprite_(x, y)
        return true
    end

    return btn
    
end

function displayEX.formatLongTextNumber(val)

    if val > 10000000 then return val end
    local numTxt = tostring(val)

    local subnum1 = math.floor( val / 1000 ) 
    local subnum2 = math.floor( val / 1000000 ) 

    if math.floor( val / ( 1000000 * 10000000 ) ) > 1 then
        numTxt = tostring(subnum2).."M"
    elseif math.floor( val / ( 1000 * 10000000 ) ) > 1 then
        numTxt = tostring(subnum1).."K"
    end

    return numTxt
    
end

function displayEX.newUIPushButtonByCCBSprite(spriteObj)
    local parent = spriteObj:getParent()
    --local varname = spriteObj.varname
    local spCache = cc.SpriteFrameCache:getInstance()

    --local parentNode = spriteObj:getParent()
    local x,y = spriteObj:getPosition()

    local images = {}

    local normalimage = spriteObj.varname.."_n.png"
    local pressedimage = spriteObj.varname.."_s.png"
    local disabledimage = spriteObj.varname.."_d.png"

    if spCache:getSpriteFrame(normalimage) then
        images.normal="#"..normalimage
    end

    if spCache:getSpriteFrame(pressedimage) then
        images.pressed="#"..pressedimage
    end

    if spCache:getSpriteFrame(disabledimage) then
        images.disabled="#"..disabledimage
    end

    spriteObj:removeFromParent(true)

    return cc.ui.UIPushButton.new(images, {scale9 = false})
        :align(display.CENTER, x,y)
        :addTo(parent)
end

function displayEX.newSwallowEnabledNode()
    local node = display.newNode()
    node:setTouchEnabled(true)
    node:setTouchSwallowEnabled(true)
    cc(node):addComponent("components.behavior.EventProtocol"):exportMethods()
    node:addNodeEventListener(cc.NODE_EVENT, function(event)
        if event.name == "cleanup" then
            node:removeAllEventListeners()
        end
    end)
    return node
end

--[[用法
-- displayEX.addBubbleButton(self.btn_add,{
--     prepare=function() end,
--     listener = function() end
-- })
-- ]]
function displayEX.addBubbleButton(sprite,params)
    local listener = params.listener

    params.listener = function()
        audio.playSound("audio/TapButton.mp3")
        if params.prepare then
            params.prepare()
        end

        local function zoom1(offset, time, onComplete)
            local x, y = sprite:getPosition()
            local size = sprite:getContentSize()
            size.width = 200
            size.height = 200

            local scaleX = sprite:getScaleX() * (size.width + offset) / size.width
            local scaleY = sprite:getScaleY() * (size.height - offset) / size.height

            transition.moveTo(sprite, {y = y - offset, time = time})
            transition.scaleTo(sprite, {
                scaleX     = scaleX,
                scaleY     = scaleY,
                time       = time,
                onComplete = onComplete,
            })
        end

        local function zoom2(offset, time, onComplete)
            local x, y = sprite:getPosition()
            local size = sprite:getContentSize()
            size.width = 200
            size.height = 200

            transition.moveTo(sprite, {y = y + offset, time = time / 2})
            transition.scaleTo(sprite, {
                scaleX     = 1.0,
                scaleY     = 1.0,
                time       = time,
                onComplete = onComplete,
            })
        end

        sprite:setTouchEnabled(false)

        zoom1(20, 0.08, function()
            zoom2(20, 0.09, function()
                zoom1(10, 0.10, function()
                    zoom2(10, 0.11, function()
                        listener()
                        sprite:setTouchEnabled(true)
                    end)
                end)
            end)
        end)
    end
    sprite:setTouchEnabled(true)
    sprite:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        if event.name == "began" then
            return true
        end
        if event.name == "ended" then
            params.listener()
        end

    end)
end

function displayEX.extendButton(target, sound)

    function target:doTouch(event)
        local touchInTarget = self:checkTouchInSprite_(event.x, event.y)

        if event.name == "began" then
            self:setHighlighted(true)
            if self.pressedCall and touchInTarget then
                self.pressedCall(event)
            end
        elseif event.name == "ended" then
            self:setHighlighted(false)
            if self.clickedCall and touchInTarget and target:isEnabled() then
                if sound then audio.playSound(sound) end
                self.clickedCall(event)
            end
            if self.relasedCall and touchInTarget then
                self.relasedCall(event)
            end

        elseif event.name == "moved" then
            if not touchInTarget and self.relasedCall then
                self.relasedCall(event)
                self:setHighlighted(false)
            else
                self:setHighlighted(true)
            end
        end

        return true
    end

    function target:checkTouchInSprite_(x, y)
        return self:getCascadeBoundingBox():containsPoint(cc.p(x, y))

--        local tSize = self:getContentSize()
--        local tPos = self:getParent():convertToWorldSpace(cc.p(self:getPosition()))
--        local rect = cc.rect(tPos.x - tSize.width / 2, tPos.y - tSize.height / 2, tSize.width, tSize.height)
--        local ret  = cc.rectContainsPoint(rect, cc.p(x,y))

--        return ret
    end

    function target:setButtonEnabled(val)
        self:setEnabled(val)
        local func = tolua.getcfunction(target, "setTouchEnabled")
        func(self, val)
    end

    function target:onButtonPressed(callback)
        self.pressedCall = callback
        return self
    end

    function target:onButtonClicked(callback)
        self.clickedCall = callback
        return self
    end

    function target:onButtonReleased(callback)
        self.relasedCall = callback
        return self
    end

    function target:setButtonImages(images)

        local conf = {
            n = cc.CONTROL_STATE_NORMAL,
            s = cc.CONTROL_STATE_HIGH_LIGHTED,
            d = cc.CONTROL_STATE_DISABLED,
        }

        local sp, img
        for s, ccState in pairs(conf) do
            img = images[s]
            sp  = display.newSpriteFrame(img)
            self:setBackgroundSpriteFrameForState(sp, ccState)
        end
    end

    function target:setButtonImage(image, state)
        local frame = display.newSpriteFrame(image)
        self:setBackgroundSpriteFrameForState(frame, state)
    end

    local func = tolua.getcfunction(target, "setTouchEnabled")
    func(target, true)

    target:addNodeEventListener(cc.NODE_TOUCH_EVENT,handler(target,target.doTouch))

    target:addNodeEventListener(cc.NODE_EVENT, function(event)
        if event.name == "cleanup" then
            target:removeNodeEventListenersByEvent(cc.NODE_EVENT)
            target:removeNodeEventListenersByEvent(cc.NODE_TOUCH_EVENT)
            target.clickedCall = nil
            target.pressedCall = nil
            target.relasedCall = nil
        end
    end)
end


function displayEX.setButtonImages(btn, images)

    local conf = {
        n = cc.CONTROL_STATE_NORMAL,
        s = cc.CONTROL_STATE_HIGH_LIGHTED,
        d = cc.CONTROL_STATE_DISABLED,
    }

    local sp, img
    for s, ccState in pairs(conf) do
        img = images[s]
        sp  = display.newSpriteFrame(img)
        btn:setBackgroundSpriteFrameForState(sp, ccState)
    end
end

function displayEX.formatTimer(isecs)

    isecs = math.ceil(isecs)

    local function formatSTR(num)
        if num < 10 then
            num = '0'..num
        end
        return num
    end

    local hor = math.modf(isecs/(60 * 60))
    local min = math.modf((isecs - hor * 60 * 60)/60)
    local sec = isecs - hor * 60 * 60 - min * 60

    hor = formatSTR(hor)
    min = formatSTR(min)
    sec = formatSTR(sec)

    local timeStr = hor..':'..min..':'..sec

    return timeStr
end

displayEX.addSpriteEvent = function(sprite,callback)
    sprite:setTouchEnabled(true)
    sprite:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        if event.name == "began" then
            return true
        end
        if event.name == "ended" then
            callback()
        end
    end)
end


return displayEX