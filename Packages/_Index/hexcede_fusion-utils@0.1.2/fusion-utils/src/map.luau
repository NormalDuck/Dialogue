local Fusion = require(script.Parent.Parent.Fusion)
local Computed = Fusion.Computed

local function map(state, callback)
	if type(state) == "table" and type(state.get) == "function" then
		return Computed(function()
			return callback(state:get())
		end)
	end

	return callback(state)
end

return map