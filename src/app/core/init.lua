require "app.core.util.TableUtil"

require("app.core.ext.putsTable")

-- init core
local core = {}

core.Assets = import(".Assets")
core.displayEX = import(".displayEX")

if device.platform == "ios" then
core.Purchase = require("app.core.store.Purchase").new()
elseif device.platform == "android" then
core.Purchase = require("app.core.store.PurchaseGooglePlay").new()
end
core.HttpNet = import(".network.HttpNetModule")
core.NetPacket = import(".network.PacketModule")
core.SocketNet = require("app.core.network.SocketNetModule").new()
core.Sqlite = require("app.core.Sqlite")
core.Waiting = require("app.core.Waiting")
core.FBPlatform = require("app.core.FBPlatform")

import(".util.AnimationUtil")

return core
