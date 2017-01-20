
--获得用户体验级别
function getExperienceLevel()
     return USER_EXPERIENCE.MEDIUM_EXP_LEVEL
end

function getTableMachineId(tableId)
    local machines=DICT_TABLE[tostring(tableId)].contain_machines
    local expLevel=getExperienceLevel()
    local mid=machines[expLevel]
    
    if mid ~= nil then
        return tonumber(mid)
    end
    
    return tonumber(machines[#machines])
end

function getMachineIdsByTableId(tableId)
    return getTableMachineId(tableId)
end

function getMachineTableId(machineId)
    local tableId=0
    local tmp_mid=machineId
    local tmp_machine=DICT_MACHINE[tostring(tmp_mid)]

    if tmp_machine.f_machine_id == "" then
        for key, val in pairs(DICT_MACHINE) do
            if val.f_machine_id==machineId then
                tmp_mid=val.machine_id
                break
            end
        end
    end

    for key, val in pairs(DICT_TABLE) do
        local machines=val.contain_machines
        for i=1,#machines do
            if tonumber(tmp_mid)==machines[i] then
                tableId=tonumber(key)
                break
            end
        end
    end

    return tableId
end

function getTableIdByMachineId(machineId)
    local tableId=0
    local tmp_mid=machineId
    local tmp_machine = DICT_MACHINE[tostring(tmp_mid)]
    local f_mid=tmp_machine.f_machine_id
    if f_mid == "" then
        tmp_mid=tmp_machine.machine_id
    end
    for key, val in pairs(DICT_TABLE) do
        local machines=val.contain_machines
        for i=1,#machines do
            if tonumber(tmp_mid)==machines[i] then
                tableId=tonumber(key)
                break
            end
        end
    end

    return tableId
end

function getSceneMachines(sceneId)
    local machines={}
    local tables=DICT_SCENE[tostring(sceneId)].contain_tables
    for i=1,#tables do
        local tmpId=getTableMachineId(tables[i])
        table.insert(machines,tmpId)
    end
    return machines
end
--玩家体验系统时修正gameSet
--[[
    所需参数因子:
    1 总游戏数 生涯前10把是否已体验过
    2 每日游戏局数(每日首次登录后清零) 
    3 每日前十把是否已体验过(每日首次登录后重置)
    4 上次购买金币后得局数(该参数每次购买金币后重置) 
    5 上次购买金币后是否已体验过(该参数每次购买金币后重置)
    6 是否已使用过booster
]]
-- function handleExpGameSet(gameSet)
--     --return 0

--    ---[[
--     print("-------------handleExpGameSet---------------")
--     local model = app:getObject("UserModel")
--     local cls = model.class
--     local properties = model:getProperties({cls.level, cls.exp})
--     local modellevel = properties[cls.level]
--     local modelexp = properties[cls.exp]
--     print("modellevel:", modellevel)
--     print("modelexp:", modelexp)

--     local totalGames = User.Report.getGameState(User.Report.KEY_GAME_TOTALGAMES)
--     local spincountafterbuy = User.getProperty(User.KEY_SPINCOUNTAFTERBUY)
--     --local spincountperday = User.getProperty(User.KEY_SPINCOUNTPERDAY)
--     --local useboostsign = User.getProperty(User.KEY_USEBOOSTSIGN)
--     --local dayrescuresign = User.getProperty(User.KEY_DAY_RESCURE_SIGN)
--     --local faillasttimes = User.getProperty(User.KEY_FAIL_LAST_TIMES)

--     --print("handleExpGameSet:",totalGames,spincountperday,spincountafterbuy,useboostsign,dayrescuresign,faillasttimes)
    
--     local level = tonumber(User.getProperty(User.KEY_LEVEL))
--     --local purchased=User.getProperty(User.KEY_PURCHASED)
--     local exp = User.getProperty(User.KEY_EXP)
   
--     if level < RESULT_POOL_LEVEL.REPEAT_BEGIN_LEVEL then
--         gameSet:setPoolId(getPoolIdByLevel(level,exp))
--     end
--     --[[
--     --首次使用道具
--     if USER_EXPERIENCE.SWITCH_SIGN.USE_BOOSTER_SIGN==1 and useboostsign~=nil and useboostsign==1 then
--         gameSet:setPoolId(RESULT_POOL.TotalBet2_5)
--         User.setProperty(User.KEY_USEBOOSTSIGN,2)
--     end
    
--     --每日赠送点
--     if USER_EXPERIENCE.SWITCH_SIGN.DAY_RESCURE_SIGN==1 and dayrescuresign~=nil and dayrescuresign==false then
--         local level = tonumber(User.getProperty(User.KEY_LEVEL))
--         local totalCoins= tonumber(User.getProperty(User.KEY_TOTALCOINS))
--         local totalBet=getMaxTotalBet(level,gameSet:getMachineId())
--         if totalCoins <= totalBet*2 then
--             gameSet:setPoolId(RESULT_POOL.TotalBet10_20)
--             User.setProperty(User.KEY_USEBOOSTSIGN,true)
--         end
--     end
    
--     --连续六次不中奖
--     if USER_EXPERIENCE.SWITCH_SIGN.FAIL_LAST_TIMES==1 and faillasttimes~=nil and faillasttimes >= 6 then
--         gameSet:setPoolId(RESULT_POOL.TotalBet1_2)
--         User.setProperty(User.KEY_FAIL_LAST_TIMES,0)
--     end
    
--     --玩家每日首次登录游戏
--     if USER_EXPERIENCE.SWITCH_SIGN.FIRST_DAY_LOGIN==1 and spincountperday<=10 then
--         local pool=User.getProperty(User.KEY_FIRST_DAY_LOGIN_POOL)
--         if pool==nil then
--             pool=initFirstDayLoginPool()
--         end
--         if pool~=nil and pool[spincountperday]~=nil and pool[spincountperday]>0 then
--             gameSet:setPoolId(pool[spincountperday])
--         end
--     end
--     --]]
    
--     --购买金币
--     if USER_EXPERIENCE.SWITCH_SIGN.BUY_COINS==1 and spincountafterbuy~=nil and spincountafterbuy<=10 then
--         local pool=User.getProperty(User.KEY_BUY_COINS_POOL)
--         if pool~=nil and pool[spincountafterbuy]~=nil and pool[spincountafterbuy]>0 then
--             gameSet:setPoolId(pool[spincountafterbuy])
--         end
--     end
    
--     --玩家首次进入到游戏中
--     if USER_EXPERIENCE.SWITCH_SIGN.FIRST_LOGIN==1 and totalGames~=nil and totalGames<=10 then
--         local pool=User.getProperty(User.KEY_FIRST_LOGIN_POOL)
--         if pool==nil then
--             pool=initFirstLoginPool()
--         end
--         if pool~=nil and pool[totalGames]~=nil and pool[totalGames]>0 then
--             gameSet:setPoolId(pool[totalGames])
--         end
--     end
    
--     print("UsePoolId:",gameSet:getPoolId())
--     --]]
-- end

-- local function initExpPool(type)
--     local pool={}
--     if type=="FIRST_LOGIN" then
--         pool=USER_EXPERIENCE.EXP_POOL.FIRST_LOGIN
--         table.RandShuffle(pool)
--         User.setProperty(User.KEY_FIRST_LOGIN_POOL,pool,true)
--     elseif type=="FIRST_DAY_LOGIN" then
--         pool=USER_EXPERIENCE.EXP_POOL.FIRST_DAY_LOGIN
--         table.RandShuffle(pool)
--         User.setProperty(User.KEY_FIRST_DAY_LOGIN_POOL,pool,true)
--         --table.dump(pool,"vivian")
--     elseif type=="BUY_COINS" then
--         pool=USER_EXPERIENCE.EXP_POOL.BUY_COINS
--         table.RandShuffle(pool)
--         User.setProperty(User.KEY_BUY_COINS_POOL,pool,true)
--     end
--     return pool
-- end

function handleExpGameSet(gameSet)
    local model = app:getObject("UserModel")
    local cls = model.class
    local properties = model:getProperties({cls.level, cls.exp, cls.totalgames, cls.spincountafterbuy, cls.buyCoinsPool, cls.firstLoginPool})

    local level = tonumber(properties[cls.level])
    local exp = tonumber(properties[cls.exp])
    if level < RESULT_POOL_LEVEL.REPEAT_BEGIN_LEVEL then
        gameSet:setPoolId(getPoolIdByLevel(level,exp))
    end

    local totalGames = tonumber(properties[cls.totalgames])
    local spincountafterbuy = tonumber(properties[cls.spincountafterbuy])

    --print("handleExpGameSet:",totalGames,spincountafterbuy)
    
    --购买金币
    if USER_EXPERIENCE.SWITCH_SIGN.BUY_COINS==1 and spincountafterbuy~=nil and spincountafterbuy >=0 and spincountafterbuy<=10 then
        local pool = properties[cls.buyCoinsPool]
        if pool~=nil and pool[spincountafterbuy]~=nil and pool[spincountafterbuy]>0 then
            gameSet:setPoolId(pool[spincountafterbuy])
        end
    end
    
    --玩家首次进入到游戏中
    if USER_EXPERIENCE.SWITCH_SIGN.FIRST_LOGIN==1 and level < 5 and totalGames~=nil and totalGames<=10 then
        local pool = properties[cls.firstLoginPool]
        if #pool==0 then
            pool=initFirstLoginPool()
        end
        if pool~=nil and pool[totalGames]~=nil and pool[totalGames]>0 then
            gameSet:setPoolId(pool[totalGames])
        end
    end
    
    print("UsePoolId:",gameSet:getPoolId())
    --]]
end

local function initExpPool(type)
    --print("initExpPool:", type)
    local model = app:getObject("UserModel")
    local cls = model.class

    local pool={}
    if type=="FIRST_LOGIN" then
        pool=USER_EXPERIENCE.EXP_POOL.FIRST_LOGIN
        table.RandShuffle(pool)

        local properties = model:getProperties({cls.firstLoginPool})
        properties[cls.firstLoginPool] = pool
        model:setProperties(properties)
        model:serializeModel()

    elseif type=="FIRST_DAY_LOGIN" then
        pool=USER_EXPERIENCE.EXP_POOL.FIRST_DAY_LOGIN
        table.RandShuffle(pool)
        User.setProperty(User.KEY_FIRST_DAY_LOGIN_POOL,pool,true)
        --table.dump(pool,"vivian")
    elseif type=="BUY_COINS" then
        pool=USER_EXPERIENCE.EXP_POOL.BUY_COINS
        table.RandShuffle(pool)

        local properties = model:getProperties({cls.buyCoinsPool})
        properties[cls.buyCoinsPool] = pool
        model:setProperties(properties)
        model:serializeModel()
    end
    -- print("------initExpPool:end---------")
    -- puts(pool)

    return pool
end

--用户初始化时调用
function initFirstLoginPool()
    local pool=initExpPool("FIRST_LOGIN")
    return pool
end

--每日首次登录时调用
function initFirstDayLoginPool()
    local pool=initExpPool("FIRST_DAY_LOGIN")
    return pool
end

--充值完成后调用
function initBuyCoinsPool()
    local pool=initExpPool("BUY_COINS")
    return pool
end

function getPoolIdByLevel(level,exp)
    local poolId=0

    local currentDictLevel=DICT_LEVEL[tostring(level)]
    local currentLevelExp=tonumber(currentDictLevel.need_total_bets)
    local nextDictLevel=DICT_LEVEL[tostring(level+1)]
    local nextLevelExp=tonumber(nextDictLevel.need_total_bets)
    local remain_level=(exp-currentLevelExp)/(nextLevelExp-currentLevelExp)

    local accurate_level=0
    local pool_config=nil
    if level <  RESULT_POOL_LEVEL.REPEAT_BEGIN_LEVEL then
        accurate_level=level+remain_level
        pool_config=RESULT_POOL_LEVEL.UNIQUE_LEVEL
    else
        --local slevel=tostring(level)
        --local slen=string.len(slevel)
        --local gewei=string.sub(slevel,slen,slen)
        local gewei=math.mod(level,5)
        accurate_level=gewei+remain_level
        pool_config=RESULT_POOL_LEVEL.REPEAT_LEVEL
    end
    
    --print("getPoolIdByLevel=level,exp,accurate_level",level,exp,accurate_level)
    
    local weight=nil
    for i=1,#pool_config do
        if accurate_level >= pool_config[i].minLevel and accurate_level < pool_config[i].maxLevel then
            --table.dump(pool_config[i].weight,"pool_config[i].weight")
            weight=pool_config[i].weight
            break
        end
    end
    
    if weight~=nil then
        poolId=getWeightPoolId(weight)
    end
    
    --print("getPoolIdByLevel=poolId",poolId)
    
    return poolId
end


--获得某个权重配置的poolId
function getWeightPoolId(weight)
    local poolId=0
    local list=weight.LIST
    local use_wight=weight.USE_WIGHT
    local all_weight=weight.ALL_WIGHT
    math.random(all_weight)
    local rand_wight=math.random(all_weight)
    
    --print("getWeightPoolId all_weight use_wight rand_wight",all_weight,use_wight,rand_wight)
    
    if rand_wight>use_wight then
        return 0
    end
    
    local pool_weight=math.random(all_weight)
    --print("getWeightPoolId pool_weight",pool_weight)
    local key_table = {}
    for key, val in pairs(list) do
        table.insert(key_table,key)
    end
    local function comps(a,b)
        return tonumber(a) < tonumber(b)
    end
    table.sort(key_table,comps)

    local pool_list=nil
    local tmp_pid=0
    for i=1,#key_table do
        local nkey=tonumber(key_table[i])
        if pool_weight > tmp_pid and nkey >= pool_weight then
            pool_list=list[key_table[i]]
            break
        end
        tmp_pid=nkey
    end
    
    if pool_list==nil then
        return 0
    else
        return pool_list
    end
end







