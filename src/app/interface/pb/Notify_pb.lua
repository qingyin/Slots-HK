-- Generated By protoc-gen-lua Do not Edit
local protobuf = require "protobuf"
module('Notify_pb')


local CGGETMESSAGELIST = protobuf.Descriptor();
local CGGETMESSAGELIST_PID_FIELD = protobuf.FieldDescriptor();
local GCMESSAGE = protobuf.Descriptor();
local GCMESSAGE_ID_FIELD = protobuf.FieldDescriptor();
local GCMESSAGE_TYPE_FIELD = protobuf.FieldDescriptor();
local GCMESSAGE_TITLE_FIELD = protobuf.FieldDescriptor();
local GCMESSAGE_SHORTCONTENT_FIELD = protobuf.FieldDescriptor();
local GCMESSAGE_CONTENT_FIELD = protobuf.FieldDescriptor();
local GCMESSAGE_STATE_FIELD = protobuf.FieldDescriptor();
local GCMESSAGE_PICTURE_FIELD = protobuf.FieldDescriptor();
local GCMESSAGE_ITEMID_FIELD = protobuf.FieldDescriptor();
local GCMESSAGE_ITEMCNT_FIELD = protobuf.FieldDescriptor();
local GCMESSAGE_FACEBOOKID_FIELD = protobuf.FieldDescriptor();
local GCGETMESSAGELIST = protobuf.Descriptor();
local GCGETMESSAGELIST_MSGLIST_FIELD = protobuf.FieldDescriptor();
local GCGETMESSAGELIST_NEWFLAG_FIELD = protobuf.FieldDescriptor();
local GCMSGNOTIFY = protobuf.Descriptor();
local GCMSGNOTIFY_MSGTYPE_FIELD = protobuf.FieldDescriptor();
local CGRECEIVEMSG = protobuf.Descriptor();
local CGRECEIVEMSG_ID_FIELD = protobuf.FieldDescriptor();
local CGRECEIVEMSG_RESULT_FIELD = protobuf.FieldDescriptor();
local GCRECEIVEMSG = protobuf.Descriptor();
local GCRECEIVEMSG_RESULT_FIELD = protobuf.FieldDescriptor();
local GCRECEIVEMSG_REWARDCOINS_FIELD = protobuf.FieldDescriptor();
local GCRECEIVEMSG_REWARDGEMS_FIELD = protobuf.FieldDescriptor();

CGGETMESSAGELIST_PID_FIELD.name = "pid"
CGGETMESSAGELIST_PID_FIELD.full_name = ".com.zy.game.casino.message.CGGetMessageList.pid"
CGGETMESSAGELIST_PID_FIELD.number = 1
CGGETMESSAGELIST_PID_FIELD.index = 0
CGGETMESSAGELIST_PID_FIELD.label = 2
CGGETMESSAGELIST_PID_FIELD.has_default_value = false
CGGETMESSAGELIST_PID_FIELD.default_value = 0
CGGETMESSAGELIST_PID_FIELD.type = 3
CGGETMESSAGELIST_PID_FIELD.cpp_type = 2

CGGETMESSAGELIST.name = "CGGetMessageList"
CGGETMESSAGELIST.full_name = ".com.zy.game.casino.message.CGGetMessageList"
CGGETMESSAGELIST.nested_types = {}
CGGETMESSAGELIST.enum_types = {}
CGGETMESSAGELIST.fields = {CGGETMESSAGELIST_PID_FIELD}
CGGETMESSAGELIST.is_extendable = false
CGGETMESSAGELIST.extensions = {}
GCMESSAGE_ID_FIELD.name = "id"
GCMESSAGE_ID_FIELD.full_name = ".com.zy.game.casino.message.GCMessage.id"
GCMESSAGE_ID_FIELD.number = 1
GCMESSAGE_ID_FIELD.index = 0
GCMESSAGE_ID_FIELD.label = 2
GCMESSAGE_ID_FIELD.has_default_value = false
GCMESSAGE_ID_FIELD.default_value = 0
GCMESSAGE_ID_FIELD.type = 3
GCMESSAGE_ID_FIELD.cpp_type = 2

GCMESSAGE_TYPE_FIELD.name = "type"
GCMESSAGE_TYPE_FIELD.full_name = ".com.zy.game.casino.message.GCMessage.type"
GCMESSAGE_TYPE_FIELD.number = 2
GCMESSAGE_TYPE_FIELD.index = 1
GCMESSAGE_TYPE_FIELD.label = 2
GCMESSAGE_TYPE_FIELD.has_default_value = false
GCMESSAGE_TYPE_FIELD.default_value = 0
GCMESSAGE_TYPE_FIELD.type = 5
GCMESSAGE_TYPE_FIELD.cpp_type = 1

GCMESSAGE_TITLE_FIELD.name = "title"
GCMESSAGE_TITLE_FIELD.full_name = ".com.zy.game.casino.message.GCMessage.title"
GCMESSAGE_TITLE_FIELD.number = 3
GCMESSAGE_TITLE_FIELD.index = 2
GCMESSAGE_TITLE_FIELD.label = 2
GCMESSAGE_TITLE_FIELD.has_default_value = false
GCMESSAGE_TITLE_FIELD.default_value = ""
GCMESSAGE_TITLE_FIELD.type = 9
GCMESSAGE_TITLE_FIELD.cpp_type = 9

GCMESSAGE_SHORTCONTENT_FIELD.name = "shortContent"
GCMESSAGE_SHORTCONTENT_FIELD.full_name = ".com.zy.game.casino.message.GCMessage.shortContent"
GCMESSAGE_SHORTCONTENT_FIELD.number = 4
GCMESSAGE_SHORTCONTENT_FIELD.index = 3
GCMESSAGE_SHORTCONTENT_FIELD.label = 1
GCMESSAGE_SHORTCONTENT_FIELD.has_default_value = false
GCMESSAGE_SHORTCONTENT_FIELD.default_value = ""
GCMESSAGE_SHORTCONTENT_FIELD.type = 9
GCMESSAGE_SHORTCONTENT_FIELD.cpp_type = 9

GCMESSAGE_CONTENT_FIELD.name = "content"
GCMESSAGE_CONTENT_FIELD.full_name = ".com.zy.game.casino.message.GCMessage.content"
GCMESSAGE_CONTENT_FIELD.number = 5
GCMESSAGE_CONTENT_FIELD.index = 4
GCMESSAGE_CONTENT_FIELD.label = 1
GCMESSAGE_CONTENT_FIELD.has_default_value = false
GCMESSAGE_CONTENT_FIELD.default_value = ""
GCMESSAGE_CONTENT_FIELD.type = 9
GCMESSAGE_CONTENT_FIELD.cpp_type = 9

GCMESSAGE_STATE_FIELD.name = "state"
GCMESSAGE_STATE_FIELD.full_name = ".com.zy.game.casino.message.GCMessage.state"
GCMESSAGE_STATE_FIELD.number = 6
GCMESSAGE_STATE_FIELD.index = 5
GCMESSAGE_STATE_FIELD.label = 2
GCMESSAGE_STATE_FIELD.has_default_value = false
GCMESSAGE_STATE_FIELD.default_value = 0
GCMESSAGE_STATE_FIELD.type = 5
GCMESSAGE_STATE_FIELD.cpp_type = 1

GCMESSAGE_PICTURE_FIELD.name = "picture"
GCMESSAGE_PICTURE_FIELD.full_name = ".com.zy.game.casino.message.GCMessage.picture"
GCMESSAGE_PICTURE_FIELD.number = 7
GCMESSAGE_PICTURE_FIELD.index = 6
GCMESSAGE_PICTURE_FIELD.label = 1
GCMESSAGE_PICTURE_FIELD.has_default_value = false
GCMESSAGE_PICTURE_FIELD.default_value = ""
GCMESSAGE_PICTURE_FIELD.type = 9
GCMESSAGE_PICTURE_FIELD.cpp_type = 9

GCMESSAGE_ITEMID_FIELD.name = "itemId"
GCMESSAGE_ITEMID_FIELD.full_name = ".com.zy.game.casino.message.GCMessage.itemId"
GCMESSAGE_ITEMID_FIELD.number = 8
GCMESSAGE_ITEMID_FIELD.index = 7
GCMESSAGE_ITEMID_FIELD.label = 1
GCMESSAGE_ITEMID_FIELD.has_default_value = false
GCMESSAGE_ITEMID_FIELD.default_value = 0
GCMESSAGE_ITEMID_FIELD.type = 5
GCMESSAGE_ITEMID_FIELD.cpp_type = 1

GCMESSAGE_ITEMCNT_FIELD.name = "itemCnt"
GCMESSAGE_ITEMCNT_FIELD.full_name = ".com.zy.game.casino.message.GCMessage.itemCnt"
GCMESSAGE_ITEMCNT_FIELD.number = 9
GCMESSAGE_ITEMCNT_FIELD.index = 8
GCMESSAGE_ITEMCNT_FIELD.label = 1
GCMESSAGE_ITEMCNT_FIELD.has_default_value = false
GCMESSAGE_ITEMCNT_FIELD.default_value = 0
GCMESSAGE_ITEMCNT_FIELD.type = 5
GCMESSAGE_ITEMCNT_FIELD.cpp_type = 1

GCMESSAGE_FACEBOOKID_FIELD.name = "facebookId"
GCMESSAGE_FACEBOOKID_FIELD.full_name = ".com.zy.game.casino.message.GCMessage.facebookId"
GCMESSAGE_FACEBOOKID_FIELD.number = 10
GCMESSAGE_FACEBOOKID_FIELD.index = 9
GCMESSAGE_FACEBOOKID_FIELD.label = 1
GCMESSAGE_FACEBOOKID_FIELD.has_default_value = false
GCMESSAGE_FACEBOOKID_FIELD.default_value = ""
GCMESSAGE_FACEBOOKID_FIELD.type = 9
GCMESSAGE_FACEBOOKID_FIELD.cpp_type = 9

GCMESSAGE.name = "GCMessage"
GCMESSAGE.full_name = ".com.zy.game.casino.message.GCMessage"
GCMESSAGE.nested_types = {}
GCMESSAGE.enum_types = {}
GCMESSAGE.fields = {GCMESSAGE_ID_FIELD, GCMESSAGE_TYPE_FIELD, GCMESSAGE_TITLE_FIELD, GCMESSAGE_SHORTCONTENT_FIELD, GCMESSAGE_CONTENT_FIELD, GCMESSAGE_STATE_FIELD, GCMESSAGE_PICTURE_FIELD, GCMESSAGE_ITEMID_FIELD, GCMESSAGE_ITEMCNT_FIELD, GCMESSAGE_FACEBOOKID_FIELD}
GCMESSAGE.is_extendable = false
GCMESSAGE.extensions = {}
GCGETMESSAGELIST_MSGLIST_FIELD.name = "msgList"
GCGETMESSAGELIST_MSGLIST_FIELD.full_name = ".com.zy.game.casino.message.GCGetMessageList.msgList"
GCGETMESSAGELIST_MSGLIST_FIELD.number = 1
GCGETMESSAGELIST_MSGLIST_FIELD.index = 0
GCGETMESSAGELIST_MSGLIST_FIELD.label = 3
GCGETMESSAGELIST_MSGLIST_FIELD.has_default_value = false
GCGETMESSAGELIST_MSGLIST_FIELD.default_value = {}
GCGETMESSAGELIST_MSGLIST_FIELD.message_type = GCMESSAGE
GCGETMESSAGELIST_MSGLIST_FIELD.type = 11
GCGETMESSAGELIST_MSGLIST_FIELD.cpp_type = 10

GCGETMESSAGELIST_NEWFLAG_FIELD.name = "newFlag"
GCGETMESSAGELIST_NEWFLAG_FIELD.full_name = ".com.zy.game.casino.message.GCGetMessageList.newFlag"
GCGETMESSAGELIST_NEWFLAG_FIELD.number = 2
GCGETMESSAGELIST_NEWFLAG_FIELD.index = 1
GCGETMESSAGELIST_NEWFLAG_FIELD.label = 2
GCGETMESSAGELIST_NEWFLAG_FIELD.has_default_value = false
GCGETMESSAGELIST_NEWFLAG_FIELD.default_value = false
GCGETMESSAGELIST_NEWFLAG_FIELD.type = 8
GCGETMESSAGELIST_NEWFLAG_FIELD.cpp_type = 7

GCGETMESSAGELIST.name = "GCGetMessageList"
GCGETMESSAGELIST.full_name = ".com.zy.game.casino.message.GCGetMessageList"
GCGETMESSAGELIST.nested_types = {}
GCGETMESSAGELIST.enum_types = {}
GCGETMESSAGELIST.fields = {GCGETMESSAGELIST_MSGLIST_FIELD, GCGETMESSAGELIST_NEWFLAG_FIELD}
GCGETMESSAGELIST.is_extendable = false
GCGETMESSAGELIST.extensions = {}
GCMSGNOTIFY_MSGTYPE_FIELD.name = "msgType"
GCMSGNOTIFY_MSGTYPE_FIELD.full_name = ".com.zy.game.casino.message.GCMsgNotify.msgType"
GCMSGNOTIFY_MSGTYPE_FIELD.number = 1
GCMSGNOTIFY_MSGTYPE_FIELD.index = 0
GCMSGNOTIFY_MSGTYPE_FIELD.label = 2
GCMSGNOTIFY_MSGTYPE_FIELD.has_default_value = false
GCMSGNOTIFY_MSGTYPE_FIELD.default_value = 0
GCMSGNOTIFY_MSGTYPE_FIELD.type = 5
GCMSGNOTIFY_MSGTYPE_FIELD.cpp_type = 1

GCMSGNOTIFY.name = "GCMsgNotify"
GCMSGNOTIFY.full_name = ".com.zy.game.casino.message.GCMsgNotify"
GCMSGNOTIFY.nested_types = {}
GCMSGNOTIFY.enum_types = {}
GCMSGNOTIFY.fields = {GCMSGNOTIFY_MSGTYPE_FIELD}
GCMSGNOTIFY.is_extendable = false
GCMSGNOTIFY.extensions = {}
CGRECEIVEMSG_ID_FIELD.name = "id"
CGRECEIVEMSG_ID_FIELD.full_name = ".com.zy.game.casino.message.CGReceiveMsg.id"
CGRECEIVEMSG_ID_FIELD.number = 1
CGRECEIVEMSG_ID_FIELD.index = 0
CGRECEIVEMSG_ID_FIELD.label = 2
CGRECEIVEMSG_ID_FIELD.has_default_value = false
CGRECEIVEMSG_ID_FIELD.default_value = 0
CGRECEIVEMSG_ID_FIELD.type = 3
CGRECEIVEMSG_ID_FIELD.cpp_type = 2

CGRECEIVEMSG_RESULT_FIELD.name = "result"
CGRECEIVEMSG_RESULT_FIELD.full_name = ".com.zy.game.casino.message.CGReceiveMsg.result"
CGRECEIVEMSG_RESULT_FIELD.number = 2
CGRECEIVEMSG_RESULT_FIELD.index = 1
CGRECEIVEMSG_RESULT_FIELD.label = 2
CGRECEIVEMSG_RESULT_FIELD.has_default_value = false
CGRECEIVEMSG_RESULT_FIELD.default_value = 0
CGRECEIVEMSG_RESULT_FIELD.type = 5
CGRECEIVEMSG_RESULT_FIELD.cpp_type = 1

CGRECEIVEMSG.name = "CGReceiveMsg"
CGRECEIVEMSG.full_name = ".com.zy.game.casino.message.CGReceiveMsg"
CGRECEIVEMSG.nested_types = {}
CGRECEIVEMSG.enum_types = {}
CGRECEIVEMSG.fields = {CGRECEIVEMSG_ID_FIELD, CGRECEIVEMSG_RESULT_FIELD}
CGRECEIVEMSG.is_extendable = false
CGRECEIVEMSG.extensions = {}
GCRECEIVEMSG_RESULT_FIELD.name = "result"
GCRECEIVEMSG_RESULT_FIELD.full_name = ".com.zy.game.casino.message.GCReceiveMsg.result"
GCRECEIVEMSG_RESULT_FIELD.number = 1
GCRECEIVEMSG_RESULT_FIELD.index = 0
GCRECEIVEMSG_RESULT_FIELD.label = 2
GCRECEIVEMSG_RESULT_FIELD.has_default_value = false
GCRECEIVEMSG_RESULT_FIELD.default_value = 0
GCRECEIVEMSG_RESULT_FIELD.type = 5
GCRECEIVEMSG_RESULT_FIELD.cpp_type = 1

GCRECEIVEMSG_REWARDCOINS_FIELD.name = "rewardCoins"
GCRECEIVEMSG_REWARDCOINS_FIELD.full_name = ".com.zy.game.casino.message.GCReceiveMsg.rewardCoins"
GCRECEIVEMSG_REWARDCOINS_FIELD.number = 2
GCRECEIVEMSG_REWARDCOINS_FIELD.index = 1
GCRECEIVEMSG_REWARDCOINS_FIELD.label = 1
GCRECEIVEMSG_REWARDCOINS_FIELD.has_default_value = false
GCRECEIVEMSG_REWARDCOINS_FIELD.default_value = 0
GCRECEIVEMSG_REWARDCOINS_FIELD.type = 3
GCRECEIVEMSG_REWARDCOINS_FIELD.cpp_type = 2

GCRECEIVEMSG_REWARDGEMS_FIELD.name = "rewardGems"
GCRECEIVEMSG_REWARDGEMS_FIELD.full_name = ".com.zy.game.casino.message.GCReceiveMsg.rewardGems"
GCRECEIVEMSG_REWARDGEMS_FIELD.number = 3
GCRECEIVEMSG_REWARDGEMS_FIELD.index = 2
GCRECEIVEMSG_REWARDGEMS_FIELD.label = 1
GCRECEIVEMSG_REWARDGEMS_FIELD.has_default_value = false
GCRECEIVEMSG_REWARDGEMS_FIELD.default_value = 0
GCRECEIVEMSG_REWARDGEMS_FIELD.type = 3
GCRECEIVEMSG_REWARDGEMS_FIELD.cpp_type = 2

GCRECEIVEMSG.name = "GCReceiveMsg"
GCRECEIVEMSG.full_name = ".com.zy.game.casino.message.GCReceiveMsg"
GCRECEIVEMSG.nested_types = {}
GCRECEIVEMSG.enum_types = {}
GCRECEIVEMSG.fields = {GCRECEIVEMSG_RESULT_FIELD, GCRECEIVEMSG_REWARDCOINS_FIELD, GCRECEIVEMSG_REWARDGEMS_FIELD}
GCRECEIVEMSG.is_extendable = false
GCRECEIVEMSG.extensions = {}

CGGetMessageList = protobuf.Message(CGGETMESSAGELIST)
CGReceiveMsg = protobuf.Message(CGRECEIVEMSG)
GCGetMessageList = protobuf.Message(GCGETMESSAGELIST)
GCMessage = protobuf.Message(GCMESSAGE)
GCMsgNotify = protobuf.Message(GCMSGNOTIFY)
GCReceiveMsg = protobuf.Message(GCRECEIVEMSG)

