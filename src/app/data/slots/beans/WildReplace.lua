local WildReplace = class("WildReplace")

function WildReplace:ctor(sourceSymbol)
    self.sourceSymbol = sourceSymbol
    self.replaceSymbols={}
end

function WildReplace:getSourceSymbol()
    return self.sourceSymbol
end

function WildReplace:setReplaceSymbols(replaceSymbols)
    self.replaceSymbols=replaceSymbols
end

function WildReplace:getReplaceSymbols()
    return self.replaceSymbols
end

function WildReplace:addReplaceSymbols(replaceSymbol)
    table.insert(self.replaceSymbols,replaceSymbol)
end

function WildReplace:insertFirstSymbol(replaceSymbol)
    table.insert(self.replaceSymbols,1,replaceSymbol)
end

function WildReplace:toString()
    local str="Wild图标:"..self.sourceSymbol:toString().."|替换的图标:"
    for i=1,#self.replaceSymbols do
        str=str.." "..self.replaceSymbols[i]:toString()
    end
    return str
end

return WildReplace