-- Vex.Input || @vexgamedev
-- Warning: Bad code ahead
-- You've been warned
-- Credits to find if user is on Xbox or PlayStation to this DevForum post (ty):
-- https://devforum.roblox.com/t/is-there-anyway-to-tell-if-a-person-is-on-an-xbox-or-a-ps4ps5/2645926/12

local Input = { _XboxCheck = false }
local LocalPlayer = game:GetService("Players").LocalPlayer
local PlayerMouse: Mouse = LocalPlayer ~= nil and LocalPlayer:GetMouse()
local Service = game:GetService("UserInputService")
local IsClient = game:GetService("RunService"):IsClient()

local GamepadInputsList = {
	Enum.KeyCode.ButtonA,
	Enum.KeyCode.ButtonB,
	Enum.KeyCode.ButtonX,
	Enum.KeyCode.ButtonY,
	Enum.KeyCode.ButtonL1,
	Enum.KeyCode.ButtonL2,
	Enum.KeyCode.ButtonL3,
	Enum.KeyCode.ButtonR1,
	Enum.KeyCode.ButtonR2,
	Enum.KeyCode.ButtonR3,
	Enum.KeyCode.ButtonStart,
	Enum.KeyCode.ButtonSelect,
	Enum.KeyCode.DPadUp,
	Enum.KeyCode.DPadDown,
	Enum.KeyCode.DPadLeft,
	Enum.KeyCode.DPadRight,
	Enum.KeyCode.Thumbstick1,
	Enum.KeyCode.Thumbstick2,
}

local XboxButtonMappings = {
	"ButtonA", "ButtonB", "ButtonX", "ButtonY",
	"ButtonL1", "ButtonL2", "ButtonL3",
	"ButtonR1", "ButtonR2", "ButtonR3",
	"ButtonStart", "ButtonSelect",
}

local PlayStationButtonMappings = {
	"ButtonCross", "ButtonCircle", "ButtonSquare", "ButtonTriangle",
	"ButtonL1", "ButtonL2", "ButtonL3",
	"ButtonR1", "ButtonR2", "ButtonR3",
	"ButtonOptions", "ButtonTouchpad", "ButtonShare",
}

local Xbox_ReturnValues_List = {
	"ButtonA", "ButtonB",
	"ButtonX", "ButtonY",
	"ButtonLB", "ButtonLT",
	"ButtonLS", "ButtonRB",
	"ButtonRT", "ButtonRS", 
	"ButtonStart", "ButtonSelect"
}

local PlayStation_ReturnValues_List = {
	"ButtonCross", "ButtonCircle",
	"ButtonSquare", "ButtonTriangle",
	"ButtonL1", "ButtonL2",
	"ButtonL3", "ButtonR1",
	"ButtonR2", "ButtonR3",
	"ButtonOptions", "ButtonTouchpad",
	"ButtonShare",
}

function Input:GetDevice(): "Keyboard and Mouse" | "Console" | "VR" | "Phone" | "Unknown"
	-- TODO: make this function return more accurate results.
	assert(IsClient, "You cannot get a device type on the serverside.")
	local TouchEnabled = Service.TouchEnabled
	local MouseEnabled = Service.MouseEnabled
	local KeyboardEnabled = Service.KeyboardEnabled
	local GamepadEnabled = Service.GamepadEnabled
	local VREnabled = Service.VREnabled

	if VREnabled then
		return "VR"
	end

	if TouchEnabled and not MouseEnabled and not KeyboardEnabled then
		return "Phone"
	end

	if GamepadEnabled and not KeyboardEnabled and not MouseEnabled then
		return "Console"
	end

	if MouseEnabled and KeyboardEnabled and not TouchEnabled then
		return "Keyboard and Mouse"
	end

	return "Unknown"
end

function Input:OnMousePress(callback: (button: number, held: boolean, x: number, y: number) -> ())
	assert(IsClient, "You cannot detect input (e.g. MousePress, Touch) on the serverside.")
	local Required = { _Connections = {} }

	table.insert(Required._Connections, PlayerMouse.Button1Up:Connect(function() return callback(1, false, PlayerMouse.X, PlayerMouse.Y) end))
	table.insert(Required._Connections, PlayerMouse.Button1Down:Connect(function() return callback(1, true, PlayerMouse.X, PlayerMouse.Y) end))
	table.insert(Required._Connections, PlayerMouse.Button2Up:Connect(function() return callback(2, false, PlayerMouse.X, PlayerMouse.Y) end))
	table.insert(Required._Connections, PlayerMouse.Button2Down:Connect(function() return callback(2, true, PlayerMouse.X, PlayerMouse.Y) end))

	function Required:Disconnect()
		for _, connection in Required._Connections do
			connection:Disconnect()
		end

		table.clear(Required._Connections)
	end

	return Required
end

function Input:OnKeyPress(requiredKeys: {Enum.KeyCode}?, callback: (key: Enum.KeyCode, held: boolean) -> ())
	local Required = { _Connections = {} }
	local Keys = requiredKeys

	table.insert(Required._Connections, Service.InputBegan:Connect(function(Input)
		if typeof(Keys) == "table" and table.find(Keys, Input.KeyCode) then
			return callback(Input.KeyCode, true)
		end
	end))

	table.insert(Required._Connections, Service.InputEnded:Connect(function(Input)
		if typeof(Keys) == "table" and table.find(Keys, Input.KeyCode) then
			return callback(Input.KeyCode, false)
		end
	end))

	function Required:Disconnect()
		for _, connection in Required._Connections do
			connection:Disconnect()
		end

		table.clear(Required._Connections)
	end

	return Required
end

function Input:IsXbox(): boolean
	return if self:GetDevice() == "Console" then Input._XboxCheck == true else false
end

function Input:IsPlayStation(): boolean
	return if self:GetDevice() == "Console" then Input._XboxCheck == false else true
end

function Input:IsKeyHeld(KeyCode: Enum.KeyCode): boolean
	return Service:IsKeyDown(KeyCode)
end

function Input:IsTyping(): boolean
	return Service:GetFocusedTextBox() ~= nil
end

if IsClient then
	Input._AutoDetectControllerConnection = Service.InputBegan:Connect(function(gamepadInput: InputObject)
		if Input:GetDevice() == "Console" then
			local stringForKeyCodePressed = Service:GetStringForKeyCode(gamepadInput)
			if table.find(XboxButtonMappings, stringForKeyCodePressed) then
				if Input._XboxCheck ~= true then
					Input._XboxCheck = true
				end
			elseif table.find(PlayStationButtonMappings, stringForKeyCodePressed) then
				if Input._XboxCheck ~= false then
					Input._XboxCheck = false
				end
			end
		end
	end)
else
	Input._AutoDetectControllerConnection = { Disconnect = function(self) return self end }
end

return Input
