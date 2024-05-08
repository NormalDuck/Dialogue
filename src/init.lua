local RunService = game:GetService("RunService")
local PublicTypes = require(script.PublicTypes)

if RunService:IsServer() then
	require(script.DialogueServer)
else
	local DialogueServer = script:FindFirstChild("DialogueServer")
	if DialogueServer and RunService:IsRunning() then
		DialogueServer:Destroy()
	end
	require(script.DialogueClient)
end

return nil :: { DialogueClient: PublicTypes.DialogueClient, DialogueServer: PublicTypes.DialogueServer }
