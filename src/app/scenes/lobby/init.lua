
-- init mvc
local scn = {}

scn.ScnMgr = require("app.core.SceneManager")
scn.models = require("app.scenes.lobby.models.init")
scn.cotors = require("app.scenes.lobby.controllers.init")

return scn
