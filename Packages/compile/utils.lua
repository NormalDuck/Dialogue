--!native
local utils = {}
local RenderStepped = game:GetService("RunService").Heartbeat

--[[
	Module made by duck. A collection of utilities that may be helpful in certain aeras.
]]

--[[Utilizes `RunService.Heartbeat` for waiting. Normally used for small amounts of waits.
\
**May not be accurate as `task.wait` if frames are slow**
\
Please do not use this to yield for 1s+, as it may result in script timeout]]
function utils.QuickWait(n: number)
	local startTime = os.clock()
	local currentTime = os.clock()
	while os.clock() - startTime <= n do
		if os.clock() - currentTime >= 0.01 then
			RenderStepped:Wait()
			currentTime = os.clock()
		end
	end
end

--[[Performs a scan to the table. If there are same values. **Does not recursively search for dupes**]]
function utils.RemoveTableDupes(t: table)
	local hash = {}
	local res = {}
	for _, v in ipairs(t) do
		if not hash[v] then
			res[#res + 1] = v
			hash[v] = true
		end
	end
	return res
end

--[[Returns the length of a key/value table.]]
function utils.DictLength(t: table): number
	local n = 0
	for _ in pairs(t) do
		n = n + 1
	end
	return n
end
--[[Checks if the given number is odd or even]]
function utils.OddOrEven(n: number): "Odd" | "Even"
	if n % 2 == 0 then
		return "Even"
	else
		return "Odd"
	end
end

--[[Checks for key/value (dictionary) table. Removes the key provided. Opposite of Reconcile]]
function utils.Unreconcile(t: table, ...: string)
	for _, propertyName in ipairs({ ... }) do
		if t[propertyName] then
			t[propertyName] = nil
		end
	end
	return t
end
return utils
