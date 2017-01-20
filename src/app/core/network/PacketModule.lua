
module("app.core.network.PacketModule", package.seeall)

require("luabuf")

local PacketModule = app.core.network.PacketModule

local SOCKET_HEADER_LENGTH=14

function PacketModule.buildPacket(iType,passportId,iBody)

    local headbuf=luabuf.iobuffer_new()
    
    local messageLength=SOCKET_HEADER_LENGTH+string.len(iBody)
    
    headbuf:iobuffer_write_int32(messageLength)
    
    headbuf:iobuffer_write_short(iType)
    
    headbuf:iobuffer_write_int64(passportId)
    
    local headstr=headbuf:iobuffer_str()
    
    local packet=headstr..iBody
    
    return packet
end


function PacketModule.subPacketBody(data)
    local body=string.sub(data,SOCKET_HEADER_LENGTH+1,string.len(data))
    return body
end

function PacketModule.subPacketHead(data)
    local body=string.sub(data,1,SOCKET_HEADER_LENGTH)
    return body
end

