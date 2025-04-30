local Net = { XOR = require(script.XOR) }
local Promise = require(script.Parent.Core.Promise)
local HttpService = game:GetService("HttpService")

if not script:GetAttribute("NAME") then
	script:SetAttribute("NAME", math.random(12, 54))
end

if not script:GetAttribute("ARG") then
	script:SetAttribute("ARG", math.random(12, 54))
end

export type Callback = (Player, ...any) -> ()
local KeyName = script:GetAttribute("NAME")
local KeyArg = script:GetAttribute("ARG")

function Net.CreateRemote(Name: string, Callback: Callback?): RemoteFunction
	local Remote = Instance.new("RemoteFunction", script)
	Remote.Name = Net.XOR:DoIt(Name, KeyName)
	Remote.OnServerInvoke = if typeof(Callback) == "function" then Callback else function() end
	return Remote
end

function Net:Subscribe(Name: string, Callback: Callback)
	if game:GetService("RunService"):IsClient() then
		local Remote: RemoteFunction? = script:FindFirstChild(Net.XOR:DoIt(Name, KeyName))
		if Remote then
			Remote.OnClientInvoke = Callback
		end
		return
	end
	
	local DecryptedCallback = function(Player: Player, _, Data: buffer, Length: number)
		if typeof(Data) == "buffer" and typeof(Length) == "number" then
			local ok, given = pcall(buffer.readstring, Data, 0, Length)
			if ok then
				given = Net.XOR:DoIt(given, KeyArg)
				local ok2, given2 = pcall(HttpService.JSONDecode, HttpService, given)
				if ok2 then
					return Callback(Player, given2)
				end
			end
		end
	end
	
	local Remote = { instance = self.CreateRemote(Name, DecryptedCallback) :: RemoteFunction }
	
	function Remote:Request(Player: Player?, TimeOut: number?, Interval: number?, ...)
		local Data = table.pack(...)
		TimeOut = TimeOut or 15
		Interval = Interval or 0.5
		return Promise.new(function(res, rej)
			local FetchedData
			task.spawn(function()
				FetchedData = table.pack(self.instance:InvokeClient(Player, table.unpack(Data)))
			end)
			
			local a = 0
			repeat
				a = a + 1
				task.wait(Interval)
			until a > TimeOut or FetchedData ~= nil
			
			if FetchedData == nil then
				return rej("Server request to player has been timed out (due to lag or exploits) [THIS IS NOT A Vex.Net ISSUE]")
			end
			
			-- no way guys im so good at packing and unpacking tables 🤯
			return res(table.unpack(FetchedData))
		end)
	end
	
	function Remote:Destroy()
		Remote.instance:Destroy()
	end
	
	return Remote
end

function Net:Request(Name: string, ...)
	local Data = table.pack((...)or{})
	assert(typeof(Name) == "string", "Name is a improper type [Expected string, gotten [" .. typeof(Name) .. "]]")
	Name = Net.XOR:DoIt(Name, KeyName)
	return Promise.new(function(res, rej)
		local Remote: RemoteFunction? = script:FindFirstChild(Name)
		if Remote and Remote:IsA("RemoteFunction") then
			--print('Found remote:', Remote:GetFullName())
			local ok, given = pcall(HttpService.JSONEncode, HttpService, table.unpack(Data))
			if ok then
				given = Net.XOR:DoIt(given, KeyArg)
				--print("Encrypted arguments:", given)
				local SendData = buffer.create(#given)
				buffer.writestring(SendData, 0, given, #given)
				--print("Buffer with arguments:", SendData)
				return res(
					Remote:InvokeServer(
						"\000", SendData, #given
					)
				)
			else
				return rej("Failed parsing the given data into a JSON table! [Make sure the given argument is a table]")
			end
		else
			return rej("Requested remote [" .. Name .. "] wasn't found, create one on the serverside or check if you typed its name correctly")
		end
	end)
end

return Net
