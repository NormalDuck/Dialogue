local ChildRef = {
	type = "SpecialKey";
	kind = "ChildRef";
	stage = "descendants";

	apply = function(self, value, applyTo, cleanupTasks)
		local childName = self.childName

		if not applyTo then return end

		value:set(applyTo:FindFirstChild(childName))
		table.insert(cleanupTasks, applyTo.ChildAdded:Connect(function(newChild)
			if newChild.Name == childName then
				value:set(newChild)
			end
		end))
	end;
}
ChildRef.__index = ChildRef

return function(childName: string)
	return setmetatable({ childName = childName; }, ChildRef)
end
