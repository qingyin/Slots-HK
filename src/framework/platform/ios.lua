
if cc.bPlugin_ then
	-- by mey
	-- luaoc = require("cocos.cocos2d.luaoc")
	luaoc = require("luaoc")
	-- luaoc = require("app.luaoc")
else
	luaoc = require(cc.PACKAGE_NAME .. ".luaoc")
end

function device.showAlertIOS(title, message, buttonLabels, listener)
end
