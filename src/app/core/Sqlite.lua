
local sqlite3 = require("lsqlite3")

--声明 Sqlite 类
local Sqlite = {}
local db = nil


Sqlite.tables={
    user_data="user_data",
    poker_data="poker_data",
    models_data="models_data",
}

function Sqlite.init()
    local sqlitepath = device.writablePath.."database6"
    db = sqlite3.open(sqlitepath)

    if core.Sqlite.tableExist(Sqlite.tables.models_data) == 0 then
        local createTableSentence= string.format("CREATE TABLE %s (id, model)", Sqlite.tables.models_data)
        core.Sqlite.executeSql(createTableSentence)
    end
end

function Sqlite.executeSql(sentence)
    return db:exec(sentence)
end

function Sqlite.queryRecord(sentence,func)
    for row in db:nrows(sentence) do
        func(row)
    end
end

function Sqlite.tableExist(table)

	local isTableSentence= string.format("SELECT COUNT(*) as count FROM sqlite_master where type='table' and name='%s'", table)

    local count = 0
    for row in db:nrows(isTableSentence) do
        count = row.count
    end

    return count
end


return Sqlite
