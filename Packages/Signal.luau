local Signal = {}
Signal.__index = Signal

function Signal.new()
	local self = {}
	self._connections = {}
	return setmetatable(self, Signal)
end

function Signal:Connect(callback: (...any) -> ())
	local a = {}
	local con = callback
	table.insert(self._connections, con)
	
	function a:Disconnect()
		table.remove(self._connections, table.find(self._connections, con))
	end
	
	return a
end

function Signal:Destroy()
	for _, connection in ipairs(self._connections) do
		connection = nil
	end
	
	table.clear(self._connections)
	table.clear(self)
end

function Signal:Fire(...)
	for _, connection in ipairs(self._connections) do
		task.spawn(connection, ...)
	end
end

return Signal
