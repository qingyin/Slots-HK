-- Generated By protoc-gen-lua Do not Edit
local protobuf = require "protobuf"
module('Game_pb')


local CGGETGAMESTAT = protobuf.Descriptor();
local CGGETGAMESTAT_PID_FIELD = protobuf.FieldDescriptor();
local GCGAMESTAT = protobuf.Descriptor();
local GCGAMESTAT_PID_FIELD = protobuf.FieldDescriptor();
local GCGAMESTAT_GAMEID_FIELD = protobuf.FieldDescriptor();
local GCGAMESTAT_GAMECNT_FIELD = protobuf.FieldDescriptor();
local GCGAMESTAT_WINCNT_FIELD = protobuf.FieldDescriptor();
local GCGAMESTAT_TOTALBET_FIELD = protobuf.FieldDescriptor();
local GCGAMESTAT_TOTALWIN_FIELD = protobuf.FieldDescriptor();
local GCGAMESTAT_MAXWIN_FIELD = protobuf.FieldDescriptor();
local GCGETGAMESTAT = protobuf.Descriptor();
local GCGETGAMESTAT_GAMESTAT_FIELD = protobuf.FieldDescriptor();

CGGETGAMESTAT_PID_FIELD.name = "pid"
CGGETGAMESTAT_PID_FIELD.full_name = ".com.zy.game.casino.message.CGGetGameStat.pid"
CGGETGAMESTAT_PID_FIELD.number = 1
CGGETGAMESTAT_PID_FIELD.index = 0
CGGETGAMESTAT_PID_FIELD.label = 2
CGGETGAMESTAT_PID_FIELD.has_default_value = false
CGGETGAMESTAT_PID_FIELD.default_value = 0
CGGETGAMESTAT_PID_FIELD.type = 3
CGGETGAMESTAT_PID_FIELD.cpp_type = 2

CGGETGAMESTAT.name = "CGGetGameStat"
CGGETGAMESTAT.full_name = ".com.zy.game.casino.message.CGGetGameStat"
CGGETGAMESTAT.nested_types = {}
CGGETGAMESTAT.enum_types = {}
CGGETGAMESTAT.fields = {CGGETGAMESTAT_PID_FIELD}
CGGETGAMESTAT.is_extendable = false
CGGETGAMESTAT.extensions = {}
GCGAMESTAT_PID_FIELD.name = "pid"
GCGAMESTAT_PID_FIELD.full_name = ".com.zy.game.casino.message.GCGameStat.pid"
GCGAMESTAT_PID_FIELD.number = 1
GCGAMESTAT_PID_FIELD.index = 0
GCGAMESTAT_PID_FIELD.label = 2
GCGAMESTAT_PID_FIELD.has_default_value = false
GCGAMESTAT_PID_FIELD.default_value = 0
GCGAMESTAT_PID_FIELD.type = 3
GCGAMESTAT_PID_FIELD.cpp_type = 2

GCGAMESTAT_GAMEID_FIELD.name = "gameId"
GCGAMESTAT_GAMEID_FIELD.full_name = ".com.zy.game.casino.message.GCGameStat.gameId"
GCGAMESTAT_GAMEID_FIELD.number = 2
GCGAMESTAT_GAMEID_FIELD.index = 1
GCGAMESTAT_GAMEID_FIELD.label = 2
GCGAMESTAT_GAMEID_FIELD.has_default_value = false
GCGAMESTAT_GAMEID_FIELD.default_value = 0
GCGAMESTAT_GAMEID_FIELD.type = 5
GCGAMESTAT_GAMEID_FIELD.cpp_type = 1

GCGAMESTAT_GAMECNT_FIELD.name = "gameCnt"
GCGAMESTAT_GAMECNT_FIELD.full_name = ".com.zy.game.casino.message.GCGameStat.gameCnt"
GCGAMESTAT_GAMECNT_FIELD.number = 3
GCGAMESTAT_GAMECNT_FIELD.index = 2
GCGAMESTAT_GAMECNT_FIELD.label = 1
GCGAMESTAT_GAMECNT_FIELD.has_default_value = false
GCGAMESTAT_GAMECNT_FIELD.default_value = 0
GCGAMESTAT_GAMECNT_FIELD.type = 3
GCGAMESTAT_GAMECNT_FIELD.cpp_type = 2

GCGAMESTAT_WINCNT_FIELD.name = "winCnt"
GCGAMESTAT_WINCNT_FIELD.full_name = ".com.zy.game.casino.message.GCGameStat.winCnt"
GCGAMESTAT_WINCNT_FIELD.number = 4
GCGAMESTAT_WINCNT_FIELD.index = 3
GCGAMESTAT_WINCNT_FIELD.label = 1
GCGAMESTAT_WINCNT_FIELD.has_default_value = false
GCGAMESTAT_WINCNT_FIELD.default_value = 0
GCGAMESTAT_WINCNT_FIELD.type = 3
GCGAMESTAT_WINCNT_FIELD.cpp_type = 2

GCGAMESTAT_TOTALBET_FIELD.name = "totalBet"
GCGAMESTAT_TOTALBET_FIELD.full_name = ".com.zy.game.casino.message.GCGameStat.totalBet"
GCGAMESTAT_TOTALBET_FIELD.number = 5
GCGAMESTAT_TOTALBET_FIELD.index = 4
GCGAMESTAT_TOTALBET_FIELD.label = 1
GCGAMESTAT_TOTALBET_FIELD.has_default_value = false
GCGAMESTAT_TOTALBET_FIELD.default_value = 0
GCGAMESTAT_TOTALBET_FIELD.type = 3
GCGAMESTAT_TOTALBET_FIELD.cpp_type = 2

GCGAMESTAT_TOTALWIN_FIELD.name = "totalWin"
GCGAMESTAT_TOTALWIN_FIELD.full_name = ".com.zy.game.casino.message.GCGameStat.totalWin"
GCGAMESTAT_TOTALWIN_FIELD.number = 6
GCGAMESTAT_TOTALWIN_FIELD.index = 5
GCGAMESTAT_TOTALWIN_FIELD.label = 1
GCGAMESTAT_TOTALWIN_FIELD.has_default_value = false
GCGAMESTAT_TOTALWIN_FIELD.default_value = 0
GCGAMESTAT_TOTALWIN_FIELD.type = 3
GCGAMESTAT_TOTALWIN_FIELD.cpp_type = 2

GCGAMESTAT_MAXWIN_FIELD.name = "maxWin"
GCGAMESTAT_MAXWIN_FIELD.full_name = ".com.zy.game.casino.message.GCGameStat.maxWin"
GCGAMESTAT_MAXWIN_FIELD.number = 7
GCGAMESTAT_MAXWIN_FIELD.index = 6
GCGAMESTAT_MAXWIN_FIELD.label = 1
GCGAMESTAT_MAXWIN_FIELD.has_default_value = false
GCGAMESTAT_MAXWIN_FIELD.default_value = 0
GCGAMESTAT_MAXWIN_FIELD.type = 3
GCGAMESTAT_MAXWIN_FIELD.cpp_type = 2

GCGAMESTAT.name = "GCGameStat"
GCGAMESTAT.full_name = ".com.zy.game.casino.message.GCGameStat"
GCGAMESTAT.nested_types = {}
GCGAMESTAT.enum_types = {}
GCGAMESTAT.fields = {GCGAMESTAT_PID_FIELD, GCGAMESTAT_GAMEID_FIELD, GCGAMESTAT_GAMECNT_FIELD, GCGAMESTAT_WINCNT_FIELD, GCGAMESTAT_TOTALBET_FIELD, GCGAMESTAT_TOTALWIN_FIELD, GCGAMESTAT_MAXWIN_FIELD}
GCGAMESTAT.is_extendable = false
GCGAMESTAT.extensions = {}
GCGETGAMESTAT_GAMESTAT_FIELD.name = "gameStat"
GCGETGAMESTAT_GAMESTAT_FIELD.full_name = ".com.zy.game.casino.message.GCGetGameStat.gameStat"
GCGETGAMESTAT_GAMESTAT_FIELD.number = 1
GCGETGAMESTAT_GAMESTAT_FIELD.index = 0
GCGETGAMESTAT_GAMESTAT_FIELD.label = 3
GCGETGAMESTAT_GAMESTAT_FIELD.has_default_value = false
GCGETGAMESTAT_GAMESTAT_FIELD.default_value = {}
GCGETGAMESTAT_GAMESTAT_FIELD.message_type = GCGAMESTAT
GCGETGAMESTAT_GAMESTAT_FIELD.type = 11
GCGETGAMESTAT_GAMESTAT_FIELD.cpp_type = 10

GCGETGAMESTAT.name = "GCGetGameStat"
GCGETGAMESTAT.full_name = ".com.zy.game.casino.message.GCGetGameStat"
GCGETGAMESTAT.nested_types = {}
GCGETGAMESTAT.enum_types = {}
GCGETGAMESTAT.fields = {GCGETGAMESTAT_GAMESTAT_FIELD}
GCGETGAMESTAT.is_extendable = false
GCGETGAMESTAT.extensions = {}

CGGetGameStat = protobuf.Message(CGGETGAMESTAT)
GCGameStat = protobuf.Message(GCGAMESTAT)
GCGetGameStat = protobuf.Message(GCGETGAMESTAT)
