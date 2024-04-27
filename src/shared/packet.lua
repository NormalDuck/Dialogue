local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ByteNet = require(ReplicatedStorage.Packages.ByteNet)

local Packet = ByteNet.defineNamespace("test", function()
	return {
		Test = ByteNet.definePacket({
			value = ByteNet.struct({
				Thingy = ByteNet.string,
			}),
		}),
	}
end)
return Packet
