local defer = require(script.Parent.defer)

local AttributeOut = {
	type = "SpecialKey";
	kind = "AttributeOut";
	stage = "self";

	apply = function(self, value, applyTo, cleanupTasks)
		local attribute = self.attribute
		table.insert(cleanupTasks, applyTo:GetAttributeChangedSignal(attribute):Connect(defer(function()
			value:set(applyTo:GetAttribute(attribute))
		end)))
	end;
}
AttributeOut.__index = AttributeOut

return function(attribute: string)
	return setmetatable({ attribute = attribute; }, AttributeOut)
end
