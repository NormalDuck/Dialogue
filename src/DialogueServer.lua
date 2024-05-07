--!native
--!nocheck
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")

local Packet = require(script.Parent:WaitForChild("packet"))
local PrivateTypes = require(script.Parent:WaitForChild("PrivateTypes"))
local PublicTypes = require(script.Parent:WaitForChild("PublicTypes"))
local Promise = require(script.Parent.Parent.Promise)
local TableUtil = require(script.Parent.Parent.TableUtil)


--[=[
	@class DialogueServer
	@server
]=]
local DialogueServer = {}

local MountedDialogues = {}
local PlayersInDialogue = {}

--[=[
	@class ServerSignals
	Listeners are custom methods that are returned when creating components of dialogue.
]=]
local ServerSignals = {}
ServerSignals.__index = ServerSignals

--[=[
	Sends a signal whenever this Dialogue component has been triggered.
	```lua
	local Dialogue = require(path.to.dialogue)

	Dialogue.Mount(
		Dialogue.CreateDialogueTemplate(
			Dialogue.CreateMessageTemplate(Dialogue.ConstructMessage():AddTriggerSignal(function(player)
				print(`{player} triggered it!`)
			end))
				:AddTriggerSignal(function()
					print("works for all constructors!")
				end)
				:AddTriggerSignal(function()
					print("You can also chain them!")
				end)
				:AddTimeoutSignal(2, function()
					print("Or mix with the other signal!")
				end),
			workspace.Instance
		)
	)
	```
]=]
function ServerSignals:AddTriggerSignal(fn: (player: Player) -> ())
	table.insert(self.Listeners, { Type = "Trigger", Callback = fn })
	return self
end

--[=[
	Sends a signal whenever it reaches the time and client doesn't perform any action to the dialogue component

	```lua
	local Dialogue = require(path.to.dialogue)

	Dialogue.Mount(
		Dialogue.CreateDialogueTemplate(
			Dialogue.CreateMessageTemplate(Dialogue.ConstructMessage():AddTimeoutSignal(2, function(player)
				print(`{player} this prints when client doesn't finish your message within 2 seconds!`)
			end))
				:AddTimeoutSignal(1, function()
					print("The next chain prints at the same time!")
				end)
				:AddTimeoutSignal(1, function()
					print("Chains don't yield each other!")
				end)
				:AddTriggerSignal(2, function()
					print("Or mix with the other signal!")
				end),
			workspace.Instance
		)
	)
	```
]=]
function ServerSignals:AddTimeoutSignal(Time: number, fn: (player: Player) -> ())
	table.insert(self.Listeners, { Type = "Timeout", Time = Time, Callback = fn })
	return self
end

--Searches for the message/choice and checks if there is callbacks (either TimeoutCallback, TriggerCallback). Calls them
local function UseCallbacks(
	plr: Player,
	Scan: PrivateTypes.Choice | PrivateTypes.Message | PrivateTypes.CreateChoicesTemplate | PrivateTypes.CreateMessageTemplate | PrivateTypes.CreateDialogueTemplate,
	PromiseTable: "MessagePromises" | "ChoicePromises" | "ChoiceTemplatePromises" | "MessageTemplatePromises" | "DialogueTemplatePromises"
)
	local Data = PlayersInDialogue[plr.Name]
	if Scan.Listeners then
		for _, Listener in ipairs(Scan.Listeners) do
			if Listener.Type == "Trigger" then
				Listener.Callback(plr)
			end
			if Listener.Type == "Timeout" then
				table.insert(
					Data[PromiseTable],
					Promise.delay(Listener.Time):andThen(function()
						Listener.Callback(plr)
					end)
				)
			end
		end
	end
end

--INTERNAL: Cancels all the promises in the table and making the table empty
local function CancelPromises(PromiseTable: {})
	for _, promise in ipairs(PromiseTable) do
		promise:cancel()
	end
	table.clear(PromiseTable)
end

local function Unreconcile(t: table, ...: string)
	for _, propertyName in ipairs({ ... }) do
		if t[propertyName] then
			t[propertyName] = nil
		end
	end
	return t
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
	local Data: PrivateTypes.ActivePlayerData = PlayersInDialogue[player.Name]
	if Data then
		CancelPromises(Data.ChoicePromises)
		CancelPromises(Data.ChoiceTemplatePromises)
		if Data.ExposeType == "Choice" then
			for _, Choice in ipairs(Data.CurrentClientDialogue.Choices.Data) do
				if Choice.UUID == UUID then
					UseCallbacks(player, Choice, "ChoicePromises")
					CancelPromises(Data.DialogueTemplatePromises)
					if Choice.Response then
						Data.CurrentClientDialogue = Choice.Response
						Data.CurrentClientMessage = 1
						Data.ExposeType = "Message"
						UseCallbacks(
							player,
							Data.CurrentClientDialogue.Message.Data[Data.CurrentClientMessage],
							"MessagePromises"
						)
						UseCallbacks(player, Data.CurrentClientDialogue.Message, "MessageTemplatePromises")
						UseCallbacks(player, Data.CurrentClientDialogue, "DialogueTemplatePromises")
						return Packet.ExposeMessage.sendTo({
							Head = Data.CurrentClientDialogue.Message.Data[Data.CurrentClientMessage].Head,
							Body = Data.CurrentClientDialogue.Message.Data[Data.CurrentClientMessage].Body,
						}, player)
					else
						PlayersInDialogue[player.Name] = nil
						return Packet.CloseDialogue.sendTo({}, player)
					end
				end
			end
		else
			player:Kick(`Anticheat: {script.Name}, {debug.info(1, "l")}`)
		end
	else
		player:Kick(`Anticheat: {script.Name}, {debug.info(1, "l")}`)
	end
end)

Packet.FinishedMessage.listen(function(_, player)
	local Data: PrivateTypes.ActivePlayerData = PlayersInDialogue[player.Name]
	if Data then
		CancelPromises(Data.MessagePromises)
		Data.CurrentClientMessage += 1
		local NextMessage: PrivateTypes.Message = Data.CurrentClientDialogue.Message.Data[Data.CurrentClientMessage]
		if Data.ExposeType == "Message" then
			if NextMessage then
				if Data.CurrentClientMessage == #Data.CurrentClientDialogue.Message + 1 then
					player:Kick(`Anticheat: {script.Name}, {debug.info(1, "l")}`)
				else
					UseCallbacks(player, NextMessage, "MessagePromises")
				end
				Packet.ExposeMessage.sendTo({ Head = NextMessage.Head, Body = NextMessage.Body }, player)
			else
				if Data.CurrentClientDialogue.Choices == nil then
					PlayersInDialogue[player.Name] = nil
					Packet.CloseDialogue.sendTo({}, player)
				else
					Data.ExposeType = "Choice"
					local Choices = TableUtil.Copy(Data.CurrentClientDialogue.Choices, true)
					for _, Choice: PrivateTypes.Choice in ipairs(Choices.Data) do
						Unreconcile(
							Choice,
							"Response",
							"_TimeoutTime",
							"_TimeoutCallback",
							"_TriggerCallback",
							"Listeners"
						)
					end
					CancelPromises(Data.MessageTemplatePromises)
					UseCallbacks(player, Data.CurrentClientDialogue.Choices, "ChoiceTemplatePromises")
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

--[=[
	@param Dialogue string -- hi
	@param Part Instance -- The instance where clients can trigger the dialogue
	@within DialogueServer
]=]
function DialogueServer.Mount(Dialogue: PrivateTypes.MountInfo, Part: Instance, CustomProximityPrompt: ProximityPrompt?)
	local ProximityPrompt = Instance.new("ProximityPrompt", Part)
	ProximityPrompt:AddTag("Dialogue")
	table.insert(MountedDialogues, {
		PPConnection = ProximityPrompt.TriggerEnded:Connect(function(player)
			PlayersInDialogue[player.Name] = {
				CurrentClientDialogue = Dialogue,
				CurrentClientMessage = 1,
				ExposeType = "Message",
				MessagePromises = {},
				ChoicePromises = {},
				ChoiceTemplatePromises = {},
				MessageTemplatePromises = {},
				DialogueTemplatePromises = {},
			}
			Packet.ExposeMessage.sendTo(
				{ Head = Dialogue.Message.Data[1].Head, Body = Dialogue.Message.Data[1].Body },
				player
			)
			local Data = PlayersInDialogue[player.Name]
			UseCallbacks(player, Data.CurrentClientDialogue.Message, "MessageTemplatePromises")
			UseCallbacks(player, Data.CurrentClientDialogue, "DialogueTemplatePromises")
		end),
	})
end

function DialogueServer.CreateDialogueTemplate(
	Message: PrivateTypes.CreateMessageTemplate,
	Choice: PrivateTypes.CreateChoicesTemplate
)
	local t = setmetatable({}, ServerSignals)
	t.Message = Message
	t.Choices = Choice
	t.Listeners = {}
	return t
end

function DialogueServer.CreateChoicesTemplate(ChoiceMessage: string, ...: PrivateTypes.Choice)
	assert(type(ChoiceMessage) == "string", "[Dialogue] Choice message is a string. ")
	local t = setmetatable({}, ServerSignals)
	t.Data = { ... }
	t.ChoiceMessage = ChoiceMessage
	t.Listeners = {}
	return t
end

function DialogueServer.CreateMessageTemplate(...: PrivateTypes.Message)
	local t = setmetatable({}, ServerSignals)
	t.Data = { ... }
	t.Listeners = {}
	return t
end

function DialogueServer.ConstructMessage(Head: string, Body: string)
	assert(Head, "[Dialogue] Empty or nil for Head. Please provide a string")
	assert(Body, "[Dialogue] Empty or nil for Head. Please provide a string.")
	local m = setmetatable({}, ServerSignals)
	m.Head = Head
	m.Body = Body
	m.Listeners = {}
	return m
end

function DialogueServer.ConstructChoice(ChoiceName: string, Response: PrivateTypes.CreateDialogueTemplate)
	assert(ChoiceName, "[Dialogue] Empty or nil for ChoiceName")
	local c = setmetatable({}, ServerSignals)
	c.ChoiceName = ChoiceName
	c.UUID = HttpService:GenerateGUID()
	c.Response = Response
	c.Listeners = {}
	return c
end

return DialogueServer :: PublicTypes.DialogueServer
