local Observe = require(script.Parent.Observe)

local Attribute = {
	type = "SpecialKey";
	kind = "Attribute";
	stage = "self";

	apply = function(self, value, applyTo, cleanupTasks)
		local attribute = self.attribute

		if type(value) == "table" and value.get then
			table.insert(cleanupTasks, Observe(value, function(newValue)
				applyTo:SetAttribute(attribute, newValue)
			end))
		else
			applyTo:SetAttribute(attribute, value)
		end
	end;
}
Attribute.__index = Attribute

return function(attribute: string)
	return setmetatable({ attribute = attribute; }, Attribute)
end
