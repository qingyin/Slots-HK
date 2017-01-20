
--[[--
Serialize Class
]]
local SerializeModel = class("SerializeModel", cc.mvc.ModelBase)

local function getUDID()
    return CCAccountManager:sharedAccountManager():UDID()
end

function SerializeModel:loadModel()

    local cls = self.class

	local userdata = nil

    local function queryBack(row)
        userdata = row
    end

    -- print("self:getId()", self:getId())

    core.Sqlite.queryRecord(
        string.format("SELECT * FROM %s WHERE id='%s'", core.Sqlite.tables.models_data, self:getId()),
        queryBack
    )

    -- print("userdata:", userdata)

    if userdata == nil then
    	local properties = {}

    	for field, schema in pairs(cls.schema) do
        	local typ, def = schema[1], schema[2]
   			local propname = field .. "_"
        	local val = self[propname]
         	
         	if val ~= nil then
            	properties[field] = val
        	end
    	end

        self:setProperty("udid", getUDID())
        properties.udid= getUDID()

        -- print("new user model:", json.encode(properties))

		local sqlstr=string.format("INSERT INTO %s  VALUES ('%s','%s')", core.Sqlite.tables.models_data, self:getId(), json.encode(properties))
        core.Sqlite.executeSql(sqlstr)
    else

        local properties = json.decode(userdata.model)

        print("properties form db:", userdata.model)
        -- print("UDID:", properties.udid, getUDID())
        assert(properties.udid == getUDID(), "udid not maching!" )
        
        self:setProperties(properties)

    end
end

function SerializeModel:serializeModel()
    local cls = self.class

    local properties = {}

    for field, schema in pairs(cls.schema) do
        local typ, def = schema[1], schema[2]
   		local propname = field .. "_"
        local val = self[propname]
         	
        if val ~= nil then
            properties[field] = val
        end
    end

    -- print("properties2:", properties, json.encode(properties))

    local sqlStr = string.format("UPDATE %s SET 'model'='%s' WHERE id='%s'", core.Sqlite.tables.models_data, json.encode(properties), self:getId())

    core.Sqlite.executeSql(sqlStr)

end


function SerializeModel:setProperty(key, val)

    local schema = self.class.schema[key]
    local typ, def = schema[1], schema[2]

    local propname = key .. "_"

    if val ~= nil then
        if typ == "number" then val = tonumber(val) end
        self[propname] = val
    elseif self[propname] == nil and def ~= nil then
        if type(def) == "table" then
            val = clone(def)
        elseif type(def) == "function" then
            val = def()
        else
            val = def
        end
        self[propname] = val
    end

    return self
end

function SerializeModel:getProperty(key)
    local schema = self.class.schema

    local propname = key .. "_"
    local typ = schema[key][1]
    local val = self[propname]

    return val
end

return SerializeModel
