local function Bind(callback, ...)
	local bound = table.pack(...)
	return function(...)
		local extra = table.pack(...)
		return callback(table.unpack(table.move(extra, 1, extra.n, bound.n + 1, table.clone(bound)), 1, bound.n + extra.n))
	end
end

return Bind