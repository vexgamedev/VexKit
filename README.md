# VexKit 👾
A light-weight framework that's guaranteed to ease your experience in game development that handles many multiple tasks.
If you've came here, and wonder how to use it, you're in the right place!
Documentations (everything you need to know) are below.

## But before we continue, here are credits I highly want to note here:

**PS/Xbox check:** https://devforum.roblox.com/t/is-there-anyway-to-tell-if-a-person-is-on-an-xbox-or-a-ps4ps5/2645926/12

**spr:** https://github.com/Fraktality/spr

#### (both are goated, tysm)

<div style="background-color: transparent; border: 4px solid yellow; padding: 15px; margin: 10px 0; border-radius: 5px; color: black;">
  <strong>Warning!</strong> Be careful, this is important.
</div>

# Documentation 📃
## Core ❤️
The core of VexKit.
You can convert Vector3s, Vector2s and CFrames to tables if required. 
Making Promises via VexKit is possible with the core aswell.

### How to convert Vectors or CFrames to tables:
⚠️ This is required if you are sending position data to the server, as this data can't be compiled to JSON.

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
⚠️ This is ran everytime the module is required. If this isn't needed, you can disconnect it under the script or somewhere else.
```luau
Input._AutoDetectControllerConnection:Disconnect()
```
## NetBridge
NetBridge is a module that keeps communication between the client and server safe and secure, loud and crystal clear.

⚠️ **You can't pass instances as arguments vector3's and/or CFrame's (when calling the remote). Instead you can pass them as a table (use `VexKit.Core.CFrame2Table` for this task)**
⚠️ **If you pass only 1 argument, you NEED to pack it into a table (using `table.pack` or such) and then calling `table.unpack` on the server to extract it. Or just do Data[1].**

## `NetBridge:Subscribe(<string> Name, <function> Callback (Player, ...))`
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

⚠️ Code below is meant to be ran on the clientside.
```luau
Vex.NetBridge:Subscribe("SetBaseplatePosition", function()
    return workspace.Baseplate.Position
end)
```

⚠️ **Making the first argument (Target Player) undefined will make it call every clients, which will make the returned data from clients undefined.**

Example:
```luau
local Position = SetBaseplatePosition:Request(TargettedPlayer, "GetCurrentBaseplatePosition") --> Vector3
print("Gotten position from the player:", Position)
```

