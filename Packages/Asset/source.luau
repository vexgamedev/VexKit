local Asset = {}

local ContentProvider = game:GetService("ContentProvider")
local Promise = require(script.Parent.Core.Promise)

Asset.Loader = require(script.Loader)

function Asset:PreloadAsync(Data: {Instance | any}, Callback: (AssetId: string, Status: Enum.AssetFetchStatus) -> ())
	local AssetId, Status = "rbxassetid://0", Enum.AssetFetchStatus.TimedOut
	
	ContentProvider:PreloadAsync(Data, function(AI, S)
		AssetId, Status = AI, S
		return Callback(AssetId, Status)
	end)
	
	return Promise.new(function(res, rej)
		if not AssetId or not Status then
			rej("Failed to preload")
			return
		end
		
		if Status == Enum.AssetFetchStatus.Success then
			res(AssetId)
		else
			rej("Failed to preload [gotten status: [" .. tostring(Status) .. "]]")
		end
	end)
end

return Asset
