local DevTools = {}
local Status = {
	['Success'] = "✅",
	['Warning'] = "⚠️",
	['Error'] = "❌"
}

function DevTools:Log(Status: "Success" | "Warning" | "Error", Name: string, ...)
	return print(
		string.format("[%s] [%s]: %s", Name, Status, ...)
	)
end

function DevTools:ProtectedCall(callback, ...)
	local Data = table.pack(...)
	return self.Promise.new(function(res, rej)
		local ok, given = pcall(callback, table.unpack(Data))
		return if ok then res(given) else rej(given)
	end)
end

return setmetatable(DevTools, require(script.Parent.Core))
