-- Promise.lua || @vexgamedev
-- Decent code ahead

local Promise = {}
Promise.__index = Promise

Promise.Status = {
	Pending = "Pending",
	Fulfilled = "Fulfilled",
	Rejected = "Rejected",
}

function Promise.new(executor)
	local self = setmetatable({}, Promise)
	self._status = Promise.Status.Pending
	self._value = nil
	self._fulfilled = {}
	self._rejected = {}
	self._final = {}

	local function resolve(value)
		if self._status ~= Promise.Status.Pending then return end
		self._status = Promise.Status.Fulfilled
		self._value = value
		for _, cb in ipairs(self._fulfilled) do cb(value) end
		for _, cb in ipairs(self._final) do cb() end
	end

	local function reject(reason)
		if self._status ~= Promise.Status.Pending then return end
		self._status = Promise.Status.Rejected
		self._value = reason
		for _, cb in ipairs(self._rejected) do cb(reason) end
		for _, cb in ipairs(self._final) do cb() end
	end

	coroutine.wrap(function()
		if not executor then return nil end
		local ok, err = pcall(function()
			executor(resolve, reject)
		end)
		if not ok then
			reject(err)
		end
	end)()

	return self
end

function Promise:andThen(onFulfilled)
	return Promise.new(function(resolve, reject)
		local function handle(value)
			local ok, result = pcall(onFulfilled, value)
			if ok then resolve(result) else reject(result) end
		end

		if self._status == Promise.Status.Fulfilled then
			handle(self._value)
		elseif self._status == Promise.Status.Pending then
			table.insert(self._fulfilled, handle)
		end
	end)
end

function Promise:catch(onRejected)
	return Promise.new(function(resolve, reject)
		local function handle(reason)
			local ok, result = pcall(onRejected, reason)
			if ok then resolve(result) else reject(result) end
		end

		if self._status == Promise.Status.Rejected then
			handle(self._value)
		elseif self._status == Promise.Status.Pending then
			table.insert(self._rejected, handle)
		end
	end)
end

function Promise:finally(onFinally)
	if self._status ~= Promise.Status.Pending then
		pcall(onFinally)
	else
		table.insert(self._final, onFinally)
	end
	return self
end

-- Static: Promise.resolve(value)
function Promise.resolve(value)
	return Promise.new(function(resolve)
		resolve(value)
	end)
end

-- Static: Promise.reject(reason)
function Promise.reject(reason)
	return Promise.new(function(_, reject)
		reject(reason)
	end)
end

-- Static: Promise.all(promises)
function Promise.all(promises)
	return Promise.new(function(resolve, reject)
		local results = {}
		local completed = 0

		for i, p in ipairs(promises) do
			p:andThen(function(value)
				results[i] = value
				completed += 1
				if completed == #promises then
					resolve(results)
				end
			end):catch(function(reason)
				reject(reason)
			end)
		end
	end)
end

-- Static: Promise.race(promises)
function Promise.race(promises)
	return Promise.new(function(resolve, reject)
		for _, p in ipairs(promises) do
			p:andThen(resolve):catch(reject)
		end
	end)
end

return Promise
