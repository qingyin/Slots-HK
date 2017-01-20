local User = class("User")

function User:ctor()
	cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()

    if core.Sqlite.tableExist(core.Sqlite.tables.user_data) == 0 then

        local keysstr="pid, serialNo, name, level, exp, vipLevel, vipPoint, coins, gems, money, liked, pictureId, successiveLoginDays, loginDays, extinfo, gameState, itemState"
        local createTableSentence= string.format("CREATE TABLE %s (id INT PRIMARY KEY, %s)", 
            core.Sqlite.tables.user_data,keysstr
            )
        core.Sqlite.executeSql(createTableSentence)
    end
end

function User:init(usermodel)
    local cls = usermodel.class

    cc.EventProxy.new(usermodel)
        :addEventListener(cls.GEM_CHANGED_EVENT, handler(self, self.updateGems))

    self:loadToModel(usermodel)
end

function User:loadToModel(model)

    local cls   =   model.class

	local userdata = nil

    local function queryBack(row)
        userdata = row
    end

    core.Sqlite.queryRecord(
        string.format("SELECT * FROM %s WHERE id=%d", core.Sqlite.tables.user_data, 1),
        queryBack
    )

    if userdata == nil then

        local properties = model:getProperties({
            cls.pid, 
            cls.serialNo, 
            cls.name, 
            cls.level, 
            cls.exp, 
            cls.vipLevel, 
            cls.vipPoint, 
            cls.coins, 
            cls.gems, 
            cls.money, 
            cls.liked, 
            cls.pictureId,
            cls.successiveLoginDays,
            cls.loginDays, 
            cls.extinfo, 
            cls.gameState, 
            cls.itemState})

        local isql=string.format("INSERT INTO %s VALUES (1, %d,%d,'%s',%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,'%s','%s','%s')",
            core.Sqlite.tables.user_data,
            properties[cls.pid], 
            properties[cls.serialNo],
            properties[cls.name],
            properties[cls.level],
            properties[cls.exp],
            properties[cls.vipLevel],
            properties[cls.vipPoint],
            properties[cls.coins],
            properties[cls.gems],
            properties[cls.money],
            properties[cls.liked],
            properties[cls.pictureId],
            properties[cls.successiveLoginDays],
            properties[cls.loginDays],
            json.encode(properties[cls.extinfo]),
            json.encode(properties[cls.gameState]),
            json.encode(properties[cls.itemState]))

        core.Sqlite.executeSql(isql)
    else

        local properties = {}
        
        for field, schema in pairs(cls.schema) do
            local typ, def = schema[1], schema[2]
            local val = userdata[field]
            
            if val ~= nil then
                if typ == "table" then
                    properties[field]=json.decode(val)
                else
                    properties[field]=val
                end
            end
        end

        model:setProperties(properties)
    end

    
end

function User:updateGems(event)
    local cls = event.model.class
    --core.Sqlite.executeSql(string.format("UPDATE %s SET '%s' = %d", core.Sqlite.tables.user_data, cls.gems, tonumber(event.model:getGems())))

    self:serializeProperty({model=event.model, table=core.Sqlite.tables.user_data, key=cls.gems, val=event.model:getGems()})

end

function User:serializeProperty(property)
    local cls = property.model.class
    local schema = cls.schema[property.key]
    local typ, def = schema[1], schema[2]

    local sqlstr="UPDATE "..property.table.." SET ".."'"..property.key.."'".." = "

    if typ == "number" then
        sqlstr=sqlstr.."%d"
        sqlstr = string.format(sqlstr, property.val)
    elseif typ == "string" then
        sqlstr=sqlstr.."'%s'"
        sqlstr = string.format(sqlstr, property.val)
    elseif typ == "table" then
        sqlstr=sqlstr.."'%s'"
        sqlstr = string.format(sqlstr, json.encode(property.val))
    end

    core.Sqlite.executeSql(sqlstr)
end

function User:serializeAll(event)
    local model = event.model
    local cls = model.class

    local properties = model:getProperties({
            cls.pid, 
            cls.serialNo, 
            cls.name, 
            cls.level, 
            cls.exp, 
            cls.vipLevel, 
            cls.vipPoint, 
            cls.coins, 
            cls.gems, 
            cls.money, 
            cls.liked, 
            cls.pictureId,
            cls.successiveLoginDays,
            cls.loginDays, 
            cls.extinfo, 
            cls.gameState, 
            cls.itemState})

    local keyvalstr=""

    local idx = 1

    for field, schema in pairs(cls.schema) do
        local typ, def = schema[1], schema[2]
        local val = properties[field]

        if val ~= nil then

            local keyval = ""
            if idx > 1 then keyval = ","..keyval end

            keyval=keyval.."'"..field.."'".." = "
            if typ == "number" then
                keyval=keyval.."%d"
                keyval = string.format(keyval, val)
            elseif typ == "string" then
                keyval=keyval.."'%s'"
                keyval = string.format(keyval, val)
            elseif typ == "table" then
                keyval=keyval.."'%s'"
                keyval = string.format(keyval, json.encode(val))
            end
            keyvalstr = keyvalstr..keyval
        end

        idx = idx + 1
    end
    
    local sqlStr="UPDATE "..core.Sqlite.tables.user_data.." SET "..keyvalstr

    core.Sqlite.executeSql(sqlStr)
end

return User