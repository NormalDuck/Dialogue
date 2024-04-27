--!native
type CreateChoicesTemplete = (ChoiceMessage: string, ConstructChoice...) -> ()
type CreateMessageTemplete = (ConstructMessage...) -> ()
type CreateDialogueTemplete = (Message: CreateMessageTemplete, Choice: CreateChoicesTemplete) -> ()
type ConstructChoice = (ChoiceName: string, Response: CreateDialogueTemplete) -> DialogueMethods
type ConstructMessage = (Head: string, Body: string, Image: string) -> DialogueMethods
type DialogueServer = {
	ConstructChoice: ConstructChoice,
	ConstructMessage: ConstructMessage,
	CreateChoicesTemplete: CreateChoicesTemplete,
	CreateMessageTemplete: CreateMessageTemplete,
	CreateDialogueTemplete: CreateDialogueTemplete,
	Mount: (CreateDialogueTemplete) -> (),
	DevMode: boolean,
}
type DialogueMethods = {
	AddTimeout: () -> Player,
	Listen: () -> Player,
}

type INTERNAL_Message = {
	Head: string,
	Body: string,
} & DialogueMethods
type INTERNAL_Choice = {
	ChoiceName: string,
	UUID: string,
	Response: INTERNAL_MountInfo,
} & DialogueMethods

type INTERNAL_CreateChoicesTemplete = CreateChoicesTemplete & () -> { ChoiceMessage: string, Data: { INTERNAL_Choice } }
type INTERNAL_CreateMessageTemplete = CreateMessageTemplete & () -> { Data: { INTERNAL_Message } }
type INTERNAL_CreateDialogueTemplete =
	CreateDialogueTemplete
	& () -> { Message: INTERNAL_CreateMessageTemplete, Choice: INTERNAL_CreateChoicesTemplete }
type INTERNAL_ConstructChoice = (ChoiceName: string, Response: INTERNAL_CreateDialogueTemplete) -> INTERNAL_Choice
type INTERNAL_ConstructMessage = (Head: string, Body: string, Image: string) -> INTERNAL_Message
type INTERNAL_MountInfo = {
	Message: { Data: { INTERNAL_Message } },
	Choice: { ChoiceMessage: string, Data: { INTERNAL_Choice } },
}
type INTERNAL_ActivePlayerData = {
	CurrentClientDialogue: INTERNAL_MountInfo,
	CurrentClientMessage: number,
	ExposeType: string,
}
--Methods for inheritence--
local Methods = {} :: DialogueMethods
function Methods:Listen(callback: () -> Player)
	assert(self, "[Dialogue] Please use :Listen, not .Listen")
	self._callback = callback
	return self
end

function Methods:AddTimeout(Time: number, Handler: () -> Player)
	assert(self, "[Dialogue] Please use :AddTimeout, not .AddTimeout")
	self._timeout = Time
	self._timeoutHandler = Handler
end
--Methods for inheritence END--

--Services--
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--Modules--
local utils = require(script.Parent:WaitForChild("utils"))
local Packet = require(script.Parent:WaitForChild("packet"))
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)

local DialogueServer = {}
local MountedDialogues = {}
local ActivePlayers = {}

DialogueServer.DevMode = false

Players.PlayerRemoving:Connect(function(player)
	ActivePlayers[player.Name] = nil
end)

Packet.CloseDialogue.listen(function(player)
	if ActivePlayers[player.Name] then
		ActivePlayers[player.Name] = nil
	else
		player:Kick(`Anticheat: {script.Name}, {debug.info(1, "l")}`)
	end
end)

Packet.ChoiceChosen.listen(function(player, UUID)
	local Data: INTERNAL_ActivePlayerData = ActivePlayers[player.Name]
	if Data then
		if Data.ExposeType == "Message" then
			for _, Choice in ipairs(Data.CurrentClientDialogue.Choice.Data) do
				if Choice.UUID == UUID then
					Data.CurrentClientDialogue = Choice.Response
					Data.CurrentClientMessage = 1
					Packet.ExposeMessage.sendTo({
						Message = Data.CurrentClientDialogue.Message[Data.CurrentClientMessage],
					}, player)
					if Choice._callback then
						Choice._callback(player)
					end
				end
			end
			player:Kick(`Anticheat: {script.Name}, {debug.info(1, "l")}`)
		end
	else
		player:Kick(`Anticheat: {script.Name}, {debug.info(1, "l")}`)
	end
end)

Packet.SwitchToChoice.listen(function(player: Player)
	local Data: INTERNAL_ActivePlayerData = ActivePlayers[player.Name]
	if Data then
		if Data.ExposeType == "Choice" then
			if Data.CurrentClientDialogue.Choice == nil then
				Packet.CloseDialogue.sendTo({}, player)
				Packet.EnablePP.sendTo({}, player)
			else
				local Choices = TableUtil.Copy(Data.CurrentClientDialogue.Choice, true)
				for _, Choice: INTERNAL_Choice in ipairs(Choices.Data) do
					utils.Unreconcile(Choice, "Response", "_callback", "_timeout", "_timeoutHandler")
				end
				Packet.ExposeChoice.sendTo({
					ChoiceMessage = Data.CurrentClientDialogue.Choice.ChoiceMessage,
					Choices = Choices,
				}, player)
			end
		else
			player:Kick(`Anticheat: {script.Name}, {debug.info(1, "l")}`)
		end
	else
		player:Kick(`Anticheat: {script.Name}, {debug.info(1, "l")}`)
	end
end)

Packet.FinishedMessage.listen(function(player)
	local Data: INTERNAL_ActivePlayerData = ActivePlayers[player.Name]
	if Data then
		if Data.ExposeType == "Message" then
			Data.CurrentClientMessage += 1
			if Data.CurrentClientMessage >= #Data.CurrentClientDialogue.Message + 1 then
				player:Kick(`Anticheat: {script.Name}, {debug.info(1, "l")}`)
			elseif Data.CurrentClientDialogue.Message.Data[Data.CurrentClientMessage]._callback then
				Data.CurrentClientDialogue.Message.Data[Data.CurrentClientMessage]._callback(player)
			end
			Packet.ExposeMessage.sendTo({ Message = Data.CurrentClientDialogue.Message.Data[Data.CurrentClientMessage] })
		else
			player:Kick(`Anticheat: {script.Name}, {debug.info(1, "l")}`)
		end
	else
		player:Kick(`Anticheat: {script.Name}, {debug.info(1, "l")}`)
	end
end)

function DialogueServer.Mount(Dialogue: INTERNAL_MountInfo, Part: Instance)
	local ProximityPrompt = Instance.new("ProximityPrompt", Part)
	table.insert(MountedDialogues, {
		PPConnection = ProximityPrompt.TriggerEnded:Connect(function(player)
			ActivePlayers[player.Name] = {
				CurrentClientDialogue = Dialogue,
				CurrentClientMessage = 1,
				ExposeType = "Message",
			}
		end),
	})
end

function DialogueServer.CreateDialogueTemplete(Message: CreateMessageTemplete, Choice: CreateChoicesTemplete)
	local t = {}
	t.Message = Message
	t.Choices = Choice
	return t
end

function DialogueServer.CreateChoicesTemplete(ChoiceMessage: string, ...: INTERNAL_Choice)
	assert(type(ChoiceMessage) == "string", "[Dialogue] Choice message is a string. ")
	print(ChoiceMessage)
	local t = {}
	t.Data = { ... }
	t.ChoiceMessage = ChoiceMessage
	return t
end

function DialogueServer.CreateMessageTemplete(...: INTERNAL_Message)
	local t = {}
	t.Data = { ... }
	return t
end

function DialogueServer.ConstructMessage(Head: string, Body: string, Image: string)
	assert(Head, "[Dialogue] Empty or nil for Head. Please provide a string")
	assert(Body, "[Dialogue] Empty or nil for Head. Please provide a string.")
	local m = setmetatable({}, { __index = Methods })
	m.Head = Head
	m.Body = Body
	m.Image = Image
	return m
end

function DialogueServer.ConstructChoice(ChoiceName: string, Response: INTERNAL_CreateDialogueTemplete)
	assert(ChoiceName, "[Dialogue] Empty or nil for ChoiceName")
	local c = setmetatable(Response or {}, { __index = Methods })
	c.ChoiceName = ChoiceName
	c.UUID = HttpService:GenerateGUID()
	return c :: INTERNAL_Choice
end

return DialogueServer :: DialogueServer
