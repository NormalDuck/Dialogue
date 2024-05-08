local RunService = game:GetService("RunService")
local PublicTypes = require(script.PublicTypes)

if RunService:IsServer() then
	return require(
			script.DialogueServer
		) :: { DialogueClient: PublicTypes.DialogueClient, DialogueServer: PublicTypes.DialogueServer }
else
	local DialogueServer = script:FindFirstChild("DialogueServer")
	if DialogueServer and RunService:IsRunning() then
		DialogueServer:Destroy()
	end
	return require(
			script.DialogueClient
		) :: { DialogueClient: PublicTypes.DialogueClient, DialogueServer: PublicTypes.DialogueServer }
end
