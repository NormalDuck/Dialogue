--!native
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ByteNet = require(ReplicatedStorage.Packages.ByteNet)

return ByteNet.defineNamespace("messaging", function()
	return {
		ExposeChoice = ByteNet.definePacket({
			value = ByteNet.struct({
				ChoiceMessage = ByteNet.string,
				Choices = ByteNet.array
			}),
		}),
		ExposeMessage = ByteNet.definePacket({
			value = ByteNet.struct({
				Message = ByteNet.string,
			}),
		}),
		CloseDialogue = ByteNet.definePacket({
			value = ByteNet.struct({
				_ = ByteNet.nothing,
			}),
		}),
		SwitchToChoice = ByteNet.definePacket({
			value = ByteNet.struct({
				_ = ByteNet.nothing,
			}),
		}),
		ChoiceChosen = ByteNet.definePacket({
			value = ByteNet.struct({
				UUID = ByteNet.string,
			}),
		}),
		FinishedMessage = ByteNet.definePacket({
			value = ByteNet.struct({
				_ = ByteNet.nothing,
			}),
		}),
		-- EnablePP = ByteNet.definePacket({
		-- 	value = ByteNet.struct({
		-- 		_ = ByteNet.nothing,
		-- 	}),
		-- }),
		-- DisablePP = ByteNet.definePacket({
		-- 	value = ByteNet.struct({
		-- 		_ = ByteNet.nothing,
		-- 	}),
		-- }),
	}
end)
