/*
** Lua binding: FbxManager_luabinding
** Generated automatically by tolua++-1.0.92 on Mon Sep  1 14:59:33 2014.
*/

#include "FbxManager_luabinding.h"
#include "CCLuaEngine.h"

using namespace cocos2d;





/* function to register type */
static void tolua_reg_types (lua_State* tolua_S)
{
 tolua_usertype(tolua_S,"CCFbxManager"); toluafix_add_type_mapping(typeid(CCFbxManager).hash_code(), "CCFbxManager");
}

/* method: sharedCCFbxManager of class  CCFbxManager */
#ifndef TOLUA_DISABLE_tolua_FbxManager_luabinding_CCFbxManager_sharedCCFbxManager00
static int tolua_FbxManager_luabinding_CCFbxManager_sharedCCFbxManager00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"CCFbxManager",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  {
   CCFbxManager* tolua_ret = (CCFbxManager*)  CCFbxManager::sharedCCFbxManager();
    tolua_pushusertype(tolua_S,(void*)tolua_ret,"CCFbxManager");
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'sharedCCFbxManager'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: purgeSharedCCFbxManager of class  CCFbxManager */
#ifndef TOLUA_DISABLE_tolua_FbxManager_luabinding_CCFbxManager_purgeSharedCCFbxManager00
static int tolua_FbxManager_luabinding_CCFbxManager_purgeSharedCCFbxManager00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"CCFbxManager",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  {
   CCFbxManager::purgeSharedCCFbxManager();
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'purgeSharedCCFbxManager'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: convert of class  CCFbxManager */
#ifndef TOLUA_DISABLE_tolua_FbxManager_luabinding_CCFbxManager_convert00
static int tolua_FbxManager_luabinding_CCFbxManager_convert00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"CCFbxManager",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isstring(tolua_S,3,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,4,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  CCFbxManager* self = (CCFbxManager*)  tolua_tousertype(tolua_S,1,0);
  const char* fin = ((const char*)  tolua_tostring(tolua_S,2,0));
  const char* fout = ((const char*)  tolua_tostring(tolua_S,3,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'convert'", NULL);
#endif
  {
   bool tolua_ret = (bool)  self->convert(fin,fout);
   tolua_pushboolean(tolua_S,(bool)tolua_ret);
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'convert'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* Open function */
TOLUA_API int tolua_FbxManager_luabinding_open (lua_State* tolua_S)
{
 tolua_open(tolua_S);
 tolua_reg_types(tolua_S);
 tolua_module(tolua_S,NULL,0);
 tolua_beginmodule(tolua_S,NULL);
  tolua_cclass(tolua_S,"CCFbxManager","CCFbxManager","",NULL);
  tolua_beginmodule(tolua_S,"CCFbxManager");
   tolua_function(tolua_S,"sharedCCFbxManager",tolua_FbxManager_luabinding_CCFbxManager_sharedCCFbxManager00);
   tolua_function(tolua_S,"purgeSharedCCFbxManager",tolua_FbxManager_luabinding_CCFbxManager_purgeSharedCCFbxManager00);
   tolua_function(tolua_S,"convert",tolua_FbxManager_luabinding_CCFbxManager_convert00);
  tolua_endmodule(tolua_S);
 tolua_endmodule(tolua_S);
 return 1;
}


#if defined(LUA_VERSION_NUM) && LUA_VERSION_NUM >= 501
 TOLUA_API int luaopen_FbxManager_luabinding (lua_State* tolua_S) {
 return tolua_FbxManager_luabinding_open(tolua_S);
};
#endif

