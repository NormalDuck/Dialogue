local defer = require(script.Parent.defer)

local function ObserveSignal<T>(signal: RBXScriptSignal<T>, callback: (value: T?, ...any) -> ...any, ...)
	local connection = signal:Connect(defer(callback, ...))
	return function()
		connection:Disconnect()
	end
end

return ObserveSignal
