local function defer(callback, ...)
	task.defer(callback, ...)
	return callback
end

return defer