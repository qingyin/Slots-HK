
require "app.interface.pb.Friend_pb"
require "app.interface.pb.CasinoMessageType"

local FriendsCS = {}


function FriendsCS:getAllFriends(giftType, callfunction)
   
    local function callBack(rdata)
        core.Waiting.hide()
        
        local msg = Friend_pb.GCGetFriendList()
        msg:ParseFromString(rdata)

        callfunction(msg.friendList)

    end

    local pid = app:getUserModel():getCurrentPid()

    local req= Friend_pb.CGGetFriendList()

    req.pid  = pid
    req.giftType = giftType

    core.SocketNet:sendCommonProtoMessage(CG_GET_FRIEND_LIST,GC_GET_FRIEND_LIST, pid,req, callBack, true)

end

function FriendsCS:addFacebookFriends(fbids, callfunction)

    local function callBack(rdata)
        core.Waiting.hide()

        local msg = Friend_pb.GCAddFacebookFriends()
        msg:ParseFromString(rdata)

        callfunction(msg)

    end

    --local pid = app:getUserModel():getCurrentPid()

    local pid = app:getUserModel():getFBPid()

    local req= Friend_pb.CGAddFacebookFriends()

    req.pid  = pid
    req.facebookIds  = fbids

    core.SocketNet:sendCommonProtoMessage(CG_ADD_FACEBOOK_FRIENDS,GC_ADD_FACEBOOK_FRIENDS, pid,req, callBack, true)

end

return FriendsCS
