local UserInterface = {}
UserInterface.spr = require(script.Parent.Spr)
UserInterface.__index = UserInterface
UserInterface.Component = {}

function UserInterface.Component.new(Class: string, Name: string?)
	local self = {}
	self._instance = Instance.new(Class)
	self._instance:SetAttribute("_is_component", true)
	self._instance.Name = Name or "Component"
	self._parent = nil
	return setmetatable(self, UserInterface)
end

export type VexButton = {
	onClick: (self: VexButton, callback: () -> ()) -> (),
	onRightClick: (self: VexButton, callback: () -> ()) -> (),
	onMouseEnter: (self: VexButton, callback: (x: number, y: number) -> ()) -> (),
	onMouseLeave: (self: VexButton, callback: (x: number, y: number) -> ()) -> (),
	frame: (self: UserInterfaceObject, Name: string?) -> UserInterfaceObject,
	button: (self: UserInterfaceObject, Name: string?, Text: string?) -> VexButton,
	done: () -> ScreenGui
}

--export type UserInterfaceObject = {
--	_parent: Instance?,
--	_instance: Instance,
--	frame: (self: UserInterfaceObject, Name: string?) -> UserInterfaceObject,
--	button: (self: UserInterfaceObject, Name: string?, Text: string?) -> VexButton,
--	done: () -> ScreenGui
--}

function UserInterface.new(Name: string?, Parent: Instance?, ResetOnSpawn: boolean?): typeof(UserInterface)
	local self = setmetatable({}, UserInterface)
	self._parent = nil
	self._instance = Instance.new("ScreenGui")
	self._instance.Name = Name or "ScreenGui"
	self._instance.Parent = Parent
	self._instance.ResetOnSpawn = ResetOnSpawn or false
	return self
end

function UserInterface:frame(Name: string?): UserInterfaceObject
	local frame = setmetatable({}, UserInterface)
	frame._parent = self._instance
	frame._instance = Instance.new("Frame")
	frame._instance.Name = Name or "Frame"
	frame._instance.Parent = frame._parent
	frame._prev = self
	frame._instance.BorderSizePixel = 0
	return frame
end

function UserInterface:onMouseEnter(callback: (self: Instance) -> ())
	self._instance.MouseEnter:Connect(function()
		return callback(self._instance)
	end)
	return self
end

function UserInterface:onMouseLeave(callback: (self: Instance) -> ())
	self._instance.MouseLeave:Connect(function()
		return callback(self._instance)
	end)
	return self
end

function UserInterface:label(Name: string?, Text: string?)
	local label = setmetatable({}, UserInterface)
	label._parent = self._instance
	label._instance = Instance.new("TextLabel")
	label._instance.Name = Name or "TextLabel"
	label._instance.Text = Text or "TextLabel"
	label._instance.Parent = label._parent
	label._prev = self
	label._instance.BorderSizePixel = 0

	function label:font(font: Enum.Font)
		label._instance.Font = font
		return self
	end

	function label:text(Text: string)
		label._instance.Text = Text
		return label
	end

	return label
end

function UserInterface:button(Name: string?, Text: string?)
	local button = setmetatable({}, UserInterface)
	button._parent = self._instance
	button._instance = Instance.new("TextButton")
	button._instance.Name = Name or "TextButton"
	button._instance.Text = Text or "TextButton"
	button._instance.Parent = button._parent
	button._instance.BorderSizePixel = 0
	button._prev = self

	function button:onClick(callback: () -> ())
		button._instance.MouseButton1Click:Connect(callback)
		return self
	end

	function button:onRightClick(callback: () -> ())
		button._instance.MouseButton2Click:Connect(callback)
		return self
	end

	function button:font(font: Enum.Font)
		button._instance.Font = font
		return self
	end

	function button:text(Text: string)
		button._instance.Text = Text
		return button
	end

	return button
end


function UserInterface:done()
	return self._prev
end

function UserInterface:finished()
	local current = self._instance
	if current:IsA("ScreenGui") then
		return current
	else
		local this = self
		repeat
			local that = typeof(current) == "Instance" and current or current._instance
			if that:IsA("ScreenGui") or (that:GetAttribute("_is_component") ~= nil and that:GetAttribute("_is_component") == true) then
				return current
			else
				current = current._parent
			end
			task.wait()
		until current
	end
end

function UserInterface:bgColor(Color: Color3 | BrickColor): UserInterfaceObject
	local that = self._instance
	if that then that[ typeof(Color) == "Color3" and "BackgroundColor3" or "BackgroundColor" ] = Color end
	return self
end

function UserInterface:txtColor(Color: Color3 | BrickColor): UserInterfaceObject
	local that = self._instance
	if that then that[ typeof(Color) == "Color3" and "TextColor3" or "TextColor" ] = Color end
	return self
end

function UserInterface:anchorPoint(Point: Vector2)
	local that = self._instance
	if that then that.AnchorPoint = Point end
	return self
end

function UserInterface:pos(Position: UDim2, AnchorPoint: Vector2?)
	local that = self._instance
	if that then
		that.Position = Position
		if AnchorPoint and typeof(AnchorPoint) == "Vector2" then
			that.AnchorPoint = AnchorPoint
		end
	end
	return self
end
UserInterface.position = UserInterface.pos

function UserInterface:size(Size: UDim2)
	local that = self._instance
	if that then that.Size = Size end
	return self
end
UserInterface.Size = UserInterface.size

function UserInterface:visible(Toggle: boolean)
	local that = self._instance
	if that then that.Visible = Toggle end
	return self
end

function UserInterface:transparency(number: number)
	local that = self._instance
	if that then
		that.BackgroundTransparency = number
	end
	return self
end

function UserInterface:textXAlignment(xAlign: Enum.TextXAlignment)
	local that = self._instance
	if that then
		that.TextXAlignment = xAlign
	end
	return self
end

function UserInterface:textYAlignment(xAlign: Enum.TextYAlignment)
	local that = self._instance
	if that then
		that.TextYAlignment = xAlign
	end
	return self
end

function UserInterface:textScaled(toggle: boolean)
	local that = self._instance
	if that then
		that.TextScaled = toggle
	end
	return self
end

function UserInterface:fontSize(size: number)
	local that = self._instance
	if that then
		that.FontSize = size
	end
	return self
end

function UserInterface:borderSizePixel(size: number)
	local that = self._instance
	if that then
		that.BorderSizePixel = size
	end
	return self
end

function UserInterface:roundCorners(radius: UDim?)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = radius or UDim.new(0, 8)
	corner.Parent = self._instance
	return self
end

function UserInterface:layout(layoutType: "vertical" | "horizontal" | "grid")
	local layoutObj = {}
	local previous = self
	layoutObj._parent = self._instance
	local layout
	if layoutType == "vertical" or layoutType == "horizontal" then
		layout = Instance.new("UIListLayout")
		layout.FillDirection = layoutType == "vertical"
			and Enum.FillDirection.Vertical
			or Enum.FillDirection.Horizontal
	elseif layoutType == "grid" then
		layout = Instance.new("UIGridLayout")
	else
		error("Invalid layout type")
	end

	layoutObj._layout = layout
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = previous._instance

	function layoutObj:padding(padding: UDim)
		if layoutObj._layout then layoutObj._layout.Padding = padding end
		return layoutObj
	end

	function layoutObj:alignX(alignment: Enum.HorizontalAlignment)
		if layoutObj._layout then layoutObj._layout.HorizontalAlignment = alignment end
		return layoutObj
	end

	function layoutObj:alignY(alignment: Enum.VerticalAlignment)
		if layoutObj._layout then layoutObj._layout.VerticalAlignment = alignment end
		return layoutObj
	end

	function layoutObj:cellSize(size: UDim2)
		if layoutObj._layout and layoutObj._layout:IsA("UIGridLayout") then
			layoutObj._layout.CellSize = size
		end
		return layoutObj
	end

	function layoutObj:cellPadding(pad: UDim2)
		if layoutObj._layout and layoutObj._layout:IsA("UIGridLayout") then
			layoutObj._layout.CellPadding = pad
		end
		return layoutObj
	end

	function layoutObj:done()
		return previous
	end

	return layoutObj
end

function UserInterface:zindex(count: number)
	local that = self._instance
	if that then
		that.ZIndex = count
	end
	return self
end

function UserInterface:imageLabel(icon: string?)
	local imageObj = {}
	local previous = self
	imageObj._instance = Instance.new("ImageLabel", previous._instance)
	imageObj._instance.BorderSizePixel = 0

	if typeof(icon) == "string" then
		imageObj._instance.Image = icon
	end

	function imageObj:icon(icon: string?)
		imageObj._instance.Image = icon
		return self
	end

	function imageObj:done()
		return previous
	end

	function imageObj:imgTransparency(transparency: number)
		self._instance.ImageTransparency = transparency
		return self
	end

	function imageObj:imgColor(color: Color3)
		self._instance.ImageColor3 = color
		return self
	end

	return setmetatable(imageObj, UserInterface)
end

function UserInterface:stroke()
	local strokeObj = {}
	local previous = self
	strokeObj._instance = Instance.new("UICorner")
	strokeObj._instance.Parent = self._instance

	function strokeObj:thickness(thickness: number)
		self._instance.Thickness = thickness
	end

	function strokeObj:color(color: Color3)
		self._instance.Color = color
	end

	function strokeObj:gradient()
		local gradientObj = {}
		local previous = self
		gradientObj._instance = Instance.new("UIGradient")
		gradientObj._instance.Parent = previous._instance

		function gradientObj:color(color1: Color3, color2: Color3)
			self._instance.Color = ColorSequence.new(color1, color2)
			return self
		end

		function gradientObj:done()
			return previous
		end

		return gradientObj
	end

	function strokeObj:done()
		return previous
	end

	return strokeObj
end

export type UserInterfaceObject = typeof(UserInterface.new("ScreenGui"))
return UserInterface
