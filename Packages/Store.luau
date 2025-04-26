local Store = {}
Store.__index = Store

function Store.new(reducer: (previousState: any, action: any?) -> (), default: any?): Store
	local self = {}
	self._reducer = reducer or nil
	self._subscriptions = {}
	self._state = default or nil
	return setmetatable(self, Store)
end

function Store:subscribe(callback: (state: any) -> ())
	table.insert(self._subscriptions, callback)
end

function Store:dispatch(...)
	local newState = self._reducer(self._state, ...)
	self._state =  newState
	for _, v in ipairs(self._subscriptions) do
		v(self._state)
	end
end

function Store:getState()
	return self._state
end

export type Store = typeof(Store.new(function() end))
return Store
