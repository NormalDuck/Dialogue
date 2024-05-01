--!native
--!nocheck
type CreateChoicesTemplete = (ChoiceMessage: string, ConstructChoice...) -> ()
type CreateMessageTemplete = (ConstructMessage...) -> ()
type CreateDialogueTemplete = (Message: CreateMessageTemplete, Choice: CreateChoicesTemplete) -> ()
type ConstructChoice = (
	ChoiceName: string,
	Response: CreateDialogueTemplete,
	Handler: { TimeoutHandler: () -> (), TriggerHandler: () -> () }?
) -> ()
type ConstructMessage = (
	Head: string,
	Body: string,
	Handler: { TimeoutHandler: () -> (), TriggerHandler: () -> () }?
) -> ()
type DialogueServer = {
	ConstructChoice: ConstructChoice,
	ConstructMessage: ConstructMessage,
	CreateChoicesTemplete: CreateChoicesTemplete,
	CreateMessageTemplete: CreateMessageTemplete,
	CreateDialogueTemplete: CreateDialogueTemplete,
	Mount: (Dialogue: CreateDialogueTemplete, Part: BasePart) -> (),
}

type INTERNAL_Message = {
	Head: string,
	Body: string,
	_callback: (player: Player) -> (),
	_timeoutHandler: (player: Player) -> (),
	_timeout: number,
	Handler: { TimeoutHandler: () -> (), TriggerHandler: () -> () },
}

type INTERNAL_Choice = {
	ChoiceName: string,
	UUID: string,
	Response: INTERNAL_MountInfo,
	_callback: (player: Player) -> (),
	_timeoutHandler: (player: Player) -> (),
	_timeout: number,
	Handler: { TimeoutHandler: () -> (), TriggerHandler: () -> () },
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
}

--Services--
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--Modules--
local utils = require(script.Parent:WaitForChild("utils"))
local Packet = require(script.Parent:WaitForChild("packet"))
local Promise = require(ReplicatedStorage.Packages.Promise)
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)

local DialogueServer = {}
local MountedDialogues = {}
local PlayersInDialogue = {}
local TimeoutPromises = {}

DialogueServer.DevMode = false

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
		if Data.ExposeType == "Choice" then
			for _, Choice in ipairs(Data.CurrentClientDialogue.Choices.Data) do
				if Choice.UUID == UUID then
					Data.CurrentClientDialogue = Choice.Response
					Data.CurrentClientMessage = 1
					if Choice._callback then
						Choice._callback(player)
					end
					if Choice.Response then
						Data.CurrentClientDialogue = Choice.Response
						Data.CurrentClientMessage = 1
						Data.ExposeType = "Message"
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
	Data.CurrentClientMessage += 1
	local NextMessage: INTERNAL_Message = Data.CurrentClientDialogue.Message.Data[Data.CurrentClientMessage]
	if Data then
		if Data.ExposeType == "Message" then
			if NextMessage then
				if Data.CurrentClientMessage == #Data.CurrentClientDialogue.Message + 1 then
					player:Kick(`Anticheat: {script.Name}, {debug.info(1, "l")}`)
				elseif Data.CurrentClientDialogue.Message.Data[Data.CurrentClientMessage]._callback then
					Data.CurrentClientDialogue.Message.Data[Data.CurrentClientMessage]._callback(player)
				end
				Packet.ExposeMessage.sendTo({ Head = NextMessage.Head, Body = NextMessage.Body }, player)
				if NextMessage._callback then
					NextMessage._callback()
				end
				if NextMessage._timeout then
					table.insert(
						TimeoutPromises,
						Promise.delay(NextMessage._timeout):finally(function()
							NextMessage._timeoutHandler(player)
						end)
					)
				end
			else
				if Data.CurrentClientDialogue.Choices == nil then
					PlayersInDialogue[player.Name] = nil
					Packet.CloseDialogue.sendTo({}, player)
				else
					Data.ExposeType = "Choice"
					local Choices = TableUtil.Copy(Data.CurrentClientDialogue.Choices, true)
					for _, Choice: INTERNAL_Choice in ipairs(Choices.Data) do
						utils.Unreconcile(Choice, "Response", "_callback", "_timeout", "_timeoutHandler")
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

function DialogueServer.ConstructMessage(
	Head: string,
	Body: string,
	Handlers: { TimeoutHandler: () -> (), TriggerHandler: () -> () }
)
	assert(Head, "[Dialogue] Empty or nil for Head. Please provide a string")
	assert(Body, "[Dialogue] Empty or nil for Head. Please provide a string.")
	local m = {}
	m.Head = Head
	m.Body = Body
	if Handlers then
		for handlerName, handler in ipairs(Handlers) do
			assert(handlerName == "TimeoutHandler" or handlerName == `[Dialogue] Invaild handler name?`)
			if handler then
				m[handlerName] = handler
			end
		end
	end
	return m
end

function DialogueServer.ConstructChoice(
	ChoiceName: string,
	Response: INTERNAL_CreateDialogueTemplete,
	Handlers: { TimeoutHandler: () -> (), TriggerHandler: () -> () }
)
	assert(ChoiceName, "[Dialogue] Empty or nil for ChoiceName")
	local c = {}
	c.ChoiceName = ChoiceName
	c.UUID = HttpService:GenerateGUID()
	c.Response = Response
	if Handlers then
		for handlerName, handler in ipairs(Handlers) do
			assert(
				handlerName == "TimeoutHandler" or handlerName == "TriggerHandler",
				`[Dialogue] Invaild handler name?`
			)
			if handler then
				c[handlerName] = handler
			end
		end
	end
	return c :: INTERNAL_Choice
end

return DialogueServer :: DialogueServer
