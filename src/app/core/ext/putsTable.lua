require("app.core.ext.initExt")


function m_ClassType(param)
    local ret = tolua.type (param)
    return ret
end

function m_tostring(obj, ...)
    if type(obj) == "table" then
        return table.tostring(obj)
    end

    if type(obj) == "userdata" then
        --tolua++ data
        --print(m_ClassType(obj))
        if(m_ClassType(obj) == "CCRect") then
            return string.format("origin={x=%f,y=%f},size={width=%f,height=%f}", obj.origin.x,obj.origin.y,obj.size.width,obj.size.height)
        end
        if(m_ClassType(obj) == "CCSize") then
            return string.format("{width=%f,height=%f}", obj.width,obj.height)
        end
        if(m_ClassType(obj) == "CCPoint") then
            return string.format("{x=%f,y=%f}", obj.x,obj.y)
        end
        
    end
    if ... then
        obj = string.format(tostring(obj), ...)
    else
        obj = tostring(obj)
    end

    return obj
end

function tracestack()
    print(debug.traceback())
end

function puts(obj, ...)
    oputs(obj, ...)
end

function oputs(obj, ...)
    --if(IS_DISTRIBUTION) then return end
    --tracestack()
    local str = m_tostring(obj, ...)
    print(str)
--[[
    local LOGFILE_PATH = (CCFileUtils:sharedFileUtils():getWritablePath()) .. "lua.log"

    local ts = os.date()
    local f = io.open(LOGFILE_PATH, "a+")
    if(f ~= nil) then
        f:write(ts..":"..str.."\n")
        f:close()
    end
    ]]--
end
