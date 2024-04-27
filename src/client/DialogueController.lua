--!native
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)

local e = React.createElement
local DialogueController = Knit.CreateController({ Name = "DialogueController", Dialogues = {} })
local DialogueRoot = ReactRoblox.createRoot(Instance.new("ScreenGui", Players.LocalPlayer.PlayerGui))

--Provides the basic theme of the Dialogue. For further customaztions just edit the render
local ThemeContext = React.createContext({
	Font = Enum.Font.SourceSans,
})

function DialogueController:KnitInit()
	local function OptionComponent(props: { OptionName: string, UUID: string })
		local FONT = React.useContext(ThemeContext).Font
		local DialogueService = Knit.GetService("DialogueService")

		return e("TextButton", {
			Visible = true,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.fromScale(1, 0.35),
			TextColor3 = Color3.new(1, 1, 1),
			Font = FONT,
			TextScaled = true,
			Text = props.OptionName,
			BackgroundColor3 = Color3.new(0.066666, 0.066666, 0.066666),
			BackgroundTransparency = 0.5,
			[React.Event.Activated] = function()
				DialogueService.FinishedInfo:Fire(props.UUID)
			end,
		}, e("UICorner", { CornerRadius = UDim.new(0.2) }))
	end
	local TextReconcile = {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		TextColor3 = Color3.new(1, 1, 1),
		TextScaled = true,
	}

	local function Dialogue()
		local DialogueService = Knit.GetService("DialogueService")
		local IsTextEngineFinished, SetIsTextEngineFinished = React.useBinding(false)
		local HeadTextRef = React.useRef(nil)
		local BodyTextRef = React.useRef(nil)
		local ClickRef = React.useRef(nil)
		local IncommingData, SetIncommingData = React.useState(nil)
		local CurrentMessage, SetCurrentMessage = React.useState(nil)
		local DialogueState, SetDialogueState =
			React.useState(false :: false | "EngineRunning" | "EngineFinished" | "Options")

		React.useEffect(function()
			local ServerCloseDialogueConnection: RBXScriptConnection
			local ExposeInformationConnection: RBXScriptConnection
			ServerCloseDialogueConnection = DialogueService.ServerCloseDialogue:Connect(function()
				SetDialogueState(false)
			end)
			ExposeInformationConnection = DialogueService.ExposeInformation:Connect(function(SentData, Type)
				SetIncommingData(SentData)
				if Type == "Message" then
					for _, Message in SentData do
						SetDialogueState("EngineRunning")
						SetIsTextEngineFinished(false)
						SetCurrentMessage(Message)
						while BodyTextRef.current == nil do
							task.wait() --This yields until the ref is assigned. Probably in one frame.
						end
						HeadTextRef.current.Text = Message.Head
						BodyTextRef.current.Text = ""
						for i = 1, string.len(Message.Body) do
							if IsTextEngineFinished:getValue() then
								break
							end
							BodyTextRef.current.Text = string.sub(Message.Body, 1, i)
							task.wait(0.03)
						end
						SetIsTextEngineFinished(true)
						SetDialogueState("EngineFinished")
						ClickRef.current.Activated:Wait()
						task.wait()
						DialogueService.FinishedMessage:Fire()
					end
				end
				if Type == "Options" then
					SetDialogueState("Options")
					SetIncommingData(SentData)
				end
			end)

			return function()
				ExposeInformationConnection:Disconnect()
				ServerCloseDialogueConnection:Disconnect()
			end
		end)

		if DialogueState == "Options" then
			local OptionsTable = {}
			for _, Choice in ipairs(IncommingData.Data) do
				table.insert(OptionsTable, e(OptionComponent, { OptionName = Choice.ChoiceName, UUID = Choice.UUID }))
			end
			return e("ImageButton", {
				BackgroundTransparency = 0.5,
				Size = UDim2.fromScale(0.625, 0.345),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.8),
				BackgroundColor3 = Color3.new(0, 0, 0),
			}, {
				e("ScrollingFrame", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.618),
					Size = UDim2.fromScale(0.975, 0.684),
					AutomaticCanvasSize = Enum.AutomaticSize.Y,
					ScrollBarThickness = 0.01,
					BackgroundTransparency = 1,
					BackgroundColor3 = Color3.new(0.5, 0.5, 0.5),
					CanvasSize = UDim2.fromScale(0, 0),
				}, {
					e("UIListLayout", { Padding = UDim.new(0.05) }),
					OptionsTable,
				}),

				--option message
				e(
					"TextLabel",
					TableUtil.Reconcile({
						Size = UDim2.fromScale(0.85, 0.27),
						Position = UDim2.fromScale(0.5, 0.13),
						Text = IncommingData.OptionMessage or "",
					}, TextReconcile)
				),

				e("UIAspectRatioConstraint", {
					AspectRatio = 3.957,
				}),
				e("UICorner", {
					CornerRadius = UDim.new(0.03),
				}),
			})
		end

		if DialogueState == "EngineRunning" then
			return e("ImageButton", {
				BackgroundTransparency = 0.5,
				Size = UDim2.fromScale(0.625, 0.345),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.8),
				BackgroundColor3 = Color3.new(0, 0, 0),
				ref = ClickRef,
				[React.Event.Activated] = function()
					BodyTextRef.current.Text = CurrentMessage.Body
					SetDialogueState("EngineFinished")
					SetIsTextEngineFinished(true)
				end,
			}, {
				e("ImageLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.12, 0.495),
					Size = UDim2.fromScale(0.176, 00.7),
				}, { e("UICorner", {
					CornerRadius = UDim.new(0.03),
				}) }),

				--Head text
				e(
					"TextLabel",
					TableUtil.Reconcile({
						Size = UDim2.fromScale(0.745, 0.28),
						Position = UDim2.fromScale(0.605, 0.2),
						ref = HeadTextRef,
					}, TextReconcile)
				),

				--Body text
				e(
					"TextLabel",
					TableUtil.Reconcile({
						Size = UDim2.fromScale(0.745, 0.46),
						Position = UDim2.fromScale(0.605, 0.57),
						ref = BodyTextRef,
					}, TextReconcile)
				),

				e("UIAspectRatioConstraint", {
					AspectRatio = 3.957,
				}),
				e("UICorner", {
					CornerRadius = UDim.new(0.03),
				}),
			})
		end

		if DialogueState == "EngineFinished" then
			return e("ImageButton", {
				BackgroundTransparency = 0.5,
				Size = UDim2.fromScale(0.625, 0.345),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.8),
				BackgroundColor3 = Color3.new(0, 0, 0),
				ref = ClickRef,
			}, {
				e("ImageLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.12, 0.495),
					Size = UDim2.fromScale(0.176, 00.7),
				}, { e("UICorner", {
					CornerRadius = UDim.new(0.03),
				}) }),

				--head
				e(
					"TextLabel",
					TableUtil.Reconcile({
						Size = UDim2.fromScale(0.745, 0.28),
						Position = UDim2.fromScale(0.605, 0.2),
						Text = CurrentMessage.Head,
					}, TextReconcile)
				),

				--Body text
				e(
					"TextLabel",
					TableUtil.Reconcile({
						Size = UDim2.fromScale(0.745, 0.46),
						Position = UDim2.fromScale(0.605, 0.57),
						Text = CurrentMessage.Body,
					}, TextReconcile)
				),

				--click to continue
				e(
					"TextLabel",
					TableUtil.Reconcile({
						Text = "Click to continue...",
						Size = UDim2.fromScale(0.225, 0.15),
						Position = UDim2.fromScale(0.865, 0.875),
					}, TextReconcile)
				),

				e("UIAspectRatioConstraint", {
					AspectRatio = 3.957,
				}),
				e("UICorner", {
					CornerRadius = UDim.new(0.03),
				}),
			})
		end
	end
	DialogueRoot:render(e(Dialogue))
end

return DialogueController
