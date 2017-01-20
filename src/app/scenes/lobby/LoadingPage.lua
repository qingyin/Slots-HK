local LP = class("LoadingPage", function()
    return display.newScene("LoadingPage")
end)

function LP:ctor(name,value)

    local  node  = CCBuilderReaderLoad(RES_CCBI.loadingPage,self)
    self:addChild(node)

    local delaycall = function()
        scn.ScnMgr.showPools[#scn.ScnMgr.showPools + 1] = {name=name, type="scene", value= value}
    end
    self:performWithDelay(delaycall, 0.6)

    self:setNodeEventEnabled(true)

    -- local sp = display.newSprite("loding_cyc.png",display.cx + 200,display.height * 0.15)

    -- sp:setScale(0.5)
    -- self:addChild(sp)

    -- local repeatAction = cc.RepeatForever:create(cc.RotateBy:create(1.0, 360))
    -- sp:runAction(repeatAction)

end

function LP:onEnter()
end

function LP:onExit()
    self = {}
end

return LP

