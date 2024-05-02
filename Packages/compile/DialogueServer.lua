--!native
--!nocheck
type CreateChoicesTemplete = (ChoiceMessage: string, ConstructChoice...) -> ()
type CreateMessageTemplete = (ConstructMessage...) -> ()
type CreateDialogueTemplete = (Message: CreateMessageTemplete, Choice: CreateChoicesTemplete) -> ()
type ConstructChoice = (ChoiceName: string, Response: CreateDialogueTemplete, Timeout: number) -> Listeners
type ConstructMessage = (Head: string, Body: string) -> Listeners
type Mount = () -> ()

type DialogueServer = {
	ConstructChoice: ConstructChoice,
	ConstructMessage: ConstructMessage,
	CreateChoicesTemplete: CreateChoicesTemplete,
	CreateMessageTemplete: CreateMessageTemplete,
	CreateDialogueTemplete: CreateDialogueTemplete,
	Mount: Mount,
}
export type Listeners = {
	AddTriggerSignal: (self: Listeners, fn: (player: Player) -> ()) -> (),
	AddTimeoutSignal: (self: Listeners, Time: number, fn: (player: Player) -> ()) -> (),
}
type INTERNAL_Message = {
	Head: string,
	Body: string,
	_TimeoutTime: number?,
	_TimeoutCallback: (player: Player) -> ()?,
	_TriggerCallback: (player: Player) -> ()?,
}

type INTERNAL_Choice = {
	ChoiceName: string,
	UUID: string,
	Response: INTERNAL_MountInfo,
	_TimeoutTime: number?,
	_TimeoutCallback: (player: Player) -> ()?,
	_TriggerCallback: (player: Player) -> ()?,
}

type INTERNAL_CreateChoicesTemplete = CreateChoicesTemplete & () -> { ChoiceMessage: string, Data: { INTERNAL_Choice } }
type INTERNAL_CreateMessageTemplete = CreateMessageTemplete & () -> { Data: { INTERNAL_Message } }
type INTERNAL_CreateDialogueTemplete =
	CreateDialogueTemplete
	& () -> { Message: INTERNAL_CreateMessageTemplete, Choice: INTERNAL_CreateChoicesTemplete }
type INTERNAL_ConstructChoice = (ChoiceName: string, Response: INTERNAL_CreateDialogueTemplete) -> INTERNAL_Choice
type INTERNAL_ConstructMessage = (Head: string, Body: string, Image: string) -> INTERNAL_Message
type INTERNAL_MountInfo = {
	Message: { Data: { INTERNAL_Message } },
	Choices: { ChoiceMessage: string, Data: { INTERNAL_Choice } },
}
type INTERNAL_ActivePlayerData = {
	CurrentClientDialogue: INTERNAL_MountInfo,
	CurrentClientMessage: number,
	ExposeType: string,
	Promises: {},
}

--Services--
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
--Modules--
local utils = require(script.Parent:WaitForChild("utils"))
local Packet = require(script.Parent:WaitForChild("packet"))
local Promise = require(ReplicatedStorage.Packages.Promise)
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)

local DialogueServer = {}
local MountedDialogues = {}
local PlayersInDialogue = {}
--TODO: Implement DevMode.
DialogueServer.DevMode = RunService:IsStudio()

local Listeners = {}
Listeners.__index = Listeners

--TODO: Add the ability to chain 
function Listeners:AddTriggerSignal(fn: (player: Player) -> ())
	self._TriggerCallback = fn
	return self
end

function Listeners:AddTimeoutSignal(Time: number, fn: (player: Player) -> ())
	self._TimeoutTime = Time
	self._TimeoutCallback = fn
	return self
end

--Searches for the message/choice and checks if there is callbacks (either TimeoutCallback, TriggerCallback). Calls them
local function UseCallbacks(plr: Player, Data: INTERNAL_ActivePlayerData, Scan: INTERNAL_Choice | INTERNAL_Message)
	if Scan._TimeoutCallback then
		table.insert(
			Data.Promises,
			Promise.delay(Scan._TimeoutTime):finally(function()
				Scan._TimeoutCallback(plr)
			end)
		)
	end
	if Scan._TriggerCallback then
		Scan._TriggerCallback(plr)
	end
end

--INTERNAL: Cancels all the promises in the table and making the table empty
local function CancelPromises(PromiseTable: {})
	print(PromiseTable)
	for _, promise in ipairs(PromiseTable) do
		promise:cancel()
	end
	table.clear(PromiseTable)
end

ProximityPromptService.PromptTriggered:Connect(function(prompt, playerWhoTriggered)
	if PlayersInDialogue[playerWhoTriggered.Name] then
		playerWhoTriggered:Kick(`Anticheat: {script.Name}, {debug.info(1, "l")}`)
	end
end)

Players.PlayerRemoving:Connect(function(player)
	PlayersInDialogue[player.Name] = nil
end)

Packet.CloseDialogue.listen(function(player)
	if PlayersInDialogue[player.Name] then
		PlayersInDialogue[player.Name] = nil
	else
		player:Kick(`Anticheat: {script.Name}, {debug.info(1, "l")}`)
	end
end)

Packet.ChoiceChosen.listen(function(uuid, player: Player)
	local UUID = uuid.UUID
	local Data: INTERNAL_ActivePlayerData = PlayersInDialogue[player.Name]
	if Data then
		CancelPromises(Data.Promises)
		if Data.ExposeType == "Choice" then
			for _, Choice in ipairs(Data.CurrentClientDialogue.Choices.Data) do
				if Choice.UUID == UUID then
					Data.CurrentClientDialogue = Choice.Response
					Data.CurrentClientMessage = 1
					UseCallbacks(player, Data, Choice)
					if Choice.Response then
						Data.CurrentClientDialogue = Choice.Response
						Data.CurrentClientMessage = 1
						Data.ExposeType = "Message"
						UseCallbacks(player, Data, Data.CurrentClientDialogue.Message.Data[Data.CurrentClientMessage])
						return Packet.ExposeMessage.sendTo({
							Head = Data.CurrentClientDialogue.Message.Data[Data.CurrentClientMessage].Head,
							Body = Data.CurrentClientDialogue.Message.Data[Data.CurrentClientMessage].Body,
						}, player)
					else
						PlayersInDialogue[player.Name] = nil
						return Packet.CloseDialogue.sendTo({}, player)
					end
					player:Kick(`Anticheat: {script.Name}, {debug.info(1, "l")}`)
				end
			end
		end
	else
		player:Kick(`Anticheat: {script.Name}, {debug.info(1, "l")}`)
	end
end)

Packet.FinishedMessage.listen(function(_, player)
	local Data: INTERNAL_ActivePlayerData = PlayersInDialogue[player.Name]
	if Data then
		local NextMessage: INTERNAL_Message = Data.CurrentClientDialogue.Message.Data[Data.CurrentClientMessage]
		Data.CurrentClientMessage += 1
		CancelPromises(Data.Promises)
		if Data.ExposeType == "Message" then
			if NextMessage then
				if Data.CurrentClientMessage == #Data.CurrentClientDialogue.Message + 1 then
					player:Kick(`Anticheat: {script.Name}, {debug.info(1, "l")}`)
				else
					UseCallbacks(player, Data, NextMessage)
				end
				Packet.ExposeMessage.sendTo({ Head = NextMessage.Head, Body = NextMessage.Body }, player)
			else
				if Data.CurrentClientDialogue.Choices == nil then
					PlayersInDialogue[player.Name] = nil
					Packet.CloseDialogue.sendTo({}, player)
				else
					Data.ExposeType = "Choice"
					local Choices = TableUtil.Copy(Data.CurrentClientDialogue.Choices, true)
					for _, Choice: INTERNAL_Choice in ipairs(Choices.Data) do
						utils.Unreconcile(Choice, "Response", "_TimeoutTime", "_TimeoutCallback", "_TriggerCallback")
					end
					Packet.ExposeChoice.sendTo({
						ChoiceMessage = Data.CurrentClientDialogue.Choices.ChoiceMessage,
						Choices = Choices.Data,
					}, player)
				end
			end
		else
			player:Kick(`Anticheat: {script.Name}, {debug.info(1, "l")}`)
		end
	else
		player:Kick(`Anticheat: {script.Name}, {debug.info(1, "l")}`)
	end
end)

function DialogueServer.Mount(Dialogue: INTERNAL_MountInfo, Part: Instance, CustomProximityPrompt: ProximityPrompt?)
	local ProximityPrompt = Instance.new("ProximityPrompt", Part)
	ProximityPrompt:AddTag("Dialogue")
	table.insert(MountedDialogues, {
		PPConnection = ProximityPrompt.TriggerEnded:Connect(function(player)
			PlayersInDialogue[player.Name] = {
				CurrentClientDialogue = Dialogue,
				CurrentClientMessage = 1,
				ExposeType = "Message",
				Promises = (Dialogue.Message.Data[1]._TimeoutCallback and {
					Promise.delay(Dialogue.Message.Data[1]._TimeoutTime):finally(function()
						Dialogue.Message.Data[1]._TimeoutCallback(player)
					end),
				}) or {},
			}
			Packet.ExposeMessage.sendTo(
				{ Head = Dialogue.Message.Data[1].Head, Body = Dialogue.Message.Data[1].Body },
				player
			)
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

function DialogueServer.ConstructMessage(Head: string, Body: string)
	assert(Head, "[Dialogue] Empty or nil for Head. Please provide a string")
	assert(Body, "[Dialogue] Empty or nil for Head. Please provide a string.")
	local m = setmetatable({}, Listeners)
	m.Head = Head
	m.Body = Body
	return m
end

function DialogueServer.ConstructChoice(ChoiceName: string, Response: INTERNAL_CreateDialogueTemplete)
	assert(ChoiceName, "[Dialogue] Empty or nil for ChoiceName")
	local c = setmetatable({}, Listeners)
	c.ChoiceName = ChoiceName
	c.UUID = HttpService:GenerateGUID()
	c.Response = Response
	return c :: INTERNAL_Choice
end

return DialogueServer :: DialogueServer
