local RunService = game:GetService("RunService")

if not RunService:IsServer() then
	local DialogueServer = script:FindFirstChild("DialogueServer")
	if DialogueServer and RunService:IsRunning() then
		DialogueServer:Destroy()
	end
end

return { DialogueClient = require(script.DialogueClient), DialogueServer = require(script.DialogueServer) }
