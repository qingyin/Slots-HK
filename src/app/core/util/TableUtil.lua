

table.reverse = function (tArray)

    if tArray == nil or #tArray == 0 then

        return nil

    end

    local tArrayReversed = {}

    local nArrCount = #tArray

    for i=1, nArrCount do

        tArrayReversed[i] = tArray[nArrCount-i+1]

    end

    return tArrayReversed

end

table.dump=function(iTable, iName)
    if nil==iTable then
        return false
    end

    iName = iName or ""

    local prefix = "   | "
    local dumpFlag = {}

    local function dump(iPrefix, iTheName, iTheTable)
        if "table"~=type(iTheTable) then
            return
        end

        print(iPrefix.."<"..type(iTheTable)..">", iTheName)
        for k, v in pairs(iTheTable) do
            if nil==v then
                print(prefix..iPrefix.."<nil>", k, "nil")
            elseif "table"==type(v) then
                if nil==dumpFlag[v] then
                    dumpFlag[v] = v
                    dump(prefix..iPrefix, k, v)
                end
            else
                print(prefix..iPrefix.."<"..type(v)..">", k, v)
            end
        end
    end

    dumpFlag[iTable] = iTable
    dump("", iName, iTable)
end

table.isEmpty=function(t)
    if(type(t) ~= "table") then
        return true
    end
    return _G.next( t ) == nil
end

--table转字符串，老方法
function sz_T2S(_t)
    local szRet = "{"
    function doT2S(_i, _v)
        if "number" == type(_i) then
            szRet = szRet .. "[" .. _i .. "] = "
            if "number" == type(_v) then
                szRet = szRet .. _v .. ","
            elseif "string" == type(_v) then
                szRet = szRet .. '"' .. _v .. '"' .. ","
            elseif "table" == type(_v) then
                szRet = szRet .. sz_T2S(_v) .. ","
            else
                szRet = szRet .. "nil,"
            end
        elseif "string" == type(_i) then
            szRet = szRet .. '["' .. _i .. '"] = '
            if "number" == type(_v) then
                szRet = szRet .. _v .. ","
            elseif "string" == type(_v) then
                szRet = szRet .. '"' .. _v .. '"' .. ","
            elseif "table" == type(_v) then
                szRet = szRet .. sz_T2S(_v) .. ","
            else
                szRet = szRet .. "nil,"
            end
        end
    end
    table.foreach(_t, doT2S)
    szRet = szRet .. "}"
    return szRet
end

--字符串转table 老方法 (反序列化,异常数据直接返回nil)
function t_S2T(_szText)
    --栈
    function stack_newStack()
        local first = 1
        local last = 0
        local stack = {}
        local m_public = {}
        function m_public.pushBack(_tempObj)
            last = last + 1
            stack[last] = _tempObj
        end
        function m_public.temp_getBack()
            if m_public.bool_isEmpty() then
                return nil
            else
                local val = stack[last]
                return val
            end
        end
        function m_public.popBack()
            stack[last] = nil
            last = last - 1
        end
        function m_public.bool_isEmpty()
            if first > last then
                first = 1
                last = 0
                return true
            else
                return false
            end
        end
        function m_public.clear()
            while false == m_public.bool_isEmpty() do
                stack.popFront()
            end
        end
        return m_public
    end
    function getVal(_szVal)
        local s, e = string.find(_szVal,'"',1,string.len(_szVal))
        if nil ~= s and nil ~= e then
            --return _szVal
            return string.sub(_szVal,2,string.len(_szVal)-1)
        else
            return tonumber(_szVal)
        end
    end

    local m_szText = _szText
    local charTemp = string.sub(m_szText,1,1)
    if "{" == charTemp then
        m_szText = string.sub(m_szText,2,string.len(m_szText))
    end
    function doS2T()
        local tRet = {}
        local tTemp = nil
        local stackOperator = stack_newStack()
        local stackItem = stack_newStack()
        local val = ""
        while true do
            local dLen = string.len(m_szText)
            if dLen <= 0 then
                break
            end

            charTemp = string.sub(m_szText,1,1)
            if "[" == charTemp or "=" == charTemp then
                stackOperator.pushBack(charTemp)
                m_szText = string.sub(m_szText,2,dLen)
            elseif '"' == charTemp then
                local s, e = string.find(m_szText, '"', 2, dLen)
                if nil ~= s and nil ~= e then
                    val = val .. string.sub(m_szText,1,s)
                    m_szText = string.sub(m_szText,s+1,dLen)
                else
                    return nil
                end
            elseif "]" == charTemp then
                if "[" == stackOperator.temp_getBack() then
                    stackOperator.popBack()
                    stackItem.pushBack(val)
                    val = ""
                    m_szText = string.sub(m_szText,2,dLen)
                else
                    return nil
                end
            elseif "," == charTemp then
                if "=" == stackOperator.temp_getBack() then
                    stackOperator.popBack()
                    local Item = stackItem.temp_getBack()
                    Item = getVal(Item)
                    stackItem.popBack()
                    if nil ~= tTemp then
                        tRet[Item] = tTemp
                        tTemp = nil
                    else
                        tRet[Item] = getVal(val)
                    end
                    val = ""
                    m_szText = string.sub(m_szText,2,dLen)
                else
                    return nil
                end
            elseif "{" == charTemp then
                m_szText = string.sub(m_szText,2,string.len(m_szText))
                local t = doS2T()
                if nil ~= t then
                    szText = sz_T2S(t)
                    tTemp = t
                    --val = val .. szText
                else
                    return nil
                end
            elseif "}" == charTemp then
                m_szText = string.sub(m_szText,2,string.len(m_szText))
                return tRet
            elseif " " ~= charTemp then
                val = val .. charTemp
                m_szText = string.sub(m_szText,2,dLen)
            else
                m_szText = string.sub(m_szText,2,dLen)
            end
        end
        return tRet
    end
    local t = doS2T()
    return t
end

--[[
table.RandShuffle=function(deck)
    -- 首先確認傳入的參數型態是 table
    assert(type(deck) == "table");

    -- 將 deck 的所有元素複製至暫用的 clone 中
    local clone = {};
    for k, v in pairs(deck) do
        clone[k] = v;
    end

    -- 取得元素集合的大小
    local range = table.maxn(deck);

    -- 巡訪 deck 結構
    for k, v in pairs(deck) do
        -- 藉由亂數機制，決定要取出的 clone 索引值
        local index = math.random(1, range);

        -- 在 clone 中移除該元素，塞回原來的 deck 中
        deck[k] = table.remove(clone, index);

        -- 將亂數取值的範圍減1
        range = range - 1;
    end
end
]]

table.RandShuffle=function(array)
    local function swap(array, index1, index2)
        array[index1], array[index2] = array[index2], array[index1]
    end
    local counter = #array
    while counter > 1 do
        math.random(counter)
        local index = math.random(counter)
        swap(array, index, counter)
        counter = counter - 1
    end
end

table.serialize=function(obj)
    local lua = ""
    local t = type(obj)
    if t == "number" then
        lua = lua .. obj
    elseif t == "boolean" then
        lua = lua .. tostring(obj)
    elseif t == "string" then
        lua = lua .. string.format("%q", obj)
    elseif t == "table" then
        lua = lua .. "{\n"
        for k, v in pairs(obj) do
            lua = lua .. "[" .. table.serialize(k) .. "]=" .. table.serialize(v) .. ",\n"
        end
        local metatable = getmetatable(obj)
        if metatable ~= nil and type(metatable.__index) == "table" then
            for k, v in pairs(metatable.__index) do
                lua = lua .. "[" .. table.serialize(k) .. "]=" .. table.serialize(v) .. ",\n"
            end
        end
        lua = lua .. "}"
    elseif t == "nil" then
        return nil
    else
        error("can not serialize a " .. t .. " type.")
    end
    return lua
end

table.unserialize=function(lua)
    local t = type(lua)
    if t == "nil" or lua == "" then
        return nil
    elseif t == "number" or t == "string" or t == "boolean" then
        lua = tostring(lua)
    else
        error("can not unserialize a " .. t .. " type.")
    end
    lua = "return " .. lua
    local func = loadstring(lua)
    if func == nil then
        return nil
    end
    return func()
end

--数组M选N
table.combine=function(a,num)
    local result={}
    local b={}

    for i=1,#a do
        if i <= num then
            b[i]=1
        else
            b[i]=0
        end
    end

    local point = 0
    local nextPoint = 0
    local count = 0
    local sum = 0
    local temp = 1

    local sb = {}
    while (true) do
        --判断是否全部移位完毕
        local blen=#b
        for i=blen,blen-num+1,-1 do
            if b[i] == 1 then
                sum = sum+ 1
            end
        end
        --print(sum)
        --根据移位生成数据
        for i=1,blen do
            if b[i] == 1 then
                point = i
                table.insert(sb,a[point])
                count=count+1
                if count == num then
                    break
                end
            end
        end

        -- print(serialize(sb))
        table.insert(result,sb)

        --当数组的最后num位全部为1 退出
        if sum == num then
            break
        end
        sum = 0

        --修改从左往右第一个10变成01
        for i = 1, blen-1 do
            if b[i]==1 and b[i+1]==0 then
                point = i
                nextPoint = i + 1
                b[point] = 0
                b[nextPoint] = 1
                break
            end
        end

        --将 i-point个元素的1往前移动 0往后移动
        for i = 1,point-1 do
            for  j = i,point-1 do
                if b[i]==0 then
                    temp = b[i]
                    b[i] = b[j+1]
                    b[j+1] = temp
                end
            end
        end
        sb={}
        count = 0
    end
    --print("table.combine return nums",#result)
    return result
end

--生序排列
quick_sort_ASC=function(t,comps,start,endi)
    start, endi = start or 1, endi or #t
    --partition w.r.t. first element
    if(endi - start < 1) then return t end
    local pivot = start
    for i = start + 1, endi do
        if comps(t[i],t[pivot]) == true  then
            local temp = t[pivot + 1]
            t[pivot + 1] = t[pivot]
            if(i == pivot + 1) then
                t[pivot] = temp
            else
                t[pivot] = t[i]
                t[i] = temp
            end
            pivot = pivot + 1
        end
   end
    t = quick_sort_ASC(t, comps, start, pivot - 1)
    return quick_sort_ASC(t, comps,  pivot + 1, endi)
end

--降序排序 /quicksort  desc
--target: 目标table/target table such as {9, -1, 4, 5, 18, 1, 8, 0, 20, 31}
--low：起始下标/start position
--high：终止下标/end position
function quick_sort_DESC(target , comps , low, high)
    low, high = low or 1, high or #target
    local t = low
    local r = high
    local temp = target[t]

    if low < high then
        while(t < r) do
            while(comps(target[r],temp) == true  and t < r) do
                r = r - 1
            end
            target[t] = target[r]
            while(comps(temp,target[t]) == true  and t < r) do
                t = t + 1
            end
            target[r] = target[t]
        end
        target[t] = temp
        quick_sort_DESC(target, comps, low, t-1)
        quick_sort_DESC(target, comps, r+1, high)
    end
end
