-- Generated By protoc-gen-lua Do not Edit
local protobuf = require "protobuf"
module('Chat_pb')


local CGCHATMESSAGE = protobuf.Descriptor();
local CGCHATMESSAGE_PID_FIELD = protobuf.FieldDescriptor();
local CGCHATMESSAGE_TARGETPID_FIELD = protobuf.FieldDescriptor();
local CGCHATMESSAGE_TEAMID_FIELD = protobuf.FieldDescriptor();
local CGCHATMESSAGE_GUILDID_FIELD = protobuf.FieldDescriptor();
local CGCHATMESSAGE_CHATCHANNEL_FIELD = protobuf.FieldDescriptor();
local CGCHATMESSAGE_CONTENT_FIELD = protobuf.FieldDescriptor();
local GCCHATMESSAGE = protobuf.Descriptor();
local GCCHATMESSAGE_CONTENT_FIELD = protobuf.FieldDescriptor();
local GCCHATMESSAGE_PID_FIELD = protobuf.FieldDescriptor();
local GCCHATMESSAGE_SITEID_FIELD = protobuf.FieldDescriptor();

CGCHATMESSAGE_PID_FIELD.name = "pid"
CGCHATMESSAGE_PID_FIELD.full_name = ".com.zy.game.casino.message.CGChatMessage.pid"
CGCHATMESSAGE_PID_FIELD.number = 1
CGCHATMESSAGE_PID_FIELD.index = 0
CGCHATMESSAGE_PID_FIELD.label = 2
CGCHATMESSAGE_PID_FIELD.has_default_value = false
CGCHATMESSAGE_PID_FIELD.default_value = 0
CGCHATMESSAGE_PID_FIELD.type = 3
CGCHATMESSAGE_PID_FIELD.cpp_type = 2

CGCHATMESSAGE_TARGETPID_FIELD.name = "targetPid"
CGCHATMESSAGE_TARGETPID_FIELD.full_name = ".com.zy.game.casino.message.CGChatMessage.targetPid"
CGCHATMESSAGE_TARGETPID_FIELD.number = 2
CGCHATMESSAGE_TARGETPID_FIELD.index = 1
CGCHATMESSAGE_TARGETPID_FIELD.label = 1
CGCHATMESSAGE_TARGETPID_FIELD.has_default_value = true
CGCHATMESSAGE_TARGETPID_FIELD.default_value = 0
CGCHATMESSAGE_TARGETPID_FIELD.type = 3
CGCHATMESSAGE_TARGETPID_FIELD.cpp_type = 2

CGCHATMESSAGE_TEAMID_FIELD.name = "teamId"
CGCHATMESSAGE_TEAMID_FIELD.full_name = ".com.zy.game.casino.message.CGChatMessage.teamId"
CGCHATMESSAGE_TEAMID_FIELD.number = 3
CGCHATMESSAGE_TEAMID_FIELD.index = 2
CGCHATMESSAGE_TEAMID_FIELD.label = 1
CGCHATMESSAGE_TEAMID_FIELD.has_default_value = true
CGCHATMESSAGE_TEAMID_FIELD.default_value = 0
CGCHATMESSAGE_TEAMID_FIELD.type = 5
CGCHATMESSAGE_TEAMID_FIELD.cpp_type = 1

CGCHATMESSAGE_GUILDID_FIELD.name = "guildId"
CGCHATMESSAGE_GUILDID_FIELD.full_name = ".com.zy.game.casino.message.CGChatMessage.guildId"
CGCHATMESSAGE_GUILDID_FIELD.number = 4
CGCHATMESSAGE_GUILDID_FIELD.index = 3
CGCHATMESSAGE_GUILDID_FIELD.label = 1
CGCHATMESSAGE_GUILDID_FIELD.has_default_value = true
CGCHATMESSAGE_GUILDID_FIELD.default_value = 0
CGCHATMESSAGE_GUILDID_FIELD.type = 5
CGCHATMESSAGE_GUILDID_FIELD.cpp_type = 1

CGCHATMESSAGE_CHATCHANNEL_FIELD.name = "chatChannel"
CGCHATMESSAGE_CHATCHANNEL_FIELD.full_name = ".com.zy.game.casino.message.CGChatMessage.chatChannel"
CGCHATMESSAGE_CHATCHANNEL_FIELD.number = 5
CGCHATMESSAGE_CHATCHANNEL_FIELD.index = 4
CGCHATMESSAGE_CHATCHANNEL_FIELD.label = 2
CGCHATMESSAGE_CHATCHANNEL_FIELD.has_default_value = false
CGCHATMESSAGE_CHATCHANNEL_FIELD.default_value = 0
CGCHATMESSAGE_CHATCHANNEL_FIELD.type = 5
CGCHATMESSAGE_CHATCHANNEL_FIELD.cpp_type = 1

CGCHATMESSAGE_CONTENT_FIELD.name = "content"
CGCHATMESSAGE_CONTENT_FIELD.full_name = ".com.zy.game.casino.message.CGChatMessage.content"
CGCHATMESSAGE_CONTENT_FIELD.number = 6
CGCHATMESSAGE_CONTENT_FIELD.index = 5
CGCHATMESSAGE_CONTENT_FIELD.label = 2
CGCHATMESSAGE_CONTENT_FIELD.has_default_value = false
CGCHATMESSAGE_CONTENT_FIELD.default_value = ""
CGCHATMESSAGE_CONTENT_FIELD.type = 9
CGCHATMESSAGE_CONTENT_FIELD.cpp_type = 9

CGCHATMESSAGE.name = "CGChatMessage"
CGCHATMESSAGE.full_name = ".com.zy.game.casino.message.CGChatMessage"
CGCHATMESSAGE.nested_types = {}
CGCHATMESSAGE.enum_types = {}
CGCHATMESSAGE.fields = {CGCHATMESSAGE_PID_FIELD, CGCHATMESSAGE_TARGETPID_FIELD, CGCHATMESSAGE_TEAMID_FIELD, CGCHATMESSAGE_GUILDID_FIELD, CGCHATMESSAGE_CHATCHANNEL_FIELD, CGCHATMESSAGE_CONTENT_FIELD}
CGCHATMESSAGE.is_extendable = false
CGCHATMESSAGE.extensions = {}
GCCHATMESSAGE_CONTENT_FIELD.name = "content"
GCCHATMESSAGE_CONTENT_FIELD.full_name = ".com.zy.game.casino.message.GCChatMessage.content"
GCCHATMESSAGE_CONTENT_FIELD.number = 1
GCCHATMESSAGE_CONTENT_FIELD.index = 0
GCCHATMESSAGE_CONTENT_FIELD.label = 2
GCCHATMESSAGE_CONTENT_FIELD.has_default_value = false
GCCHATMESSAGE_CONTENT_FIELD.default_value = ""
GCCHATMESSAGE_CONTENT_FIELD.type = 9
GCCHATMESSAGE_CONTENT_FIELD.cpp_type = 9

GCCHATMESSAGE_PID_FIELD.name = "pid"
GCCHATMESSAGE_PID_FIELD.full_name = ".com.zy.game.casino.message.GCChatMessage.pid"
GCCHATMESSAGE_PID_FIELD.number = 2
GCCHATMESSAGE_PID_FIELD.index = 1
GCCHATMESSAGE_PID_FIELD.label = 1
GCCHATMESSAGE_PID_FIELD.has_default_value = false
GCCHATMESSAGE_PID_FIELD.default_value = 0
GCCHATMESSAGE_PID_FIELD.type = 3
GCCHATMESSAGE_PID_FIELD.cpp_type = 2

GCCHATMESSAGE_SITEID_FIELD.name = "siteId"
GCCHATMESSAGE_SITEID_FIELD.full_name = ".com.zy.game.casino.message.GCChatMessage.siteId"
GCCHATMESSAGE_SITEID_FIELD.number = 3
GCCHATMESSAGE_SITEID_FIELD.index = 2
GCCHATMESSAGE_SITEID_FIELD.label = 1
GCCHATMESSAGE_SITEID_FIELD.has_default_value = false
GCCHATMESSAGE_SITEID_FIELD.default_value = 0
GCCHATMESSAGE_SITEID_FIELD.type = 5
GCCHATMESSAGE_SITEID_FIELD.cpp_type = 1

GCCHATMESSAGE.name = "GCChatMessage"
GCCHATMESSAGE.full_name = ".com.zy.game.casino.message.GCChatMessage"
GCCHATMESSAGE.nested_types = {}
GCCHATMESSAGE.enum_types = {}
GCCHATMESSAGE.fields = {GCCHATMESSAGE_CONTENT_FIELD, GCCHATMESSAGE_PID_FIELD, GCCHATMESSAGE_SITEID_FIELD}
GCCHATMESSAGE.is_extendable = false
GCCHATMESSAGE.extensions = {}

CGChatMessage = protobuf.Message(CGCHATMESSAGE)
GCChatMessage = protobuf.Message(GCCHATMESSAGE)

