--!native


local DialogueClient = {}

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)
local LemonSignal = require(ReplicatedStorage.Packages.LemonSignal)
local Packet = require(script.Parent:WaitForChild("packet"))
local PublicTypes = require(script.Parent:WaitForChild("PublicTypes"))

DialogueClient.CloseDialgoue = LemonSignal.new()
DialogueClient.OpenDialogue = LemonSignal.new()
DialogueClient.ChoiceChosen = LemonSignal.new()
DialogueClient.SwitchToChoice = LemonSignal.new()
DialogueClient.NextMessage = LemonSignal.new()

local New = Fusion.New
local Children = Fusion.Children
local Value = Fusion.Value
local Computed = Fusion.Computed
local OnEvent = Fusion.OnEvent

--States--
local DialogueState = Value(false)
local Head = Value("")
local Body = Value("")
local ChoiceMessage = Value("")
local Choices = Value(nil)

--BYTENET EVENT LISTENERS--
Packet.ExposeMessage.listen(function(Message)
	ProximityPromptService.Enabled = false
	DialogueState:set("Message")
	Head:set(Message.Head)
	Body:set(Message.Body)
	DialogueClient.NextMessage:Fire()
end)

Packet.ExposeChoice.listen(function(ChoiceData)
	Choices:set(ChoiceData.Choices)
	ChoiceMessage:set(ChoiceData.ChoiceMessage)
	DialogueState:set("Choice")
	DialogueClient.SwitchToChoice:Fire()
end)

Packet.CloseDialogue.listen(function()
	DialogueState:set(false)
	ProximityPromptService.Enabled = true
	DialogueClient.CloseDialgoue:Fire()
end)
--BYTENET EVENT LISTENERS END--

ProximityPromptService.PromptTriggered:Connect(function(prompt)
	if CollectionService:HasTag(prompt, "Dialogue") then
		ProximityPromptService.Enabled = false
		DialogueClient.OpenDialogue:Fire()
	end
end)

local StyleProps = {
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundTransparency = 0.3,
	BackgroundColor3 = Color3.new(0, 0, 0),
	TextColor3 = Color3.new(1, 1, 1),
	TextScaled = true,
	Font = Enum.Font.BuilderSans,
}

function DialogueClient.GetDialogueState()
	return DialogueState:get()
end

function DialogueClient.GetMessage()
	assert(DialogueState:get() == "Message", "[Dialgoue] Cannot get message in other states.")
	return Head:get(), Body:get()
end

function DialogueClient.GetChoices()
	assert(DialogueState:get() == "Choice", "[Dialogue] Cannot get choices in other states.")
	return Choices:get()
end

New("ScreenGui")({
	Parent = Players.LocalPlayer.PlayerGui,
	Enabled = Computed(function()
		return DialogueState:get() ~= false
	end),
	[Children] = {
		New("ImageButton")({
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 0.3,
			BackgroundColor3 = Color3.new(0, 0, 0),
			Size = UDim2.fromOffset(275, 100),
			Position = UDim2.fromScale(0.5, 0.75),
			[OnEvent("Activated")] = function()
				if DialogueState:get() == "Message" then
					Packet.FinishedMessage.send()
				end
			end,
			[Children] = {
				New("UIAspectRatioConstraint")({
					AspectRatio = 2.854,
				}),
				--Head
				New("TextLabel")(TableUtil.Reconcile({
					Size = UDim2.fromScale(1, 0.3),
					Position = UDim2.fromScale(0.5, 0.15),
					BackgroundTransparency = 1,
					Text = Computed(function()
						if DialogueState:get() == "Message" then
							return Head:get()
						elseif DialogueState:get() == "Choice" then
							return ChoiceMessage:get()
						else
							return ""
						end
					end),
					Visible = Computed(function()
						return DialogueState:get()
					end),
				}, StyleProps)),
				--Body
				New("TextLabel")(TableUtil.Reconcile({
					Size = UDim2.fromScale(1, 0.7),
					Position = UDim2.fromScale(0.5, 0.65),
					BackgroundTransparency = 1,
					Text = Computed(function()
						return Body:get()
					end),
					Visible = Computed(function()
						return DialogueState:get() == "Message"
					end),
				}, StyleProps)),
				New("ScrollingFrame")({
					Visible = Computed(function()
						return DialogueState:get() == "Choice"
					end),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Size = UDim2.fromScale(1, 0.7),
					Position = UDim2.fromScale(0.5, 0.65),
					AutomaticCanvasSize = Enum.AutomaticSize.Y,
					ScrollBarThickness = 0.01,
					BackgroundTransparency = 1,
					CanvasSize = UDim2.fromScale(0, 0),
					[Children] = Computed(function()
						if DialogueState:get() == "Choice" then
							local ChoicesInstance = {}
							for _, Choice: { ChoiceName: string, UUID: string } in ipairs(Choices:get()) do
								table.insert(
									ChoicesInstance,
									New("TextButton")(TableUtil.Reconcile({
										Size = UDim2.fromScale(1, 0.35),
										Text = Choice.ChoiceName,
										BackgroundColor3 = Color3.new(0, 0, 0),
										[OnEvent("Activated")] = function()
											Packet.ChoiceChosen.send({ UUID = Choice.UUID })
											DialogueClient.ChoiceChosen:Fire()
										end,
									}, StyleProps))
								)
							end
							table.insert(ChoicesInstance, New("UIListLayout")({ Padding = UDim.new(0.05) }))
							return ChoicesInstance
						else
							return nil
						end
					end),
				}),
			},
		}),
	},
})

return DialogueClient :: PublicTypes.DialogueClient
