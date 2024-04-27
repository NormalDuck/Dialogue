local unwrap = require(script.Parent.unwrap)

local function With(source)
	return function(with)
		local destination = table.clone(unwrap(source))
		if type(with) == "table" then
			for index, value in pairs(unwrap(with)) do
				destination[index] = value
			end
		end
		return destination
	end
end

return With