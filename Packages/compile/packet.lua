--!native
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ByteNet = require(ReplicatedStorage.Packages.ByteNet)

return ByteNet.defineNamespace("messaging", function()
	return {
		ExposeChoice = ByteNet.definePacket({
			value = ByteNet.struct({
				ChoiceMessage = ByteNet.string,
				Choices = ByteNet.unknown,
			}),
		}),
		ExposeMessage = ByteNet.definePacket({
			value = ByteNet.struct({
				Head = ByteNet.string,
				Body = ByteNet.string,
			}),
		}),
		ChoiceChosen = ByteNet.definePacket({
			value = ByteNet.struct({
				UUID = ByteNet.string,
			}),
		}),
		CloseDialogue = ByteNet.definePacket({
			value = ByteNet.struct({}),
		}),

		FinishedMessage = ByteNet.definePacket({
			value = ByteNet.struct({}),
		}),
	}
end)
