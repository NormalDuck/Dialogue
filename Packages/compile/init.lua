local RunService = game:GetService("RunService")

if RunService:IsServer() then
	return require(script.DialogueServer)
else
	local DialogueServer = script:FindFirstChild("DialogueServer")
	if DialogueServer and RunService:IsRunning() then
		DialogueServer:Destroy()
	end

	return require(script.DialogueClient)
end
