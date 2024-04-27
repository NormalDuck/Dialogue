--!native
local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local ClientService = Knit.CreateService({
	Name = "ClientService",
	Client = {
		--[[Service -> Client]]
		--
		DisableProximityPrompt = Knit.CreateSignal(),
		EnableProximityPrompt = Knit.CreateSignal(),
		--[[Client -> Server]]
		--
		InputBegan = Knit.CreateSignal(),
		InputChanged = Knit.CreateSignal(),
		InputEnded = Knit.CreateSignal(),
		JumpRequest = Knit.CreateSignal(),
	},
})

function ClientService:DisableProximityPrompt(Player: Player)
	self.Client.DisableProximityPrompt:Fire(Player)
	table.insert(self._DisabledProximityPromptList, Player)
end

function ClientService:EnableProximityPrompt(Player: Player)
	self.Client.EnableProximityPrompt:Fire(Player)
	table.remove(self._DisabledProximityPromptList, table.find(self._DisabledProximityPromptList, Player))
end

function ClientService:KnitInit()
	self._DisabledProximityPromptList = {} :: { Player }
	Players.PlayerRemoving:Connect(function(player)
		table.remove(self._DisabledProximityPromptList, table.find(self._DisabledProximityPromptList, player))
	end)
	ProximityPromptService.PromptTriggered:Connect(function(prompt, playerWhoTriggered)
		if table.find(self._DisabledProximityPromptList, playerWhoTriggered) then
			playerWhoTriggered:Kick("Anticheat")
		end
	end)
end

function ClientService:KnitStart()
	ClientService.Client.InputBegan:Connect(function(Player: Player, InputType: Enum.InputType)
		if typeof(InputType) ~= "EnumItem" then
			Player:Kick("Anticheat, false enum")
		end
	end)
	ClientService.Client.InputChanged:Connect(function(Player: Player, InputType: Enum.InputType)
		if typeof(InputType) ~= "EnumItem" then
			Player:Kick("Anticheat, false enum")
		end
	end)

	ClientService.Client.InputEnded:Connect(function(Player: Player, InputType: Enum.InputType)
		if typeof(InputType) ~= "EnumItem" then
			Player:Kick("Anticheat, false enum")
		end
	end)

	ClientService.Client.JumpRequest:Connect(function(Player: Player)
		
	end)
end
return ClientService
