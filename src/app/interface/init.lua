
local net = {}
require "app.interface.pb.Notify_pb"

net.UserAuthCS = import(".UserAuthCS")
net.UserCS = import(".UserCS")
net.FriendsCS = import(".FriendsCS")
net.GiftsCS = import(".GiftsCS")
net.MessageCS = import(".MessageCS")
net.PurchaseCS = import(".PurchaseCS")
net.GameCS = import(".GameCS")
net.TimingRewardCS = import(".TimingRewardCS")
net.DailyLoginCS = import(".DailyLoginCS")
net.ChatCS = import(".ChatCS")
net.HonorCS = import(".HonorCS")

return net
