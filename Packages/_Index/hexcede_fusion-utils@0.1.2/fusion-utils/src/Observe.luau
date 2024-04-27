local Fusion = require(script.Parent.Parent.Fusion)
local Observer = Fusion.Observer

local defer = require(script.Parent.defer)

local function Observe<T, Args...>(stateObject: Fusion.StateObject<T>, callback: (value: T, Args...) -> ...any, ...)
	local extraArguments = table.pack(...)
	local function handleChange()
		callback(stateObject:get(), table.unpack(extraArguments, 1, extraArguments.n))
	end

	return Observer(stateObject):onChange(defer(handleChange))
end

return Observe