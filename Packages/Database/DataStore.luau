local Service = game:GetService("DataStoreService")
local Promise = require(script.Parent.Parent.Core.Promise)
local DataStore = {}
DataStore.__index = DataStore

function DataStore.new(Name: string, Scope: string?, Options: Instance?)
	return setmetatable({ instance = Service:GetDataStore(Name, Scope, Options) }, DataStore)
end

function DataStore:Get(Key: string| number)
	assert(typeof(Key) == "string" or typeof(Key) == "number", "Invalid Key type, expected string or number, gotten [" .. typeof(Key) .. "]!")
	Key = tostring(Key)
	return Promise.new(function(resolve, reject)
		local ok, given = pcall(self.instance.GetAsync, self.instance, Key)
		return if ok then resolve(given) else reject(given)
	end)
end

function DataStore:Set(Key: string| number, Data: {} | boolean | number)
	assert(typeof(Key) == "string" or typeof(Key) == "number", "Invalid Key type, expected string or number, gotten [" .. typeof(Key) .. "]!")
	assert(typeof(Data) == "table" or type(Data) == "boolean" or type(Data) == "number", "Invalid Data type, expected table or boolean or number, gotten [" .. typeof(Data) .. "]!")
	Key = tostring(Key)
	return Promise.new(function(resolve, reject)
		local ok, err = pcall(self.instance.SetAsync, self.instance, Key, Data)
		return if not ok then reject(err) else resolve(true)
	end)
end

function DataStore:Remove(Key: string | number)
	assert(typeof(Key) == "string" or typeof(Key) == "number", "Invalid Key type, expected string or number, gotten [" .. typeof(Key) .. "]!")
	Key = tostring(string)
	return Promise.new(function(resolve, reject)
		local ok, err = pcall(self.instance.RemoveAsync, self.instance, Key)
		return if not ok then reject(err) else resolve(true)
	end)
end

function DataStore:ListDataStorePagesAsync()
	return self.instance:ListKeysAsync()
end

function DataStore:GetKeysAndValuesFromDataStoreAsync(requestPages: number?)
	local KeysPages = self:ListDataStorePagesAsync()
	local List = {}
	
	local function CheckKey(Key: string)
		return self:Get(Key):andThen(function(Value)
			List[Key] = Value
		end)
	end
	
	for i = 1, (requestPages or 1) do
		local ok, given = pcall(function()
			for _, Key in pairs(KeysPages:GetCurrentPage()) do
				CheckKey(Key.KeyName)
			end
		end)
		
		if KeysPages.IsFinished then break end
		if not ok then
			warn("Cancelled the requestPages loop, reason:\n" .. given)
			break
		else
			KeysPages:AdvanceToNextPageAsync()
		end
	end
	
	return List
end

return DataStore
