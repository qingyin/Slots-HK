local Waiting = {}

Waiting.logining = false

Waiting.hasshow = false
Waiting.indicator = nil

function Waiting.show()
    --Waiting.newShow()
    print("Waiting--.show")
    if device.platform == "ios" then
        Waiting.showIos()
    elseif device.platform == "android" then
        Waiting.showAndroid()
    end
end

function Waiting.hide()
    --Waiting.newHide()
    if Waiting.logining then
        return
    end
    print("Waiting--.hide")
    if device.platform == "ios" then
        Waiting.hideIos()
    elseif device.platform == "android" then
        Waiting.hideAndroid()
    end
end

function Waiting.showIos()
    if Waiting.hasshow == true then return end
    Waiting.hasshow = true

    device.showActivityIndicator()
    Waiting.indicator = scn.ScnMgr.addView("CoverView")
    
end

function Waiting.hideIos()
    if Waiting.hasshow == false then return end
    Waiting.hasshow = false
    device.hideActivityIndicator()
    if Waiting.indicator then
        Waiting.indicator:removeFromParent(true)
        Waiting.indicator = nil
    end
end

function Waiting.showAndroid()
    if Waiting.hasshow == true then return end
    Waiting.hasshow = true
    -- local s_storeKit=AndroidStoreKit:sharedStoreKit()
    -- s_storeKit:showProgressDialog()
    CCAccountManager:showIndicator()
end

function Waiting.hideAndroid()
    if Waiting.hasshow == false then return end
     Waiting.hasshow = false
     -- local s_storeKit=AndroidStoreKit:sharedStoreKit()
     -- s_storeKit:hideProgressDialog() sharedAccountManager():
     CCAccountManager:hideIndicator()
end

function Waiting.newShow()
    if  Waiting.layer == nil then
        Waiting.init()
    end
    if not Waiting.hasshow then
        local scn = display.getRunningScene()
        scn:addChild( Waiting.layer)
        Waiting.hasshow = true
    end
end

function Waiting.newHide()
    if  Waiting.layer ~= nil and Waiting.hasshow then
        Waiting.hasshow = false
        local scn = display.getRunningScene()
        scn:removeChild( Waiting.layer)
        Waiting.layer = nil
    end
end

function Waiting.init()
    local s = cc.Director:getInstance():getWinSize()
    local layer = display.newColorLayer(cc.c4b(0, 200,0, 100))
    layer:setContentSize(s)
    Waiting.layer = layer
    local sp = display.newSprite("loding_cyc.png",display.cx,display.cy)
    layer:addChild(sp)

    local repeatAction = cc.RepeatForever:create(cc.RotateBy:create(1.0, 360))
    sp:runAction(repeatAction)
end


return Waiting
