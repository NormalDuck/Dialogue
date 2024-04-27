--!native

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local New = Fusion.New
local Children = Fusion.Children
local Value = Fusion.Value
local Computed = Fusion.Computed
local Observer = Fusion.Observer

return function(props: {})
	New("ImageButton")({
		BackgroundTransparency = 0.5,
		Size = UDim2.fromScale(0.625, 0.345),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.8),
		BackgroundColor3 = Color3.new(0, 0, 0),
        Observer()
	})
end

--[[
    e("ImageButton", {
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
]]
