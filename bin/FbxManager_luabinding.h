
#ifndef __FBXMANAGER_LUABINDING_H_
#define __FBXMANAGER_LUABINDING_H_

extern "C" {
#include "lua.h"
#include "tolua++.h"
#include "tolua_fix.h"
}

TOLUA_API int luaopen_FbxManager_luabinding(lua_State* tolua_S);

#endif // __FBXMANAGER_LUABINDING_H_
