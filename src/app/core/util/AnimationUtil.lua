
AnimationUtil = AnimationUtil or {}
AnimationUtil.EVENT_NULL   = "NULL"

function AnimationUtil.flip(target_)
    local target = target_
    local scale = target:getScale()
    local zoom = function(sx,sy,onComplete)
        transition.scaleTo(target, {time = 0.25, scaleX = sx, scaleY = sy, onComplete = onComplete})
    end
    zoom(-0.5,scale,function()
        zoom(-scale,scale,function()
            zoom(0.5,scale,function()
                zoom(scale,scale)
            end)
        end)
    end)
end

function AnimationUtil.MoveTo(image, num, start, target, onCallBack )
            
    --audio.playSound(GAME_SFX.coinsFalling)

    local scn = display.getRunningScene()

    local function zoom1(offset, time, onComplete)
        local x, y = target:getPosition()
        local size = target:getContentSize()
        transition.moveTo(target, {y = y - offset, time = time,onComplete = onComplete,})
    end

    local function zoom2(offset, time, onComplete)
        local x, y = target:getPosition()
        local size = target:getContentSize()
        transition.moveTo(target, {y = y + offset, time = time / 2,onComplete = onComplete,})
    end
    
    local parentStart = start:getParent()
    local parentTarget = target:getParent()
    
    local sPts = parentStart:convertToWorldSpace(cc.p(start:getPosition()))
    local ePts = parentTarget:convertToWorldSpace(cc.p(target:getPosition()))

    local startX = sPts.x
    local startY = sPts.y
    
    local endX = ePts.x
    local endY = ePts.y
    
    for index = 1, num do
        local sp = display.newSprite(image, x, y)

        scn:addChild(sp, 1000)

        sp.startX = startX + (40-math.random(80))
        sp.startY = startY + (40-math.random(80))
        
        sp.endX = endX + (10-math.random(20))
        sp.endY = endY + (10-math.random(20))

        sp.delayTime = (30 - math.random(30)) / 100

        sp:setPosition(sp.startX, sp.startY)

        local scale = 0.1 + sp.delayTime * 2
        sp:setScale(scale)
        
        local endscale = 1

        local array = {}
        local delay = cc.DelayTime:create(sp.delayTime)

        local bezier = {
            cc.p(1000, 200),
            cc.p(800, 700),
            cc.p(sp.endX, sp.endY)
        }

        bezier.controlPoint_1 = cc.p(1000, 200)
        bezier.controlPoint_2 = cc.p(800, 700)
        bezier.endPosition = cc.p(sp.endX, sp.endY)

        local bezierto = cc.BezierTo:create(1.0, bezier)

        sp:runAction(cc.Sequence:create(delay,bezierto))

        transition.scaleTo(sp, {time = 0.2, scale = endscale, delay=sp.delayTime, easing = "BACKIN"})

        transition.rotateTo(sp, {time = 1.0, rotate = -600, delay=sp.delayTime, onComplete = function()

            sp:removeFromParent(true)
            if num == index then
                zoom1(2, 0.08, function()
                    zoom2(2, 0.09, function()
                        zoom1(1, 0.10, function()
                            zoom2(1, 0.11, function()
                                if onCallBack ~= nil then
                                    onCallBack()
                                end
                            end)
                        end)
                    end)
                end)
            end

        end})
    end

end

function AnimationUtil.flyTo(image, num, start, target)

    local scn = display.getRunningScene()

    local function zoom1(offset, time, onComplete)
        local x, y = target:getPosition()
        local size = target:getContentSize()
        transition.moveTo(target, {y = y - offset, time = time,onComplete = onComplete,})
    end

    local function zoom2(offset, time, onComplete)
        local x, y = target:getPosition()
        local size = target:getContentSize()
        transition.moveTo(target, {y = y + offset, time = time / 2,onComplete = onComplete,})
    end

    local function zoom3(offset, time)
        local x, y = target:getPosition()
        local size = target:getContentSize()
        transition.moveTo(target, {y = y + offset, time = time / 2})
    end
    
    local parentStart = start:getParent()
    local parentTarget = target:getParent()
    
    local sPts = parentStart:convertToWorldSpace(cc.p(start:getPosition()))
    local ePts = parentTarget:convertToWorldSpace(cc.p(target:getPosition()))

    local startX = sPts.x
    local startY = sPts.y
    
    local endX = ePts.x
    local endY = ePts.y
    
    for index = 1, num do
        local sp = display.newSprite(image, x, y)

        scn:addChild(sp, 1000)

        sp.startX = startX + (40-math.random(80))
        sp.startY = startY + (40-math.random(80))
        
        sp.endX = endX + (10-math.random(20))
        sp.endY = endY + (10-math.random(20))

        sp.delayTime = (30 - math.random(30)) / 100

        sp:setPosition(sp.startX, sp.startY)

        local scale = 0.1 + sp.delayTime * 2
        sp:setScale(scale)
        
        local endscale = 1

        local array = {}
        local delay = cc.DelayTime:create(sp.delayTime)

        local bezier = {
            cc.p(1000, 200),
            cc.p(800, 700),
            cc.p(sp.endX, sp.endY)
        }

        bezier.controlPoint_1 = cc.p(1000, 200)
        bezier.controlPoint_2 = cc.p(800, 700)
        bezier.endPosition = cc.p(sp.endX, sp.endY)

        local bezierto = cc.BezierTo:create(1.0, bezier)

        sp:runAction(cc.Sequence:create(delay,bezierto))

        transition.scaleTo(sp, {time = 0.2, scale = endscale, delay=sp.delayTime, easing = "BACKIN"})

        transition.rotateTo(sp, {time = 1.0, rotate = -600, delay=sp.delayTime, onComplete = function()

            sp:removeFromParent(true)
            if num == index then
                zoom1(2, 0.08, function()
                    zoom2(2, 0.09, function()
                        zoom1(1, 0.10, function()
                            zoom3(1, 0.11)
                        end)
                    end)
                end)
            end

        end})
    end

end

function AnimationUtil.MoveHeartTo(stars, target, onCallBack )
            
    local scn = display.getRunningScene()

    local parentTarget = target:getParent()
    local ePts = parentTarget:convertToWorldSpace(cc.p(target:getPosition()))

    local endX = ePts.x
    local endY = ePts.y
    
    local num = #stars
    
    for index = 1, num do
        
        local sp = stars[index]

        local parentStart = sp:getParent()
        local sPts = parentStart:convertToWorldSpace(cc.p(sp:getPosition()))
        
        sp:removeFromParent(false)

        scn:addChild(sp, 1000)

        sp:setPosition(sPts.x, sPts.y)

        sp.endX = endX
        sp.endY = endY

        sp.delayTime = (30 - math.random(30)) / 100

        local scale = 1.0
        sp:setScale(scale)
        
        local endscale = 1

        local delay = cc.DelayTime:create(sp.delayTime)

        local bezier = {
            cc.p(900, 300),
            cc.p(1000, 200),
            cc.p(sp.endX, sp.endY),
        }
        local bezierto = cc.BezierTo:create(1.0, bezier)

        sp:runAction(cc.Sequence:create(delay,bezierto))

        transition.scaleTo(sp, {time = 1.0, scale = endscale, delay=sp.delayTime, easing = "BACKIN",onComplete = function()

            sp:removeFromParent(true)

            if num == index then
                onCallBack()
            end

        end})
        
    end

end

function AnimationUtil.MoveStarsTo(stars, target, onCallBack )
   -- audio.playSound(GAME_SFX.coinsFalling)

    local scn = display.getRunningScene()

    local function zoom1(offset, time, onComplete)
        local x, y = target:getPosition()
        local size = target:getContentSize()
        transition.moveTo(target, {y = y - offset, time = time,onComplete = onComplete,})
    end

    local function zoom2(offset, time, onComplete)
        local x, y = target:getPosition()
        local size = target:getContentSize()
        transition.moveTo(target, {y = y + offset, time = time / 2,onComplete = onComplete,})
    end
    
    local parentTarget = target:getParent()
    local ePts = parentTarget:convertToWorldSpace(cc.p(target:getPosition()))

    local endX = ePts.x
    local endY = ePts.y
    
    local num = #stars
    
    for index = 1, num do
        
        local sp = stars[index]

        local parentStart = sp:getParent()
        local sPts = parentStart:convertToWorldSpace(cc.p(sp:getPosition()))
        
        sp:removeFromParent(false)

        scn:addChild(sp, 1000)

        sp:setPosition(sPts.x, sPts.y)

        sp.endX = endX
        sp.endY = endY

        sp.delayTime = (30 - math.random(30)) / 100

        local scale = 1.0
        sp:setScale(scale)
        
        local endscale = 1

        local delay = cc.DelayTime:create(sp.delayTime)

        local bezier = {
            cc.p(100, 200),
            cc.p(150, 100),
            cc.p(sp.endX, sp.endY)
        }

        local bezierto = cc.BezierTo:create(1.0, bezier)
        sp:runAction(cc.Sequence:create(delay,bezierto))

        transition.scaleTo(sp, {time = 1.0, scale = endscale, delay=sp.delayTime, easing = "BACKIN",onComplete = function()

            sp:removeFromParent(true)

            if num == index then
                zoom1(2, 0.08, function()
                    zoom2(2, 0.09, function()
                        zoom1(1, 0.10, function()
                            zoom2(1, 0.11, function()
                                if onCallBack ~= nil then
                                    onCallBack()
                                end
                            end)
                        end)
                    end)
                end)
            end

        end})
        
        transition.rotateTo(sp, {time = 1.0, rotate = -800, delay=sp.delayTime})
    end
end

function AnimationUtil.MoveCoinsTo(image, num, start, target, onCallBack )
            
    --audio.playSound(GAME_SFX.coinsFalling)

    local scn = display.getRunningScene()

    local function zoom1(offset, time, onComplete)
        local x, y = target:getPosition()
        local size = target:getContentSize()
        transition.moveTo(target, {y = y - offset, time = time,onComplete = onComplete,})
    end

    local function zoom2(offset, time, onComplete)
        local x, y = target:getPosition()
        local size = target:getContentSize()
        transition.moveTo(target, {y = y + offset, time = time / 2,onComplete = onComplete,})
    end
    
    local parentStart = start:getParent()
    local parentTarget = target:getParent()
    
    local sPts = parentStart:convertToWorldSpace(cc.p(start:getPosition()))
    local ePts = parentTarget:convertToWorldSpace(cc.p(target:getPosition()))

    local startX = sPts.x
    local startY = sPts.y
    
    local endX = ePts.x
    local endY = ePts.y
    
    local tempTB = {}
    
    for index = 1, num do
        local sp = display.newSprite(image)
        
        scn:addChild(sp, 1000)

        sp.startX = startX + (70-math.random(140))
        sp.startY = startY + (70-math.random(140))
        
        sp.endX = endX + (10-math.random(20))
        sp.endY = endY + (10-math.random(20))

        sp.delayTime = (30 - math.random(30)) / 100

        sp:setPosition(sp.startX, sp.startY)

        local scale = 1.0
        sp:setScale(scale)
        
        local endscale = 0.1 + sp.delayTime * 2

        local delay = cc.DelayTime:create(sp.delayTime)

        local bezier = {
            cc.p(1000, 200),
            cc.p(800, 700),
            cc.p(sp.endX, sp.endY),
        }

        local bezierto = cc.BezierTo:create(1.0, bezier)

        sp:runAction(cc.Sequence:create(delay,bezierto))

        transition.scaleTo(sp, {time = 1.0, scale = 1, delay=sp.delayTime, easing = "BACKIN",onComplete = function()

            sp:removeFromParent(true)

            if num == index then
                zoom1(2, 0.08, function()
                    zoom2(2, 0.09, function()
                        zoom1(1, 0.10, function()
                            zoom2(1, 0.11, function()
                                if onCallBack ~= nil then
                                    onCallBack()
                                end
                            end)
                        end)
                    end)
                end)
            end

        end})

        local seq = cc.Sequence:create(
            cc.DelayTime:create(sp.delayTime),
            cc.ScaleTo:create(0.15, 0, 1),
            cc.ScaleTo:create(0.15, -1, 1),
            cc.ScaleTo:create(0.15, 0, 1),
            cc.ScaleTo:create(0.15, 1, 1)
        )
        sp:runAction(cc.RepeatForever:create(seq))
    end

end

function AnimationUtil.creatCoinPack(start, scale, distX, distY)

    local scaleSP = scale or 1

    local scn = display.getRunningScene()

    local parentStart = start:getParent()
    local sPts = parentStart:convertToWorldSpace(cc.p(start:getPosition()))

    if distX then sPts.x = sPts.x + distX end
    if distY then sPts.y = sPts.y + distY end

    local obj = {
        coins1={},
        coins2={},
        coins3={}
    }

    local dist1 = 13 * scaleSP
    local dist2 = 120 * scaleSP
    local dist3 = dist2/2
    local dist4 = 40 * scaleSP

    for i=1,6 do
        local coinSP = display.newSprite("mrdl_jinbi_pingmian.png")
        coinSP:setPosition(sPts.x, sPts.y + (i-1)*dist1)
        scn:addChild(coinSP)

        coinSP:setScale(scaleSP)

        obj.coins1[6 - i + 1] = coinSP

        coinSP:setOpacity(0)
        transition.fadeIn(coinSP, {time= 0.01, delay=0.2 + i*0.03})
    end

    for i=1,5 do
        local coinSP = display.newSprite("mrdl_jinbi_pingmian.png")
        coinSP:setPosition(sPts.x+dist2, sPts.y + (i-1)*dist1)
        scn:addChild(coinSP)
        
        coinSP:setScale(scaleSP)

        obj.coins2[5 - i + 1] = coinSP

        coinSP:setOpacity(0)
        transition.fadeIn(coinSP, {time= 0.01, delay=0.2 + i*0.03})
    end

    for i=1,3 do
        local coinSP = display.newSprite("mrdl_jinbi_pingmian.png")
        coinSP:setPosition(sPts.x+dist3, sPts.y + (i-1)*dist1 - dist4)
        scn:addChild(coinSP)
        
        coinSP:setScale(scaleSP)

        obj.coins3[3 - i + 1] = coinSP
        
        coinSP:setOpacity(0)
        transition.fadeIn(coinSP, {time= 0.01, delay=0.2 + i*0.03})
    end

    obj.num = 6+5+3
    obj.startX = sPts.x
    obj.startY = sPts.y

    return obj
end

function AnimationUtil.CollectCoins(obj, target, onCallBack )
            
    local scn = display.getRunningScene()

    local parentTarget = target:getParent()
    
    local ePts = parentTarget:convertToWorldSpace(cc.p(target:getPosition()))

    local endX = ePts.x
    local endY = ePts.y
    
    local loader={}
    local effectNode = CCBuilderReaderLoad("effect/coin_effect.ccbi", loader)
    effectNode:setPosition(endX, endY)
    effectNode:setVisible(false)
    scn:addChild(effectNode)

    local num = obj.num
    index = 1
    stepNum = 1

    while index < num+1 do

        for i=1,3 do

            local coinsnode = obj["coins"..tostring(i)]
            local idx = math.ceil(stepNum/3)
            local coinnode = coinsnode[idx]

            if coinnode then
            
                local delayTime = 0.2 + index*0.2
                
                coinnode.idx = index
                index = index + 1

                transition.scaleTo(coinnode, {time = 0.5, scale = 0.33, delay=delayTime ,onComplete = function()
                    
                    coinnode:removeFromParent(true)
                    audio.playSound(RES_AUDIO.coin_collect)
                    effectNode:setVisible(true)
                    effectNode:resetSystem()

                    if num == coinnode.idx then
                        if onCallBack ~= nil then
                            onCallBack()
                        end
                        effectNode:removeFromParent(true)
                    end

                    transition.moveBy(target, {y = 10, time = 0.02, onComplete = function()
                        transition.moveBy(target, {y = -10, time = 0.02, onComplete = function()

                        end})
                    end})

                end})

                local bezier = {
                        cc.p(obj.startX, obj.startY + 100),
                        cc.p(obj.startX, obj.startY + 200),
                        cc.p(endX, endY),
                    }

                local delay = cc.DelayTime:create(delayTime)
                local bezierto = cc.BezierTo:create(0.5, bezier)

                coinnode:runAction(cc.Sequence:create(delay,bezierto))

            end
            
            stepNum = stepNum + 1

        end

    end

end

function AnimationUtil.MoveExp(image, num, start, target, obj, onCallBack,controlPoint1,controlPoint2)

    local cp1 = cc.p(1000, 200)
    local cp2 = cc.p(800, 700)
    if controlPoint1 ~= nil then
        cp1 = controlPoint1
    end
    if controlPoint2 ~= nil then
        cp2 = controlPoint2
    end

    local percent = target:getPercentage()

    local scn = display.getRunningScene()

    local function zoom1(offset, time, onComplete)
        local x, y = target:getPosition()
        local size = target:getContentSize()
        local scaleX = target:getScaleX() * (size.width + offset) / size.width
        local scaleY = target:getScaleY() * (size.height - offset) / size.height
        transition.moveTo(target, {x = x - offset, time = time,onComplete = onComplete,})
    end

    local function zoom2(offset, time, onComplete)
        local x, y = target:getPosition()
        local size = target:getContentSize()
        transition.moveTo(target, {x = x + offset, time = time / 2,onComplete = onComplete,})
    end
    
    local parentStart = start:getParent()
    local parentTarget = target:getParent()
    
    local sPts = parentStart:convertToWorldSpace(cc.p(start:getPosition()))
    local ePts = parentTarget:convertToWorldSpace(cc.p(target:getPosition()))

    local startX = sPts.x
    local startY = sPts.y
    
    local endX = ePts.x
    local endY = ePts.y
    
    local psize = target:getContentSize()
    endX = endX + psize.width * percent/100 - psize.width/2

    for index = 1, num do
        local sp = display.newSprite(image, x, y)

        scn:addChild(sp, 1000)

        sp.startX = startX + (10-math.random(20))
        sp.startY = startY + (10-math.random(20))
        sp.endX = endX
        sp.endY = endY

        sp.delayTime = (30 - math.random(30)) / 100

        sp:setPosition(sp.startX, sp.startY)

        local scale = 0.75 - sp.delayTime * 2
        sp:setScale(scale)

        local delay = cc.DelayTime:create(sp.delayTime)

        local bezier = {
            cp1,
            cp2,
            cc.p(sp.endX, sp.endY)
        }

        local bezierto = cc.BezierTo:create(0.8, bezier)

        sp:runAction(cc.Sequence:create(delay,bezierto))

        transition.rotateTo(sp, {time = 0.8, rotate = -600, delay=sp.delayTime, onComplete = function()

                sp:removeFromParent(true)
                       
                -- if 1 == index and obj ~= nil then
                --     obj.expEffect:setPosition(endX,endY)
                --     obj:runAnimationByName(obj.expEffect, "show")
                -- end

                if num == index then
                    zoom1(2, 0.08, function()
                        zoom2(2, 0.09, function()
                            zoom1(1, 0.10, function()
                                zoom2(1, 0.11, function()
                                    if onCallBack ~= nil then
                                        onCallBack()
                                    end
                                end)
                            end)
                        end)
                    end)
                end

            end}
        )
    end

end

function AnimationUtil.EnterMoveTo(target, t, callback)
    local ex,ey = target:getPosition()
    target:setPosition(0-display.width/2, ey)
    transition.moveTo(target, {
        x = ex,
        y = ey,
        time = t,
        easing = "BACKOUT",
        onComplete = callback})
end

function AnimationUtil.ExitMoveTo(target, t, callback)
    transition.moveTo(target, {
        x = 3*display.width/2,
        time = t,
        easing = "BACKIN",
        onComplete = callback})
end


function AnimationUtil.EnterScale(target, t, callback)
    target:setScale(0)
    transition.scaleTo(target, {time = t, scale = 1, easing = "sineOut", onComplete=callback})
end
function AnimationUtil.ExitScale(target, t, callback)
    transition.scaleTo(target, {time = t, scale = 0, easing = "sineIn",onComplete=callback})
end

function AnimationUtil.FadeInView(target, t, callback)

    local function fadesSprite(target, t, o)
    
        local sprite = tolua.cast(target,"cc.Sprite")
        if sprite ~= nil then
            transition.fadeIn(sprite, {time= t})
        end
        local sprite9 = tolua.cast(target,"cc.Scale9Sprite")
        if sprite ~= nil then
            transition.fadeIn(sprite9, {time= t})
        end
       
        local children = target:getChildren()
        local len = table.getn(children)
        if len > 0 then
            for i = 1,len do
                fadesSprite(children[i], t, o)
            end
        end

    end
    
    fadesSprite(target, t)

    local complete = function()
        if callback ~= nil then callback() end
    end

    local delay = cc.DelayTime:create(t)
    local callfun = cc.CallFunc:create(complete)
    target:runAction(cc.Sequence:create(delay,callfun))

end

function AnimationUtil.FadeOutView(target, t, callback)

    local function fadesSprite(target, t, o)

        local sprite = tolua.cast(target,"cc.Sprite")

        if sprite ~= nil then
            transition.fadeOut(sprite, {time= t})
        end

        local children = target:getChildren()
        local len = table.getn(children)
        if len > 0 then
            for i = 1,len do
                fadesSprite(children[i], t, o)
            end
        end
    end
    
    fadesSprite(target, t)

    local complete = function()
        --print("fade out")
        if callback ~= nil then callback() end
    end

    local delay = cc.DelayTime:create(t)
    local callfun = cc.CallFunc:create(complete)
    target:runAction(cc.Sequence:create(delay,callfun))
end


function AnimationUtil.runAnimationByName(target, name)
    if target == nil then
        return false
    end
    if target.animationManager:getRunningSequenceName() == name then
        return false
    end
    target.animationManager:runAnimationsForSequenceNamed(name)
    if target.animationManager:getRootNode():getTag() == 10011 then
        return false
    end

    return true
end


--------------------------------------
-- animateNumber
--------------------------------------
local schedulerEntry = {}
function AnimationUtil.animateNumber(label, fromNum, toNum, time, key)
    toNum =  math.floor(toNum)
    local flag  = toNum - fromNum
    local dtNum = math.abs(flag)

    if flag == 0 then
        return 0
    end

    local unFun = function(val)
        if schedulerEntry[val] then
            scheduler.unscheduleGlobal( schedulerEntry[val] )
            schedulerEntry[val] = nil
        end
    end

    local tTime = 0
    local tick = function(dt)
        local dtNum_ = dtNum * dt / time
        tTime = tTime + dt

        if flag > 0 then
            fromNum = fromNum + dtNum_
            fromNum = fromNum >= toNum and toNum or fromNum

            if fromNum >= toNum then
                label:setString(toNum)
                return unFun(key)
            end
        else
            fromNum = fromNum - dtNum_
            fromNum = fromNum <= toNum and toNum or fromNum

            if fromNum <= toNum then
                label:setString(toNum)
                return unFun(key)
            end
        end

        if label == nil then
           return unFun(key)
        end
        if tTime > time then
            label:setString(toNum)
            return unFun(key)
        end
        label:setString(math.floor(fromNum))
    end

    if schedulerEntry[key] ~= nil then
        unFun(key)
    end
    schedulerEntry[key] = scheduler.scheduleGlobal(tick , 0)
end

function AnimationUtil.progressMoveTo(obj, from, to, count, time)

    local delat = 0.5
    if time then delat = time end

    obj:setPercentage(from)
    obj:stopAllActions()

    if count and count > 0 then
        
        obj:runAction(cca.progressFromTo(delat, from, 100))

        count = count - 1 

        local delayIdx = 1

        for i=1, count do
            
            local delayAction = cc.DelayTime:create(delat * delayIdx)
            delayIdx = delayIdx + 1

            local complete = function()
                obj:setPercentage(0)
            end

            local resetAction = cc.CallFunc:create(complete)

            local progressAction = cca.progressFromTo(delat, 0, 100)
        

            obj:runAction(cc.Sequence:create(delayAction, resetAction, progressAction))

        end
        
        local delayAction = cc.DelayTime:create(delat * delayIdx)

        local complete = function()
            obj:setPercentage(0)
        end
        local resetAction = cc.CallFunc:create(complete)
        local progressAction = cca.progressFromTo(delat, 0, to)

        obj:runAction(cc.Sequence:create(delayAction, resetAction, progressAction))


    else

        if ( to - from ) < 0.0001 then
            obj:setPercentage(to)
            return
        end

        obj:runAction(cc.ProgressFromTo:create(delat, from, to))
    end

end

function AnimationUtil.getTwoPercentage(pastprogress, pastlevel, nowlv, nowexp)

    local nextlv = nowlv + 1
    
    local nextelvxp = tonumber(getNeedExpByLevel(nextlv))

    local levelUpCnt = 0

    local modVal,nowprogress = math.modf(nowexp/nextelvxp)


    while modVal > 0 do

        levelUpCnt = levelUpCnt + 1

        nextlv = nextlv + 1
        nowexp = nowexp - nextelvxp
        nextelvxp = tonumber(getNeedExpByLevel(nextlv))
        modVal,nowprogress = math.modf(nowexp/nextelvxp)

    end
    
    local levelup = false

    if nowlv > pastlevel then levelup = true end

    nowprogress = nowprogress * 100

    return pastprogress, nowprogress, levelup, levelUpCnt
end

function AnimationUtil.reset()
   -- print("AnimationModel.reset", schnum)
    for k, v in pairs(schedulerEntry) do
        scheduler.unscheduleGlobal( v )
    end
    schedulerEntry = nil
    schedulerEntry = {}
end

function AnimationUtil.setContentSizeAndScale(node)
    --print("------setContentSizeAndScale--------")
    if not node then
        return
    end

    if display.width >= 1024 and display.height >= 768 then
        node:setScale(0.9)
    else
        node:setScale(0.75)
    end
end

