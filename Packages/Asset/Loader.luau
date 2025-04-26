local Loader = {}
local ContentProvider = game:GetService("ContentProvider")
local InstanceAssist = require(script.Parent.Parent.GUI)

Loader.__index = Loader
function Loader.new()
	local self = {}
	self.Objects = {}
	self.Done = 0
	self._Skip = false
	return setmetatable(self, Loader)
end

function Loader:AddItemAsync(item: Animation | Decal | Texture | ImageLabel | ImageButton | Sound | MeshPart)
	local Object = item
	
	if typeof(item) == "Instance" then
		if item:IsA("Animation") then
			Object = InstanceAssist.CreateInstance(item.Name, "Animation", { AnimationId = item.AnimationId })
		elseif item:IsA("Decal") or item:IsA("Texture") then
			Object = InstanceAssist.CreateInstance(item.Name, item.ClassName, { Texture = item.Texture })
		elseif item:IsA("ImageButton") or item:IsA("ImageLabel") then
			Object = InstanceAssist.CreateInstance(item.Name, item.ClassName, { Image = item.Image })
		elseif item:IsA("Sound") then
			Object = InstanceAssist.CreateInstance(item.Name, item.ClassName, { SoundId = item.SoundId })
		elseif item:IsA("MeshPart") then
			Object = InstanceAssist.CreateInstance(item.Name, item.ClassName, { MeshId = item.MeshId })
		end
	end
	
	table.insert(self.Objects, Object)
end

function Loader:AddItemsAsync(items: {})
	for _, v in pairs(items) do
		table.insert(self.Objects, v)
	end
end

function Loader:BeginPreloading(callback: (Percentage: number, AssetFetchStatus: Enum.AssetFetchStatus) -> ())
	local AlreadyDone = false
	return ContentProvider:PreloadAsync(self['Objects'], function(_, assetFetchStatus)
		if self._Skip == true and not AlreadyDone then
			self.Done = #self.Objects
			AlreadyDone = true
			return callback(100, Enum.AssetFetchStatus.Success)
		end
		
		self.Done = self.Done + 1
		local Percentage = (self.Done / #self.Objects) * 100
		return callback(Percentage, assetFetchStatus)
	end)
end

function Loader:Skip()
	self._Skip = true
end

return Loader
