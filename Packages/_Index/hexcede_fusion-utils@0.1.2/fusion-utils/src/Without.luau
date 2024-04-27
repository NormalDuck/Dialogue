local unwrap = require(script.Parent.unwrap)

local function Without(source)
	return function(with)
		local destination = table.clone(unwrap(source))
		if type(with) == "table" then
			for _, index in ipairs(unwrap(with)) do
				destination[index] = nil
			end
		end
		return destination
	end
end

return Without