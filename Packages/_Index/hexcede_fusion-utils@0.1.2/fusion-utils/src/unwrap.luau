local Fusion = require(script.Parent.Parent.Fusion)

local function unwrap<T>(value: Fusion.CanBeState<T>, default: T?): T
	if type(value) == "table" and type(value.get) == "function" then
		return value:get()
	end
	return if value == nil then default :: T else value :: T
end

return unwrap