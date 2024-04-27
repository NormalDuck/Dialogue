local Fusion = require(script.Parent.Parent.Fusion)

local Value = Fusion.Value
local Hydrate = Fusion.Hydrate
local Cleanup = Fusion.Cleanup

local ChildRef = require(script.Parent.ChildRef)
local Observe = require(script.Parent.Observe)

local Child = {
	type = "SpecialKey";
	kind = "Child";
	stage = "descendants";

	apply = function(self, value, applyTo, cleanupTasks)
		local childRef = Value()
		Hydrate(applyTo) {
			[ChildRef(self.childName)] = childRef
		}

		local isHydrated = {}
		local result = Observe(childRef, function(child)
			if not child then return end
			if isHydrated[child] then return end
			isHydrated[child] = true

			-- Bind to child
			Hydrate(child)(value)

			-- Bind to cleanup of child
			Hydrate(child) {
				[Cleanup] = function()
					isHydrated[child] = nil
				end;
			}
		end)

		table.insert(cleanupTasks, result)
		table.insert(cleanupTasks, function()
			childRef = nil
		end)
	end;
}
Child.__index = Child

return function(childName: string)
	return setmetatable({ childName = childName; }, Child)
end
