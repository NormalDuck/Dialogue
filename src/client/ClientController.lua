--!native
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Knit = require(ReplicatedStorage.Packages.Knit)

local ClientController = Knit.CreateController({ Name = "ClientController" })

-- srry i couldnt find where your declarations and/or definitions were at
function ClientController:KnitStart()
	local ClientService = Knit.GetService("ClientService")

	ClientService.DisableProximityPrompt:Connect(function()
		ProximityPromptService.Enabled = false
	end)
	ClientService.EnableProximityPrompt:Connect(function()
		ProximityPromptService.Enabled = true
	end)

	UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
		ClientService.InputBegan:Fire(input.UserInputType)
	end)
	UserInputService.InputEnded:Connect(function(input, gameProcessedEvent)
		ClientService.InputChanged:Fire(input.UserInputType)
	end)
	UserInputService.InputEnded:Connect(function(input, gameProcessedEvent)
		ClientService.InputEnded:Fire(input.UserInputType)
	end)
	UserInputService.JumpRequest:Connect(function()
		ClientService.JumpRequest:Fire()
	end)
end

function ClientController:KnitInit() end

return ClientController
