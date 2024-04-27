local unwrap = require(script.Parent.unwrap)

local function WithItems(source)
	return function(with)
		local destination = table.clone(unwrap(source))
		if type(with) == "table" then
			local withUnwrapped = unwrap(with)
			table.move(withUnwrapped, 1, #withUnwrapped, #destination + 1, destination)
		end
		return destination
	end
end

return WithItems