local Timer = {}
local Promise = require(script.Parent.Core.Promise)

function Timer:After(Seconds: number, Callback: () -> ())
	task.wait(Seconds)
	return Promise.new(function(res, rej)
		local ok, given = pcall(Callback)
		return if ok then res(given) else rej(given)
	end)
end

function Timer:Every(Seconds: number, Callback: () -> true | nil)
	local Repeat = true
	while Repeat do
		local Arg = Callback()
		if Arg == true then break end
		task.wait(Seconds)
	end
end

return Timer
