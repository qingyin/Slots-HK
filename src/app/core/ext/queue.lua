queue = {}

function queue.new()
    return {first = 0, last = -1}
end

function queue.pushleft (q, v)
    local first = q.first - 1
    q.first = first
    q[first] = v
end

function queue.push (q, v)
    local last = q.last + 1
    q.last = last
    q[last] = v
end

function queue.pop (q)
    local first = q.first
    if first > q.last then return nil end
    local v = q[first]
    q[first] = nil        -- to allow garbage collection
    q.first = first + 1
    return v
end

function queue.popright (q)
    local last = q.last
    if q.first > last then return nil end
    local v = q[last]
    q[last] = nil         -- to allow garbage collection
    q.last = last - 1
    return v
end

function queue.empty (q)
    if q.first > q.last then return true end
    return false
end

function queue.gettop (q)
    local first = q.first
    if first > q.last then return nil end
    return  q[first]
end
