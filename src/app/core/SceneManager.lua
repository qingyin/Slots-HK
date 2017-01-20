
local SceneManager = class("SceneManager")

local sm = SceneManager

sm.showPools = {}
sm.showingView = nil


--------------------------------------
-- replaceScene
--------------------------------------
function sm.replaceScene(sceneName, args, showloading)
    --sm.showPools[#sm.showPools + 1] = {name=sceneName, type="scene", value= args }

    if showloading ~= nil and showloading == true then
        sm.showPools[#sm.showPools + 1] = {name="lobby.LoadingPage", type="scene",value= {sceneName,args}}
    else
        sm.showPools[#sm.showPools + 1] = {name=sceneName, type="scene", value= args }
    end
end

--------------------------------------
-- addView
--------------------------------------
function sm.addView( className, ... )
    local view = nil
    local scn = display.getRunningScene()
    if scn ~= nil then
        view = app:createSView(className, ... )
        view.pop = false
        scn:addChild( view )
    end
    return view
end

--------------------------------------
-- addView
--------------------------------------
function sm.removeView( view )
    if view.pop == nil then
        sm.shownext(view.nextshow)
    end
    view:removeSelf()
end

--------------------------------------
-- PopView
--------------------------------------
function sm.popView( className, args )
    
    if sm.showingView ~= nil then
        local nextview = sm.showingView.nextshow
        local newshow = {name=className, type="view", value= args }
        newshow.nextshow = nextview

        local tempview = newshow
        local tempshows = {}
        
        while tempview ~= nil do
            tempshows[#tempshows + 1] = tempview
            tempview = tempview.nextshow
        end

        local sortFunc = function(a, b)
            return tonumber(sm.getPriority(a)) > tonumber(sm.getPriority(b))
        end

        table.sort(tempshows, sortFunc)
        
        for i=2,#tempshows do
            local show = tempshows[i-1]
            local nextshow = tempshows[i]
            nextshow.nextshow = nil
            show.nextshow = nextshow
        end
        
        local showingnext = tempshows[1]

        sm.showingView.obj.nextshow = showingnext
        sm.showingView.nextshow = showingnext

    else
        sm.showPools[#sm.showPools + 1] = {name=className, type="view", value= args }
    end
end

function sm.shownext(nextshow)

    --print("sm.shownext", nextshow)
    sm.showingView = nil

    if nextshow ~= nil then
        if nextshow.type == "view" then
            print("View: ",nextshow.name)
            local view = app:createSView(nextshow.name, nextshow.value )
            view.nextshow = nextshow.nextshow

            if nextshow.value ~= nil and nextshow.value.event ~= nil then
                local event = nextshow.value.event
                view:addEventListener(event.name,    event.func,    event.target)
            end

            local scn = display.getRunningScene()
            if scn ~= nil then
                scn:addChild(view)
                nextshow.obj = view
                sm.showingView = nextshow
            end

        elseif nextshow.type == "scene" then
            print("Scene: ",nextshow.name)
            sm.preEnter()
            app:enterScene(nextshow.name, nextshow.value)
            sm.postEnter()
        end
    end
end

function sm.preEnter()
    app:getObject("ReportModel"):reportData()
    display.removeUnusedSpriteFrames()
    collectgarbage("collect")
end

function sm.postEnter()
    -- if core.Waiting.hasshow == true then
    --     if device.platform == "ios" then
    --         core.Waiting.indicator = sm.addView('CoverView')
    --         print("----------------!!!")
    --     end
    -- end
    core.Waiting.hide()
end

function sm.show()

    if #sm.showPools < 1 then return end

    local sortFunc = function(a, b)
        return tonumber(sm.getPriority(a)) > tonumber(sm.getPriority(b))
    end

    table.sort(sm.showPools, sortFunc)

    for i=2,#sm.showPools do
        local show = sm.showPools[i-1]
        local nextshow = sm.showPools[i]
        show.nextshow = nextshow
    end
    
    local showview = sm.showPools[1]
    sm.showPools = nil 
    sm.showPools = {}

    sm.shownext(showview)

end

function sm.getPriority(show)
    
    local priority = 0

    if show.type == "scene" then
        priority = -100
    else
        priority = 0
    end
    
    return priority

end

return SceneManager
