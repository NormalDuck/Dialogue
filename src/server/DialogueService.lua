--!native
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)
local Utils = require(ReplicatedStorage.Shared.Utils.Utilities)
local Unreconcile = Utils.Unreconcile

export type Methods = {
	Listen: () -> Player,
}

export type Message = {
	Image: string,
	Head: string,
	Body: string,
} & Methods

export type Choice = {
	Message: { Message },
} & Methods

export type Textbox = {
	EventHandler: () -> Player,
} & Methods

export type ChoiceTemplete = {
	AddTimeout: (Timeout: number, TimeoutHandler: () -> Player) -> (),
}

----------------PRIVATE METHODS---------------

local Methods = {} :: Methods
function Methods:Listen(callback: () -> Player)
	self.__callback = callback
	return self
end

local ChoiceTemplete = {} :: ChoiceTemplete

function ChoiceTemplete:AddTimeout(Timeout: number, TimeoutHandler: () -> Player)
	self.Timeout = Timeout
	self.TimeoutHandler = TimeoutHandler
end
-----------------------------------------------------

local DialogueService = Knit.CreateService({
	Name = "DialogueService",
	Client = {
		--[Server -> Client]--
		ServerCloseDialogue = Knit.CreateSignal(), --"Forces" the client to close the dialogue.
		ExposeInformation = Knit.CreateSignal(), --Sends the format of the dialogue to the client

		--[Client -> Server]--
		FinishedInfo = Knit.CreateSignal(), --Asks for the server to give further information.
		FinishedMessage = Knit.CreateSignal(), --Tells the server they finished the message.
		ClientCloseDialogue = Knit.CreateSignal(), --Tells the server client has closed the dialog.
	},
})

--[[Mounts the Dialogue to client side and creates a proximity Message]]
function DialogueService:Mount(
	Dialogue: {
		Messages: {},
		Choices: {},
	},
	Part: BasePart
)
	local ClientService = Knit.GetService("ClientService")
	local ProximityPrompt = Instance.new("ProximityPrompt", Part)

	table.insert(self._MountedDialogues, {
		Dialogue = Dialogue,
		Trigged = ProximityPrompt.Triggered:Connect(function(Player) --Opens a connection
			task.wait() --waits one frames for the client to react with the invoke so it doesn't kick you immediately after signal is fired
			ClientService:DisableProximityPrompt(Player)
			DialogueService._PlayerRegisteredDialogue[Player] = Dialogue

			local CurrentClientDialogue = Dialogue
			local ExposeType = "Message"
			local CurrentClientMessage = #CurrentClientDialogue.Message.Data + 1

			local FinishedInfoConnection: RBXScriptConnection
			local ClientCloseDialogueConnection: RBXScriptConnection
			local FinishedMessageConnection: RBXScriptConnection

			FinishedMessageConnection = DialogueService.Client.FinishedMessage:Connect(function(playerWhoFired)
				if playerWhoFired ~= Player then
					return
				end
				if ExposeType == "Message" then
					CurrentClientMessage -= 1
					if CurrentClientMessage == 0 then
						Player:Kick(`Anticheat: {script.Name}, {debug.info(1, "l")}`)
					elseif CurrentClientDialogue.Message.Data[CurrentClientMessage].__callback then
						CurrentClientDialogue.Message.Data[CurrentClientMessage].__callback(Player)
					end
				else
					Player:Kick(`Anticheat: {script.Name}, {debug.info(1, "l")}`)
				end
			end)

			DialogueService.Client.ExposeInformation:Fire(Player, Dialogue.Message.Data, ExposeType)

			FinishedInfoConnection = DialogueService.Client.FinishedInfo:Connect(
				function(playerWhoFired: Player, UUID: string)
					ExposeType = (ExposeType == "Message" and "Choice") or "Message"
					if playerWhoFired ~= Player then
						return
					end
					if ExposeType == "Choice" then
						if CurrentClientDialogue.Choices == nil then
							DialogueService:CloseDialogue(playerWhoFired)
							ClientService:EnableProximityPrompt(playerWhoFired)
							FinishedMessageConnection:Disconnect()
							FinishedInfoConnection:Disconnect()
							ClientCloseDialogueConnection:Disconnect()
							return
						end
						local Copy = TableUtil.Copy(CurrentClientDialogue.Choices, true)
						for _, Choice in ipairs(Copy.Data) do
							Unreconcile(Choice, "Message", "ResponseHandler", "ResponseTime", "Choices")
						end
						return DialogueService.Client.ExposeInformation:Fire(playerWhoFired, Copy, "Options")
					end

					if ExposeType == "Message" then
						for _, Choice in ipairs(CurrentClientDialogue.Choices.Data) do
							if Choice.UUID == UUID then
								CurrentClientDialogue = Choice
								CurrentClientMessage = #CurrentClientDialogue.Message.Data + 1
								DialogueService.Client.ExposeInformation:Fire(
									playerWhoFired,
									CurrentClientDialogue.Message.Data,
									"Message"
								)
								if Choice.__callback then
									Choice.__callback(playerWhoFired)
								end
								return
							end
						end
					end
					Player:Kick(`Anticheat: {script.Name}, {debug.info(1, "l")}`)
				end
			)

			ClientCloseDialogueConnection = DialogueService.Client.ClientCloseDialogue:Connect(function(player)
				DialogueService:CloseDialogue(player)
				ClientService:EnableProximityPrompt(player)
				FinishedMessageConnection:Disconnect()
				FinishedInfoConnection:Disconnect()
				ClientCloseDialogueConnection:Disconnect()
			end)
		end),
	})
end

--[[Unmouts the Dialogue constructed using Dialogue module.
\
**please provide the constructed Dialogue within the first argument, or the function won't work**]]
function DialogueService:Unmount(Dialogue: table, CloseActiveDialogues: boolean)
	assert(Dialogue, "Please provide a Dialogue value")
	local FoundDialogue = false
	for i, MountedDialogue in ipairs(self._MountedDialogues) do
		if MountedDialogue.Dialogue == Dialogue then
			FoundDialogue = true
			MountedDialogue.Triggered:Disconnect()
			MountedDialogue.ProximityPrompt:Destroy()
		end
		table.remove(self._MountedDialogues, i)
	end
	assert(FoundDialogue, "Cannot find the provided Dialogue.")
end

--[[Unmounts **all** the Dialogues exposed the clients. Sends them a signal to tell them to delete it.]]
function DialogueService:UnmountAll(CloseActiveDialogues: boolean)
	local FoundDialogue = false
	for i, MountedDialogue in ipairs(self._MountedDialogues) do
		FoundDialogue = true
		MountedDialogue.Triggered:Disconnect()
		MountedDialogue.ProximityPrompt:Destroy()
		table.remove(self._MountedDialogues, i)
	end
	assert(FoundDialogue, "Cannot find the provided Dialogue.")
end

--[[Creates a custom `Message` data type.
\
**Methods Inherited:**
\
`Methods:Listen(callback: () -> (Player))`]]
function DialogueService:ConstructMessage(Head: string, Body: string, Image: string)
	assert(Head, "[DialogService] Please provide head (name of the speaker) message")
	assert(Body, "[DialogService] Please provide body message")
	local NewMessage = setmetatable({}, { __index = Methods })
	NewMessage.Head = Head
	NewMessage.Body = Body
	NewMessage.Image = Image
	return NewMessage
end

--[[Creates a custom `Choice` data type.
\
**Methods Inherited:**
\
`Methods:Listen(callback: () -> (Player))`]]
function DialogueService:ConstructChoice(
	ChoiceName: string,
	Message: {
		Message: {},
		Choices: {},
	}
)
	local NewChoice = setmetatable(Message, { __index = Methods })
	assert(
		typeof(Message.Message) == "table",
		"[DialogueService `ConstructChoice`] Please wrap your messages within a table when constructing a message key"
	)
	NewChoice.ChoiceName = ChoiceName
	NewChoice.UUID = HttpService:GenerateGUID()
	return NewChoice
end

function DialogueService:ConstructTextbox()
	local NewTextbox = setmetatable({}, { __index = Methods })
	return NewTextbox
end

--[[
Abstraction for creating table, increases readability for the code. Has methods for more customizations.
\
**Methods Inherited:**
\
`AddTimeout: (Timeout: number, TimeoutHandler: () -> ()) -> (),`
]]
function DialogueService:CreateChoicesTemplete(OptionMessage: string, ...: Choice)
	local ChoicesTemplete = setmetatable({}, { __index = ChoiceTemplete })
	ChoicesTemplete.Data = { ... }
	ChoicesTemplete.OptionMessage = OptionMessage
	return ChoicesTemplete
end

--[[Abstraction for creating table, increases readability for the code. You may use tables instead, perferably this as I might update APIS to support this method with more things.]]
function DialogueService:CreateMessageTemplete(...: Message)
	local MessageTemplete = setmetatable({}, {}) --Empty for now. May add methods later
	MessageTemplete.Data = { ... }
	return MessageTemplete
end

--[[Re-exports `ServerCloseDialogue:Fire(Player)`. If no player is specified, "forces" all clients to close dialogue]]
function DialogueService:CloseDialogue(Player: Player)
	if Player then
		self.Client.ServerCloseDialogue:Fire(Player)
	else
		self.Client.ServerCloseDialogue:FireAll()
	end
end

function DialogueService:KnitInit()
	self._MountedDialogues = {} :: {
		{
			Dialogue: table,
			Triggered: RBXScriptConnection,
		}
	}
	self._PlayerRegisteredDialogue = {} :: { Message: any, Children: { { ChoiceName: string, Message: any } } }
	DialogueService.Client.ClientCloseDialogue:Connect(function(player: Player)
		if self._PlayerRegisteredDialogue[player] then
			self._PlayerRegisteredDialogue[player] = nil
		else
			player:Kick(`Anticheat: {script.Name}, {debug.info(1, "l")}`)
		end
	end)
end

return DialogueService
