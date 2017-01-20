module("app.data.slots.calculation.WildReelUtil", package.seeall)

local WildReelUtil = app.data.slots.calculation.WildReelUtil
local MatrixUtil = require("app.data.slots.calculation.MatrixUtil")
local MatrixSymbol=import("app.data.slots.beans.MatrixSymbol")
local WildReplace = import("app.data.slots.beans.WildReplace")


local dicMachine=DICT_MACHINE
local dicReels=DICT_REELS

--处理wildreel图标出现的各种情况
function WildReelUtil.handleWildReel(stopMatrix,stopPosMatrix)
    local replaceWilds={}
    local sourceWilds={}
    
    for pos, matrixSymbol in pairs(stopPosMatrix) do
        local wildReelSymbol=DICT_WILD_REEL[tostring(matrixSymbol:getSymbolId())]
        if wildReelSymbol~=nil then
           sourceWilds[pos]=matrixSymbol:clone()
           --print("原始图标:"..matrixSymbol:toString())
        end
    end
    
    for pos, matrixSymbol in pairs(sourceWilds) do
        local wildReelSymbol=DICT_WILD_REEL[tostring(matrixSymbol:getSymbolId())]
        local wildReelType=wildReelSymbol.wild_reel_type
        if wildReelType==WILD_REEL_TYPE.WildReelA then
            WildReelUtil.handleWildReelA(matrixSymbol,stopMatrix,replaceWilds,DIRECTION.TOP)
        elseif wildReelType==WILD_REEL_TYPE.WildReelB then
            WildReelUtil.handleWildReelB(matrixSymbol,stopMatrix,replaceWilds)
        elseif wildReelType==WILD_REEL_TYPE.WildReelC then
            WildReelUtil.handleWildReelC(matrixSymbol,stopMatrix,replaceWilds)
        elseif wildReelType==WILD_REEL_TYPE.WildDuplicateA then
            WildReelUtil.handleWildDuplicateA(matrixSymbol,stopMatrix,replaceWilds)
        elseif wildReelType==WILD_REEL_TYPE.WildDuplicateB then
            WildReelUtil.handleWildDuplicateB(matrixSymbol,stopMatrix,replaceWilds)
        elseif wildReelType==WILD_REEL_TYPE.WildHoldA then

        elseif wildReelType==WILD_REEL_TYPE.WildHoldB then
        
        elseif wildReelType==WILD_REEL_TYPE.WildHoldC then
        
        end
    end
    
    for i=1,#stopMatrix do
        local tmpReel=stopMatrix[i]
        for k=1,#tmpReel do
            stopPosMatrix[tmpReel[k]:getCoordinate()]=tmpReel[k]
        end
    end
    
    return replaceWilds
end

--[[
该图标出现在游戏“轴”的最上方，则触发该图标，将该图标下方依次相邻的两个图标变成Wild，变成的Wild图标与普通Wild图标功能相同；
如该图标出现在游戏“轴”的中间或下方，则不能触发该图标变化，该图标只能作为普通Wild图标使用
]]
function WildReelUtil.handleWildReelA(matrixSymbol,stopMatrix,replaceWilds,direction)
    local wildReelSymbol=DICT_WILD_REEL[tostring(matrixSymbol:getSymbolId())]
    local wildConfig=WildConfig[wildReelSymbol.wild_reel_type]
    local reelIdx=matrixSymbol:getX()+1
    local reelSymbols=stopMatrix[reelIdx]
    local lastSymbol=reelSymbols[#reelSymbols]
    local firstSymbol=reelSymbols[1]
    --如果出现在最上方
    if lastSymbol:getCoordinate()==matrixSymbol:getCoordinate() and direction==DIRECTION.TOP then
        --替换的图标数量
        local changeNums=tonumber(wildConfig.change_symbols)
        for i=1,changeNums do
            local sidx=#reelSymbols-i
            --旧图标
            local oldSymbol=reelSymbols[sidx]
            WildReelUtil.replaceSymbol(matrixSymbol,replaceWilds,reelSymbols,oldSymbol)
        end
    end
    --如果出现在最下方
    if firstSymbol:getCoordinate()==matrixSymbol:getCoordinate() and direction==DIRECTION.BOOTOM then
        --替换的图标数量
        local changeNums=tonumber(wildConfig.change_symbols)
        for i=1,changeNums do
            local sidx=i+1
            --旧图标
            local oldSymbol=reelSymbols[sidx]
            WildReelUtil.replaceSymbol(matrixSymbol,replaceWilds,reelSymbols,oldSymbol)
        end
    end

    stopMatrix[reelIdx]=reelSymbols
end

--[[
该图标出现游戏轴的任何位置，都将触发该图标。如出现在上方，则将下方依次相邻的两个图标变成普通Wild；
如出现在下方，则将上方依次相邻的两个图标变成普通Wild；如出现在中奖，则将上下相邻的两个图标变成普通Wild
]]
function WildReelUtil.handleWildReelB(matrixSymbol,stopMatrix,replaceWilds)
    local reelIdx=matrixSymbol:getX()+1
    local reelSymbols=stopMatrix[reelIdx]
    local lastSymbol=reelSymbols[#reelSymbols]
    local firstSymbol=reelSymbols[1]
    --如果出现在最上方
    if lastSymbol:getCoordinate()==matrixSymbol:getCoordinate() then
        WildReelUtil.handleWildReelA(matrixSymbol,stopMatrix,replaceWilds,DIRECTION.TOP)
    --如果出现在最下方
    elseif firstSymbol:getCoordinate()==matrixSymbol:getCoordinate() then
        WildReelUtil.handleWildReelA(matrixSymbol,stopMatrix,replaceWilds,DIRECTION.BOOTOM)
    --中间了
    else
        --当前图标在数组的索引
        local sidx=matrixSymbol:getY()+1
        local oldAboveSymbol=reelSymbols[sidx+1]
        WildReelUtil.replaceSymbol(matrixSymbol,replaceWilds,reelSymbols,oldAboveSymbol)

        local oldUnderSymbol=reelSymbols[sidx-1]
        WildReelUtil.replaceSymbol(matrixSymbol,replaceWilds,reelSymbols,oldUnderSymbol)
    end
    
    local replaceId=DICT_WILD_REEL[tostring(matrixSymbol:getSymbolId())].replace_id
    local replaceSymbol=matrixSymbol:clone()
    replaceSymbol:setSymbolId(replaceId)
    --替换轴上旧图标
    reelSymbols[replaceSymbol:getY()+1]=replaceSymbol

    --没有可替换图标时返回只有source图标的对象
    local wildReplace=replaceWilds[matrixSymbol:getCoordinate()]
    if wildReplace==nil then
       wildReplace=WildReplace.new(matrixSymbol)
    end

    wildReplace:insertFirstSymbol(replaceSymbol)
    replaceWilds[matrixSymbol:getCoordinate()]=wildReplace

    
    stopMatrix[reelIdx]=reelSymbols
end

--[[
    替换图标Index后面所有Index的图标为该图标
]]
function WildReelUtil.handleWildReelC(matrixSymbol,stopMatrix,replaceWilds)
    local reelIdx=matrixSymbol:getX()+1
    local reelSymbols=stopMatrix[reelIdx]
    
    local sidx=matrixSymbol:getY()+1
    for i=sidx+1,#reelSymbols do
        local oldAboveSymbol=reelSymbols[i]
        WildReelUtil.replaceSymbol(matrixSymbol,replaceWilds,reelSymbols,oldAboveSymbol)
    end
    
    local replaceId=DICT_WILD_REEL[tostring(matrixSymbol:getSymbolId())].replace_id
    local replaceSymbol=matrixSymbol:clone()
    replaceSymbol:setSymbolId(replaceId)
    --替换轴上旧图标
    reelSymbols[replaceSymbol:getY()+1]=replaceSymbol
    
    --没有可替换图标时返回只有source图标的对象
    local wildReplace=replaceWilds[matrixSymbol:getCoordinate()]
    if wildReplace==nil then
       wildReplace=WildReplace.new(matrixSymbol)
    end

    wildReplace:insertFirstSymbol(replaceSymbol)
    replaceWilds[matrixSymbol:getCoordinate()]=wildReplace

    stopMatrix[reelIdx]=reelSymbols
end

--内部方法，替换图标
function WildReelUtil.replaceSymbol(matrixSymbol,replaceWilds,reelSymbols,oldSymbol)
    print("原始图标:"..matrixSymbol:toString())
    print("WildReelUtil.replaceSymbol 旧图标:"..oldSymbol:toString())
    local dicSymbol=DICT_SYMBOL[tostring(oldSymbol:getSymbolId())]
    
    --螃蟹的逻辑，不是替换成自己，而是替换成跟自己关联的一个图标
    local replaceSymbol=matrixSymbol
    local replaceId=DICT_WILD_REEL[tostring(matrixSymbol:getSymbolId())].replace_id
    if replaceId ~= "" then
        replaceSymbol=matrixSymbol:clone()
        replaceSymbol:setSymbolId(replaceId)
    end

    --如果被替换的是普通图标
    if dicSymbol.symbol_type==SYMBOL_TYPE.Normal then
        --复制个旧图标
        local newSymbol=oldSymbol:clone()
        --改变其symbolId
        newSymbol:setSymbolId(replaceSymbol:getSymbolId())
        
        print("WildReelUtil.replaceSymbol 新图标:"..newSymbol:toString())

        --替换轴上旧图标
        reelSymbols[newSymbol:getY()+1]=newSymbol

        --处理替换table
        local wildReplace=replaceWilds[matrixSymbol:getCoordinate()]
        if wildReplace==nil then
           wildReplace=WildReplace.new(matrixSymbol)
        end
        wildReplace:addReplaceSymbols(newSymbol)
        replaceWilds[matrixSymbol:getCoordinate()]=wildReplace
    end
    print("@@@@@@@@@@@@@@@@@@WildReelUtil.replaceSymbol替换完成")
end

--[[
当在游戏中出现Wild图标时，将会把除本轴之外的的另一条轴上的其中一个Symbol（Bonus，Scatter和本来已经是Wild的Symbol除外）变成Wild图标，并遵循以下规则：
    当Wild在第1条轴出现时，它将只能将第3，4，5轴上的任意一个Symbol变成Wild；
    当Wild在第2条轴出现时，它将只能将第3，4，5轴上的任意一个Symbol变成Wild；
    当Wild在第3条轴出现时，它将只能将第2，4，5轴上的任意一个Symbol变成Wild；
    当Wild在第4条轴出现时，它将只能将第2，3，5轴上的任意一个Symbol变成Wild；
    当Wild在第5条轴出现时，它将只能将第1，2，3轴上的任意一个Symbol变成Wild；
]]
function WildReelUtil.handleWildDuplicateA(matrixSymbol,stopMatrix,replaceWilds)
    local wildReelSymbol=DICT_WILD_REEL[tostring(matrixSymbol:getSymbolId())]
    local wildConfig=WildConfig[wildReelSymbol.wild_reel_type]
    local reelIdx=matrixSymbol:getX()+1
    local reelSymbols=stopMatrix[reelIdx]
    
    local function isSymbolsOK(chgReelSymbols)
        local isOk=false
        for i=1,#chgReelSymbols do
            local tmpSymbol=chgReelSymbols[i]
            local dicSymbol=DICT_SYMBOL[tostring(tmpSymbol:getSymbolId())]
            if dicSymbol.symbol_type==SYMBOL_TYPE.Normal then
                isOk=true
                break
            end
        end
        return isOk
    end

    local function getChangeReelIdx()
        local changeRules=wildConfig.change_rules

        local changeRule=changeRules[tostring(reelIdx)]
        math.random(#changeRule.change_reels)
        local changeReelIdx=changeRule.change_reels[math.random(#changeRule.change_reels)]
        local chgReelSymbols=stopMatrix[changeReelIdx]
        
        local isOk=isSymbolsOK(chgReelSymbols)
        if isOk==true then
            return changeReelIdx
        end
        
        for k=1,#changeRule.change_reels do
            local chgReelSymbols=stopMatrix[changeRule.change_reels[k]]
            if isSymbolsOK(chgReelSymbols)==true then
                changeReelIdx=changeRule.change_reels[k]
                break
            end
        end
        return changeReelIdx
    end
    
    local function getTmpReelSymbols(changeReelIdx)
        print("changeReelIdx="..changeReelIdx)
        local chgReelSymbols=stopMatrix[changeReelIdx]
    
        local tmpReelSymbols={}
        for i=1,#chgReelSymbols do
            local tmpSymbol=chgReelSymbols[i]
            local dicSymbol=DICT_SYMBOL[tostring(tmpSymbol:getSymbolId())]
            if dicSymbol.symbol_type==SYMBOL_TYPE.Normal then
                table.insert(tmpReelSymbols,tmpSymbol)
            end
        end
        
        return tmpReelSymbols,chgReelSymbols
    end
    
    local changeReelIdx=getChangeReelIdx()
    local tmpReelSymbols,chgReelSymbols=getTmpReelSymbols(changeReelIdx)

    
    if table.isEmpty(tmpReelSymbols) == false then
        local oldSymbol=tmpReelSymbols[math.random(#tmpReelSymbols)]
        WildReelUtil.replaceSymbol(matrixSymbol,replaceWilds,chgReelSymbols,oldSymbol)
        stopMatrix[changeReelIdx]=chgReelSymbols
    end
end

--[[
当在游戏中出现Wild图标时，将会把Symbol区域内另外2个Symbol（Bonus，Scatter和本来已经是Wild的Symbol除外）变成Wild图标，并遵循如下规则：
    当Wild图标出现时，会将上方或下方其中一个Symbol变成Wild，同时会将左侧或者右侧其中一个Symbol变成Wild；
    如果该Wild图标的上方是边界，则变化下方相邻Symbol；如果下方是边界，则变化上方相邻Symbol
    如果该Wild图标的左侧是边界，则变化右侧相邻Symbol；如果右侧是边界，则变化左侧相邻Symbol
]]
function WildReelUtil.handleWildDuplicateB(matrixSymbol,stopMatrix,replaceWilds)
    local reelIdx=matrixSymbol:getX()+1
    local reelSymbols=stopMatrix[reelIdx]
    local lastSymbol=reelSymbols[#reelSymbols]
    local firstSymbol=reelSymbols[1]
    --如果出现在最上方
    if lastSymbol:getCoordinate()==matrixSymbol:getCoordinate() then
        WildReelUtil.handleWildReelA(matrixSymbol,stopMatrix,replaceWilds,DIRECTION.TOP)
    --如果出现在最下方
    elseif firstSymbol:getCoordinate()==matrixSymbol:getCoordinate() then
        WildReelUtil.handleWildReelA(matrixSymbol,stopMatrix,replaceWilds,DIRECTION.BOOTOM)
    else
        math.random(2)
        local rnum=math.random(2)
        local osymbol=nil
        local y=matrixSymbol:getY()+1
        if rnum > 1 then
            osymbol=reelSymbols[y+1]
        else
            osymbol=reelSymbols[y-1]
        end
        WildReelUtil.replaceSymbol(matrixSymbol,replaceWilds,reelSymbols,osymbol)
        stopMatrix[reelIdx]=reelSymbols
    end
    
    --替换相邻轴的图标
    local chgReelIdx=1
    if reelIdx==1 then
        chgReelIdx=reelIdx+1
    elseif reelIdx==#stopMatrix then
        chgReelIdx=#stopMatrix-1
    else
        math.random(2)
        local rnum=math.random(2)
        if rnum > 1 then
            chgReelIdx=reelIdx+1
        else
            chgReelIdx=reelIdx-1
        end
    end
    
    print("chgReelIdx="..chgReelIdx)
    
    local chgReelSymbols=stopMatrix[chgReelIdx]
    local oldSymbol=chgReelSymbols[matrixSymbol:getY()+1]

    WildReelUtil.replaceSymbol(matrixSymbol,replaceWilds,chgReelSymbols,oldSymbol)
    stopMatrix[chgReelIdx]=chgReelSymbols
end

