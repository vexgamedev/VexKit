# VexKit 👾
> [!NOTE]
> VexKit is a very lightweight framework, that can be used to help you in game development, while also reducing time taken.
> This framework can be used for:
> - Saving data,
> - Optimizing game states,
> - Designing GUI (+ Chaining),
> - Secure communications `(client->server, server->client)`
> 
> Feel free to copy and paste the modules from Packages (this is meant to be a resource used by developers)

> [!IMPORTANT]
> Before be begin, I would like to credit these people for:
> 
> **PS/Xbox check:** https://devforum.roblox.com/t/is-there-anyway-to-tell-if-a-person-is-on-an-xbox-or-a-ps4ps5/2645926/12
>
> **spr:** https://github.com/Fraktality/spr
>
> Thank you both, I appreciate y'all.

# Documentation 📃
## Core ❤️
The core of VexKit.
You can convert Vector3s, Vector2s and CFrames to tables if required. 
Making Promises via VexKit is possible with the core aswell.

### How to convert Vectors or CFrames to tables:
> [!IMPORTANT]
> This is required if you are sending position data to the server, as this data can't be compiled to JSON.

CFrames (`Vex.Core.CFrameToTable`):
```luau
return Vex.Core.CFrameToTable(workspace.Baseplate.CFrame)
--> {0, -8, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1}
```

Vectors (`Vex.Core.Vector3ToTable`, `Vex.Core.Vector2ToTable`)
```luau
return
    Vex.Core.Vector3ToTable(workspace.Baseplate.Position), --> {0, -8, 0}
    Vex.Core.Vector2ToTable(Vector2.new(10, 15)) --> {10, 15}
```

### Converting tables into Vectors or CFrames
CFrames (`Vex.Core.TableToCFrame`):
```luau
return Vex.Core.TableToCFrame({0, -8, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1})
--> CFrame(0, -8, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
```

Vectors (`Vex.Core.TableToVector3`, `Vex.Core.TableToVector2`)
```luau
return
    Vex.Core.TableToVector3({0, -8, 0}), --> Vector3(0, -8, 0)
    Vex.Core.TableToVector2({10, 15}) --> Vector2(10, 15)
```

### How to make promise objects:
```luau
local Promise = VexKit.Core.Promise
Promise.new(function(res, rej) end)
```
Or you can make them using:
```luau
VexKit.Core:NewPromise(function(res, rej) end)
```
> [!TIP]
> To get the resolved values without using `:andThen()`,
>
> do for example:
>
> ```luau
> local IsToggled = VexKit.Core.Promise.new(function(res, rej)
>    res(true)
> end)._value
> 
> print(IsToggled) --> true
> ```

## Input 🎮
### `Input:GetDevice()`
`:GetDevice()` returns if the player is either on "Keyboard and Mouse" (PC), "Console" (Xbox/PlayStation), "VR", "Phone" (Phone/Tablet), and obviously "Unknown"

Example:
```luau
local device = Vex.Input:GetDevice()
print(
    string.format(
        "%d is playing on %s!", game:GetService("Players").LocalPlayer.UserId, device
    )
)
```

### `Input:IsTyping(): boolean`
`:IsTyping()` will return true if the user has focused a TextBox, otherwise false.
> [!TIP]
> You can use `:IsTyping()` when using `:OnKeyPress`, here's an example:
> ```luau
> Vex.Input:OnKeyPress({Enum.KeyCode.Q, Enum.KeyCode.ButtonA}, function(Key, Held)
>    if not Vex.Input:IsTyping() then
>        if Key == Enum.KeyCode.Q then
>            print("Player pressed Q on their keyboard!")
>        elseif Key == Enum.KeyCode.ButtonA then
>            print("Player pressed A on their gamepad!")
>        end
>    end
>  end)
> ```

Example:
```luau
local LocalPlayer = game:GetService("Players").LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
while task.wait() do
    if not Vex.Input:IsTyping() then
    if Vex.Input:IsKeyHeld(Enum.KeyCode.Space) then
        Character.PrimaryPart.CFrame = Character.PrimaryPart.CFrame + Vector3.new(0, 0.01, 0)
    end
end
```
Provided example will make the players' character teleport above if space is held.

### `Input:OnMousePress(function(<int> Button, <bool> Held, <int> X, <int> Y)`
`Input:OnMousePress` activates the provided callback once the player presses/releases a mouse button

**(FYI. LMB (Left Mouse Button) = 1, RMB (Right Mouse Button) = 2)**

Example:
```luau
local OnMousePressConnection = Vex.Input:OnMousePress(function(Button: number, Held: boolean, X: number, Y: number)
    print(
        if Held then
            string.format("Player pressed the %s button at x%d y%d!", Button == 1 and "LMB" or "RMB", X, Y)
        else string.format("Player released the %s button at x%d y%d!", Button == 1 and "LMB" or "RMB", X, Y)
    )
end)
task.wait(3)
-- disconnect the mouse connection once it's useless
OnMousePressConnection:Disconnect()
```

### `Input:OnKeyPress(function({Enum.KeyCode} RequiredKeys, Callback: (key: Enum.KeyCode, held: boolean) -> ())`
`Input:OnKeyPress` executes the callback once one of the RequiredKeys keybind was pressed by the player, which can be useful for console support (with PC).

Example:
```luau
local OnKeyPressConnection = Vex.Input:OnKeyPress({Enum.KeyCode.Q, Enum.KeyCode.ButtonA}, function(key: Enum.KeyCode, held: boolean)
    if held == false then -- the input has ended
        print("The button Q/A has been tapped!")
    end
end)
```

### `Input:IsXbox(): boolean`
`Input:IsXbox()` will return true if the player is on console and a Xbox gamepad has been detected.

Example:
```luau
if Vex.Input:IsXbox() == true then
    print("The player is playing on Xbox!")
end
```

### `Input:IsPlayStation(): boolean`
`Input:IsPlayStation()` will return true if the player is on console and a PlayStation gamepad has been detected.

Example:
```luau
if Vex.Input:IsPlayStation() == true then
    print("The player is playing on PlayStation!")
end
```

### Disconnecting gamepad auto-detect (if you don't need it):
> [!CAUTION]
> This is connected everytime the module is required. If this isn't needed, you can disconnect it under the script or somewhere else.
>
> Otherwise, you can go to VexKit -> Packages -> Input, scrolldown and remove the entire `Input._AutoDetectControllerConnection` variable definition.
> ```luau
> Input._AutoDetectControllerConnection:Disconnect()
> ```
## NetBridge
NetBridge is a module that keeps communication between the client and server safe and secure, loud and crystal clear.

> [!IMPORTANT]
> **You can't pass instances as arguments vector3's and/or CFrame's (when calling the remote). Instead you can pass them as a table (use `VexKit.Core.CFrame2Table` for this task)**.
>
> **If you pass only 1 argument, you NEED to pack it into a table (using `table.pack` or such) and then calling `table.unpack` on the server to extract it. Or just do Data[1].**

### `NetBridge:Subscribe(<string> Name, <function> Callback (Player, ...))`
``NetBridge:Subscribe`` subscribes the Name as a remote which can be called by the client using `NetBridge:Request` or `NetBridge:Call`.

Example:
```luau
Vex.NetBridge:Subscribe("SetBaseplatePosition", function(Player, Data: { Position: {} })
    -- ⚠️ Converting tables back to Vector3 (MUST REMEMBER!)
    Data.Position = Vex.Core.TableToVector3(Data.Position)
    workspace.Baseplate.Position = Data.Position
end)
```

After you have attached a remote to the server using `:Subscribe()`,
you can request the client to send information directly back to the server,
which returns a promise.

You can even call this on the clientside (assuming you want to request client stuff from the server using a player), example:

> [!WARNING]
> **The code below is meant to be ran on the client**.
```luau
Vex.NetBridge:Subscribe("SetBaseplatePosition", function()
    return workspace.Baseplate.Position
end)
```

## `NetBridge:Request` (called on serverside)

> [!WARNING]
> **Making the first argument (Target Player) undefined will make it call every clients, which will make the returned data from clients undefined.**

Example:
```luau
local Position = SetBaseplatePosition:Request(TargettedPlayer, "GetCurrentBaseplatePosition") --> Vector3
print("Gotten position from the player:", Position)
```
## `NetBridge:Request` (called on clientside)
`Vex.NetBridge:Request` returns a Promise object.
Here's an example:
```luau
local NetBridge = Vex.NetBridge
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CreatedRig

NetBridge:Request("Remotes/CreateRig"):andThen(require(function(Rig: Model)
	if not Rig then
    -- assuming PlayerRigs is a folder in ReplicatedStorage..
		Rig = ReplicatedStorage.PlayerRigs:WaitForChild(LocalPlayer.UserId)
	end

	Rig.Parent = ReplicatedStorage.PlayerRigs
  CreatedRig = Rig
end))

-- You can do something with the rig here
-- But since this is useless now, it will be removed.
Rig:Destroy()
```
> [!TIP]
> Instead of doing  `NetBridge:Request("Name Here", ...):andThen(function()`,
>
> You can make a module inside of that script, make it return a function, and then write:
> 
> ``NetBridge:Request("Name Here", ...):andThen(require(script.ModuleNameGoesHere))``

> [!IMPORTANT]
> Both `:Subscribe` and `:Request` can be called on the client and server side, but please note that:
>
> The usage of either changes depending on the context.
>
> For example, if you use `:Request` on the serverside, it doesn't return a Promise object but the arguments the client has given.
>
>  You only get Promise objects if you use `:Request` on the client.

## Database 💾
### ``Database:GetDataStore(Name: string)``
> [!TIP]
> This datastore module is literally Roblox's Data Store, however rewritten to:
> - be able to list every key in a store
> - look like if it was written in a different language
Example:
```luau
local NewDataStore = Vex.Database:GetDataStore("NewDataStore")
```
### ``Database:Get(Key: string | number): Promise``
> [!IMPORTANT]
> This option returns a promise.
>
> To get just the value (and not calling `:andThen()`), as shown before, you can use:
> ```luau
> local PlayerData = DataStore:Get(1)._value
> ```
``Vex.Database:Get`` returns a Promise which contains the value of given key.
Examples:
```luau
local Data1, Data2
DataStore:Get(1):andThen(function(GivenData)
    Data1 = GivenData
end)

Data2 = DataStore:Get(2)._value
```
### ``Database:Set(Key: string | number, ...): Promise``
> [!NOTE]
> If you wish to do something after setting the data of the key, since this returns a Promise object,
> you can chain like this (or by learning, using this example):
> ```lua
> DataStore:Set(1, {
>    Stage = 2,
>    FollowingQuest = "Find out where you are"
> }):andThen(function(success)
>    print("Successfuly set data of the key \"1\"!")
> end):catch(warn)
> ```
Example:
```luau
DataStore:Set(5, { Money = 10 })
```
## ``Database:Remove(Key: string): Promise``
> [!NOTE]
> This method returns a Promise object too, meaning you can chain methods.
>
> Look above at `Database:Set` for a example.
Example:
```lua
DataStore:Remove(1):andThen(function(success)
    print("Successfuly removed data for the key \"1\"!")
end):catch(warn)
```
## Signal ⚡
``Vex.Signal`` is a module that allows you to simulate BindableEvents (running multiple functions at once).
Here's an example:
```lua
local newSignal = Vex.Signal.new()
newSignal:Connect(function(...)
    print(...)
end)
-- prints "Hello world!" after 5 seconds
task.delay(5, newSignal.Fire, newSignal, "Hello world!")
```
Signal allows you to help in creating modules with functionality without creating BindableEvents, allowing you to simplify code.
## Asset 📑
``Vex.Asset`` allows you to easily preload assets, even giving you extra functionality for making loading screens.
> [!IMPORTANT]
> `:PreloadAsync` returns a Promise.

To preload these, you can call ``Vex.Asset:PreloadAsync``, example:
```luau
Vex.Asset:PreloadAsync({ "rbxassetid://0", AnimationObjects }):andThen(function()
    print("Successfuly preloaded these items!")
end):catch(warn)
```

However, to make loading screens, you can use ``Vex.Asset.Loader``.
Here is a example how:
```luau
local Loader = Vex.Asset.Loader.new()
Loader:AddItemsAsync({workspace, game:GetService("ReplicatedStorage")})
Loader:BeginPreloading(function(Percentage, AssetFetchStatus: Enum.AssetFetchStatus)
    local Scale = Percentage / 100
    -- Change the size of some bar to the scale
    -- Change some text to the percentage
end)

task.delay(1.5, function()
    Loader:Skip()
end)
```
You can also add one singular item by running:
```luau
Loader:AddItemAsync(Item)
```
## GUI 📑
``Vex.GUI`` is a framework prioritizing efficiency and speed whilst coding, with incredible functions including chaining.
### `GUI.new(Name: string?, Parent: Instance?)`
GUI.new takes 2 arguments, first is `Name` which takes only string (can be `undefined` now), and then Parent which MUST either be `undefined` or a `Instance` object.
> [!CAUTION]
> `:done()` method returns the parent of the object, which is highly necessary for chaining.
> **IF** you have done every `Instance` objects you needed, you can use :done() to exit out of the chain and get the **NewGui (ScreenGui)** object, or call `:finished()`.
```luau
local localPlayer = game:GetService("Players").LocalPlayer
local NewGui = GUI.new("ScreenGui", localPlayer:WaitForChild("PlayerGui"))
	:done()
```
### Creating elements (Frames, ImageLabels, TextLabels, TextButtons, Rounding Corners, ETC)

<details>
  <summary>Every methods and their usages in this example code below</summary>

  - FYI, the descriptions of what these funxtions do are going to be commented (the ones already done will remain empty as they were already explained)
  
  ```lua
	local spr = vexgui.spr

	function newCard(title: string)
		title = string.format("%s  ", title)
		return vexgui.Component.new("Frame", "Card") -- Create a new Frame component named "Card"
			:roundCorners(UDim.new(0, 10)) -- Rounds the corners with the scale of 0 and offset 10
			:size(UDim2.fromOffset(90, 130)) -- Modifies the size into the specified UDim2
			:bgColor(Color3.fromRGB(43, 43, 43)) -- Modifies the background color into the provided Color3
			:borderSizePixel(0) -- Set the border size pixel to 0
			:zindex(2) -- Modify the ZIndex to 2 to make this show above the shadow
			:label("Title", title) -- Create a new title frame with the text of "title"
				-- Name: string, Text: string
				-- Example: :laabel("Label's Name", "Hello world! is what says on this TextLabel")
				:txtColor(Color3.fromRGB(177, 177, 177)) -- Modify the text color into said Color3
				:transparency(1) -- Modify the background transparency to 1
				:textXAlignment(Enum.TextXAlignment.Right) -- Set the Text X alignment
				:textYAlignment(Enum.TextYAlignment.Top) -- Set the Text Y alignment
				:font(Enum.Font.GothamBold) -- Modify the font into GothamBold
				:textScaled(true) -- Make the text scaled (change FontSize upon Size modification)
				:size(UDim2.fromScale(1, 0.1)) -- Make the title label 100% width and 10% height (text visibility)
				:zindex(2) -- Make the ZIndex above shadow's visibility priority
				:done() -- Exit the chaining back into the Card component
			:onMouseEnter(function(frame: Frame) -- New callback when the player hovers their mouse on the frame
				-- frame is the Card component that you can modify directly here
				print(frame) --> Card
				spr.target(frame, 1, 1.3, {
					BackgroundColor3 = Color3.fromRGB(70, 70, 70),
				})
				spr.target(frame:WaitForChild("Title"), 1, 1.3, {
					TextColor3 = Color3.fromRGB(210, 210, 210),
				})
				spr.target(frame:FindFirstChildOfClass("UICorner"), 1, 1.3, {
					CornerRadius = UDim.new(0, 13)
				})
			end)
			:onMouseLeave(function(frame: Frame) -- New callback when the player moves their mouse away from the frame
				-- frame is the Card component that you can modify directly here
				spr.target(frame, 1, 1.3, {
					BackgroundColor3 = Color3.fromRGB(43, 43, 43),
				})
				spr.target(frame:WaitForChild("Title"), 1, 1.3, {
					TextColor3 = Color3.fromRGB(177, 177, 177),
				})
				spr.target(frame:FindFirstChildOfClass("UICorner"), 1, 1.3, {
					CornerRadius = UDim.new(0, 10)
				})
			end)
		:finished() -- Return the card component as the Instance (you receive the Frame object)
	end

	local screenGui = vexgui.new("Card Displayer", game.Players.LocalPlayer:WaitForChild("PlayerGui"))
		:frame("Cards Menu")
			:imageLabel("http://www.roblox.com/asset/?id=117996870926569") -- Create a new ImageLabel (this shows a shadow FYI)
				:size(UDim2.fromScale(1.7, 1.7)) -- Resize it to be 170% width and height (shadow visibility)
				:pos(UDim2.fromScale(0.5, 0.5), Vector2.one/2) -- Center the shadow in the frame
				-- #1st argument is a UDim2 (Position), and 2nd is a Vector2 (AnchorPoint)
				:imgTransparency(0.4) -- Change the transparency of the image
				:transparency(1) -- Change the background transparency of the image
				:imgColor(Color3.fromRGB(147, 97, 255)) -- Change the image color
				:done() -- Exit back to the Cards Menu frame chain
			:pos(UDim2.fromScale(0.5, 0.5), Vector2.one / 2) -- Center the frame perfectly in the screen
			:size(UDim2.fromScale(0.32, 0.8)) -- 32% width, 80% height of the screen
			:bgColor(Color3.fromRGB(13, 13, 13)) -- Replace the color of the background to be black
			:roundCorners(UDim.new(0, 16)) -- Round the frame's corners with the radius of 16 (Offset)
			:borderSizePixel(0) -- Change the border size pixel so there's no ugly black borders that weren't invited
			:zindex(2) -- Same story, make the Frame ZIndex to 2 to be over the purple shadow
			:frame("Cards List") -- Create a new cards list frame
				:zindex(2) -- Same story (yada yada)
				:borderSizePixel(0) -- Same story once again
				:layout("grid")-- :layout("vertical", "horizontal", "grid")
					:alignX(Enum.HorizontalAlignment.Center) -- Objects will appear in the center middle horizontally
					:alignY(Enum.VerticalAlignment.Center) -- Objects will appear in the center middle vertically
					:cellSize(UDim2.fromOffset(150, 173)) -- Modify the cell size
					:done() -- Exit the grid layout into the Cards List frame
			:size(UDim2.fromScale(1, 1)) -- Change the size to 100% of the GUI (so every cards fit)
			:transparency(1) -- Set the transparency to 1 so only Card Displayer is visible
			:done() -- Exit the chain to Card Displayer
		:done() -- Exit the chain to the Screen GUI
		:finished() -- Extract the ScreenGui instance here

	for i = 1, 9 do
		newCard("Test title here").Parent = screenGui:FindFirstChild("Cards Menu"):FindFirstChild("Cards List")
	end
  ```
</details>

To create frames after a GUI was defined, we can do:
```luau
GUI.new(...):
	:frame(Name: string) -- Create a new Frame object with the specified Name in that ScreenGui
		:done() -- We're finished with the frame, exit back to the ScreenGui chain
	:done() -- Exit chaining and return ScreenGui
```
There are even buttons, labels, imagelabels and grid layouts.
<details>
  <summary>To create buttons, there's a method `:button(Name: string, Text: string)`</summary>
	
  ```luau
  GUI.new(...)
  	:button("Test Button", "Click this for a Hello World!")
  		:size(UDim2.fromScale(1, 0.3)
  		:position(UDim2.fromScale(0.5, 0.5), Vector2.one/2)
  		:font(Enum.Font.Code)
  		:txtColor(Color3.fromRGB(255, 255, 255))
  		:bgColor(Color3.fromRGB(40, 40, 40))
  		:onClick(function(TestButton)
  			print("Hello World! [Player clicked Test Button]")
  		end)
		:onRightClick(function(TestButton)
			print("Ooo fancy [Player right clicked Test Button]")
		end)
  ```
</details>

<details>
  <summary>To create TextLabels, there's a method `:label(Name: string, Text: string)`</summary>
	
  ```luau
  GUI.new(...)
  	:label("Test Label", "Hover this for brighter text!")
  		:size(UDim2.fromScale(1, 0.3)
  		:position(UDim2.fromScale(0.5, 0.5), Vector2.one/2)
  		:font(Enum.Font.Code)
  		:txtColor(Color3.fromRGB(199, 199, 199))
  		:bgColor(Color3.fromRGB(40, 40, 40))
  		:onMouseEnter(function(TestLabel)
  			TestLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
  		end)
		:onMouseLeave(function(TestLabel)
			TestLabel.TextColor3 = Color3.fromRGB(199, 199, 199)
		end)
  ```
</details>

<details>
  <summary>To create ImageLabels, there's a method `:imageLabel(Icon: string)`</summary>
	
  ```luau
  GUI.new(...)
  	:imageLabel("http://www.roblox.com/asset/?id=117996870926569")
  		:size(UDim2.fromScale(1, 0.3)
  		:position(UDim2.fromScale(0.5, 0.5), Vector2.one/2)
  		:font(Enum.Font.Code)
  		:imgColor(Color3.fromRGB(199, 199, 199))
		:imgTransparency(0.43)
  		:transparency(1) -- Background Transparency
  ```
</details>

## More documentations soon, if you really need to learn more, reffer to the example above titled _Every methods and their usages in this example code below_

---
> [!NOTE]
> Written by [@vexgamedev](https://github.com/vexgamedev/)
> 
> This took alot of effort to write,
> 
> also this was getting written when I was tired so please don't judge.
> 
> Thanks for reading, and enjoy using VexKit!

---
