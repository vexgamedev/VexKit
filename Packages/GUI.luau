-- GUI || @vexgamedev
-- Some high-tech advanced stuff, would recommend if you want to make your code longer

local GUI = {}
GUI.__index = GUI

function GUI._IsVexGUIMade(Object: any)
	if typeof(Object) == "table" and Object.instance ~= nil and typeof(Object.instance) == "Instance" then
		return true
	end
	
	return false
end

export type Properties = {[string]: any?}
export type Children = {Instance}
export type TextContent2DObject = {
	position: UDim2?,
	size: UDim2?,
	transparency: number?,
	color: Color3?
}

local PlayerService = game:GetService("Players")
local LocalPlayer = PlayerService.LocalPlayer
local Spr = require(script.Parent.Spr)

function GUI.CreateInstance(Name: string, Class: string, Properties: Properties?, Children: Children?): Instance
	local Object = Instance.new(Class)
	Object.Name = Name
	
	if typeof(Properties) == "table" then
		for Property: string, Value: any in pairs(Properties) do
			Object[Property] = Value
		end
	end
	
	if typeof(Children) == "table" then
		for _, Child in pairs(Children) do
			if typeof(Child) == "Instance" then
				Child.Parent = Object
			end
		end
	end
	
	return Object
end

function GUI.CreateGui(Name: string?, autoParentToPlayerGui: boolean?): GUI2DObject
	return setmetatable({
		instance = GUI.CreateInstance(Name or "ScreenGui", "ScreenGui", {
			Parent = autoParentToPlayerGui == true and LocalPlayer ~= nil and LocalPlayer.PlayerGui or nil
		})
	}, GUI)
end

function GUI.Create2DElement(Name: string, Class: string, Properties: Properties?, Children: Children?, Parent: Instance?): GUI2DObject
	local function Replace(O: string, I: string)
		if typeof(Properties) == "table" then -- just to satisfy Roblox's ultimately strict typecheck needs (can't wear hoodies while coding rule when??)
			if Properties[O] then
				Properties[I] = Properties[O]
				Properties[O] = nil
			end
		end
	end
	
	local Object = Instance.new(Class, Parent)
	Object.Name = Name
	local self = {}
	self.instance = Object
	
	if typeof(Properties) == "table" then
		Replace("position", "Position")
		Replace("parent", "Parent")
		Replace("name", "Name")
		Replace("size", "Size")
		Replace("thickness", "Thickness")
		Replace("color", "Color")
		Replace("colour", "Color")
		Replace("anchorpoint", "AnchorPoint")
		Replace("backgroundcolor3", "BackgroundColor3")
		Replace("textcolor3", "TextColor3")
		Replace("textcolor", "TextColor")
		Replace("backgroundcolor", "BackgroundColor")
		
		
		for Property: string, Value: any in pairs(Properties) do
			if typeof(Value) ~= "function" and typeof(Value) ~= "nil" then
				Object[Property] = Value
			end
		end
	end	

	if typeof(Children) == "table" then
		for _, Child in ipairs(Children) do
			if GUI._IsVexGUIMade(Child) then
				Child:Parent(Object)
			elseif typeof(Child) == "Instance" then
				Child.Parent = Object
			end
		end
	end
	
	return setmetatable(self, GUI)
end

function GUI:Animate(Damping: number, Frequency: number, Properties: Properties)
	if self.instance then
		Spr.Target(self.instance, Damping, Frequency, Properties)
	end
end

function GUI:parent(Location: Instance | GUI2DObject)
	if self.instance then
		self.instance.Parent = Location
	end
end

function GUI:Add(Class: string, Name: string, Properties: Properties?, Children: Children?): GUI2DObject
	if self.instance then
		local New = GUI.Create2DElement(Name, Class, Properties, Children)
		New.Parent = self.instance
	end
	
	return self -- Chaining 🤑
end

function GUI:CreateButton(Name: string, Class: "TextButton" | "ImageButton", Properties: TextContent2DObject | Properties, Children: Children?, Parent: Instance?)
	local Object = self.Create2DElement(Name, Class, Properties, Children, Parent)
	local Callback = Properties.Callback or Properties.CallBack or Properties.callback
	local Button: ImageButton | TextButton = Object.instance
	
	if typeof(Callback) == "function" then
		Button.MouseButton1Click:Connect(Callback)
		Button.TouchTap:Connect(Callback)
		Button.Activated:Connect(Callback)
	end
	
	return Object -- so more chaining elements are possible
end

function GUI:CreateToggle(Name: string, Properties: Properties?, Children: Children?, Parent: Instance?)
	local State = false

	local ToggleObject = self:CreateButton(Name, "TextButton", Properties or {}, Children, Parent)
	local Button = ToggleObject.instance
	local OnToggle = Instance.new("BindableEvent")

	Button.MouseButton1Click:Connect(function()
		State = not State
		OnToggle:Fire(State)
	end)

	return {
		instance = Button,
		Set = function(_, val: boolean)
			State = val
			OnToggle:Fire(State)
		end,
		Get = function()
			return State
		end,
		OnToggle = function(_, fn: (boolean) -> ())
			return OnToggle.Event:Connect(fn)
		end
	}
end

-- pretty much the same call (like GUI:Parent(), GUI:parent() except name differences)
GUI.Parent = GUI.parent
GUI.animate = GUI.Animate
GUI.create2delement = GUI.Create2DElement
GUI.add = GUI.Add

export type GUI2DObject = typeof(GUI.Create2DElement("Frame", "Frame", {}, {}, nil))
return GUI
