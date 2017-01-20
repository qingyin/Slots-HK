local TabBase = class("TabBase", function()
    return core.displayEX.newSwallowEnabledNode()
end)

function TabBase:ctor()
    self.tabNum=2
    self.selectedIdx = -1
end

function TabBase:addTabEvent(idx, callfunction)
    core.displayEX.addSpriteEvent(self["tab"..tostring(idx)],callfunction)
end

function TabBase:showTab(idx)
    self.selectedIdx = idx

    for i=1, self.tabNum do
        local tab = self["tab"..i]
        local tabPanel = self["tabPanel"..i]
        local selTab = self["selTab"..i]

        if idx == i then
            if tab then tab:setVisible(false) end
            if selTab then selTab:setVisible(true) end
            if tabPanel then tabPanel:setVisible(true) end
        else
            if tab then tab:setVisible(true) end
            if selTab then selTab:setVisible(false) end
            if tabPanel then tabPanel:setVisible(false) end
        end
    end
end

function TabBase:hideTab(idx)
    local tab = self["tab"..idx]
    local tabPanel = self["tabPanel"..idx]
    local selTab = self["selTab"..idx]

    print(idx, tab, tabPanel, selTab)

    if tab then tab:setVisible(false) end
    if tabPanel then tabPanel:setVisible(false) end
    if selTab then selTab:setVisible(false) end
end

return TabBase
