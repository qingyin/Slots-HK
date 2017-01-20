local data = {}

data.serializeModel = require("app.data.SerializeModel")
data.ReportModel = require("app.data.ReportModel")
--data.user = require("app.data.User")
-- data.poker = require("app.data.poker.init")
data.slots = require("app.data.slots.init")
data.double = require("app.data.double.init")
-- data.blackjack = require("app.data.bj.init")
-- data.txspoker = require("app.data.txspoker.init")

require "app.data.dict.dict_vip"
require "app.data.dict.dict_level"
require "app.data.dict.dict_layout"
require "app.data.dict.dict_unit"
require "app.data.dict.dict_chip"
require "app.data.dict.dict_product_auth"
require "app.data.dict.dict_gift"
require "app.data.dict.dict_gift_menu"
require "app.data.dict.dict_notification"
require "app.data.dict.dict_daily_reward"
require "app.data.dict.dict_reward"
require "app.data.dict.dict_special_task"
require "app.data.dict.dict_facebook_feed"

require "app.data.DictUtil"

DICT_VIP    		=dict_vip
DICT_LEVEL  		=dict_level
DICT_LAYOUT			=dict_layout
DICT_UNIT 			=dict_unit
DICT_PRODUCT_AUTH   =dict_product_auth
DICT_PRODUCT_AUTH   =dict_product_auth
DICT_GIFT 	  		=dict_gift
DICT_GIFT_MENU  	=dict_gift_menu
DICT_DAILY_REWARD   =dict_daily_reward
DICT_REWARD         =dict_reward
DICT_SPECIAL_TASK   =dict_special_task
DICT_FACEBOOK_FEED  =dict_facebook_feed

return data
