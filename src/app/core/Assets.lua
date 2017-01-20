require("lfs")

local Assets = {}

function Assets.exists(path)
    return cc.FileUtils:getInstance():isFileExist(path)
end

function Assets.mkdir(path)
    if not Assets.exists(path) then
        return lfs.mkdir(path)
    end
    return true
end

function Assets.rmdir(path)
    print("os.rmdir:", path)
    if Assets.exists(path) then
        local function _rmdir(path)
        
            local mode = lfs.attributes(path, "mode")

            if mode == "directory" then
                local iter, dir_obj = lfs.dir(path)
                while true do
                    local dir = iter(dir_obj)
                    if dir == nil then break end
                    if dir ~= "." and dir ~= ".." then
                    
                        local curDir = path..dir

                        local mode = lfs.attributes(curDir, "mode")

                        if mode == "directory" then
                            _rmdir(curDir.."/")
                        elseif mode == "file" then
                            os.remove(curDir)
                        end
                    end
                end
            elseif mode == "file" then
                os.remove(path)
            end

            local succ, des = os.remove(path)
            if des then print(des) end
            return succ
        end
        _rmdir(path)
    end
    return true
end

return Assets