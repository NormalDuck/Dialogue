local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Dialogue = require(ReplicatedStorage.Packages.compile)

local Packet = require(ReplicatedStorage.Shared.packet)

Packet.Test.listen(function(data)
	task.defer(function()
		print(data)
	end)
end)
--the lag was due to the printing not the 
ReplicatedStorage.RemoteEvent.OnClientEvent:Connect(function(data)
	task.defer(function()
		print(data)
	end)
end)
