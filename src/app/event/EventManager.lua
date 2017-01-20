local EventManager = class("EventManager")

EventManager.SPIN_SLOTSGAME_EVENT         = "SPIN_SLOTSGAME_EVENT"
EventManager.SERVER_NOTICE_EVENT          = "SERVER_NOTICE_EVENT"
EventManager.SOCKET_CONNECT_EVENT         = "SOCKET_CONNECT_EVENT"
EventManager.UPDATE_PLAYERS_EVENT         = "UPDATE_PLAYERS_EVENT"
EventManager.UPDATE_FRIENDS_EVENT         = "UPDATE_FRIENDS_EVENT"
EventManager.UPDATE_PSTATES_EVENT         = "UPDATE_PSTATES_EVENT"
EventManager.UPDATE_LOBBYUI_EVENT         = "UPDATE_LOBBYUI_EVENT"
EventManager.SEND_MESSAGE_EVENT			  = "SEND_MESSAGE_EVENT"
EventManager.STOP_LINEEFF_EVENT			  = "STOP_LINEEFF_EVENT"
EventManager.UPDATE_TOPBACK_EVENT         = "UPDATE_TOPBACK_EVENT"
EventManager.UPDATE_BACKHOME_EVENT        = "UPDATE_BACKHOME_EVENT"
EventManager.UPDATE_TOPFB_EVENT           = "UPDATE_TOPFB_EVENT"
EventManager.PURCHASE_PBSUCCEED_EVENT     = "PURCHASE_PBSUCCEED_EVENT"
EventManager.PURCHASE_PBFAILED_EVENT      = "PURCHASE_PBFAILED_EVENT"
EventManager.UPDATE_TOP_DEAL_EVENT        = "UPDATE_TOP_DEAL_EVENT"
EventManager.OFFLINE_STOP_SUTOSPIN        = "OFFLINE_STOP_SUTOSPIN"
EventManager.UPDATE_PRODUCT_LIST          = "UPDATE_PRODUCT_LIST"


EventManager.ENTER_GAME = 1
EventManager.EXIT_GAME  = 2
EventManager.ENTER_BACKGROUND = 3
EventManager.ENTER_FOREGROUND = 4

EventManager.INTER_MACHINE = 1000
EventManager.EXIT_MACHINE  = 2000

function EventManager.instance()
    return EventManager.new()
end

function EventManager:ctor()
	cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
end

function EventManager:exit()
    self:getComponent("components.behavior.EventProtocol"):dumpAllEventListeners()
end

return EventManager