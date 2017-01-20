scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
data = require("app.data.init")
scn = require("app.scenes.lobby.init")
EventMgr = require("app.event.EventManager").instance()
core = require("app.core.init")
net = require("app.interface.init")

SlotsMgr = require("app.scenes.slots.SlotsManager")
SymbolMgr = require("app.scenes.slots.SymbolManager")

AdMgr = require("app.scenes.Advertisement.AdvertisementManager")
headViewClass = require("app.scenes.common.HeadView")

require("app.lua_plugin")

-- luaoc = require(cc.PACKAGE_NAME .. ".luaoc")--require("cocos.cocos2d.luaoc")

require("app.res")
