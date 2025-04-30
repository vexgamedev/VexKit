--\\
--> Vex's Kit || designed and made by @vexgamedev
--> Aiming to help you with simplicity, and optimizations
--> Whether it's GUI design, network from client -> server, server -> client, you got it.
--> View this link for documentation (scroll down):
--> https://github.com/vexgamedev/VexKit/
--//

local Packages = script:WaitForChild("Packages")
local VexKit = {
	Core = require(Packages:WaitForChild("Core")),
	--[=[
		Core gives you the modules VexKit uses (e.g. Promise)
	--]=]
	
	Input = require(Packages:WaitForChild("Input")),
	--[=[
		Input allows you to easily overwrite detection of keys pressed,
		checking if the player is on PlayStation/Xbox, Phone/Tablet, PC and even VR/PCVR.
		You can easily integrate mobile support to your game with this too (as you can make mobile buttons on the screen)
		FYI: Mobile Buttons are powered by Vex.GUI
	--]=]
	
	Timer = require(Packages:WaitForChild("Timer")),
	--[=[
		Timer allows you to do an action every or once in requested duration with your specific function,
		works like task.delay, however you can even loop it.
		[⚠️] If looping, add `return true` somewhere to break the loop (!REQUIRED!)
	--]=]
	
	Store = require(Packages:WaitForChild("Store")),
	--[=[
		Store is basically Rodux, allows you easy customization and optimization over stores.
	--]=]
	
	NetBridge = require(Packages:WaitForChild("Net")),
	--[=[
		Net allows you easy and highly secure, optimized connection between the Client To Server, even Server to Client.
		This works by encrypting tables into JSON and send it through using AES and buffers, significantly reducing sent data.
		(PS. this may even save peoples' wifi/celery data lol)
	--]=]
	
	Spr = require(Packages:WaitForChild("Spr")),
	--[=[
		spr (Spring Driven Motion) is a animation object, which will assist you in very smooth motions for objects and/or guis.
		Full credits go to Fractality (@Fraktality): https://github.com/Fraktality/spr
	--]=]
	
	GUI = require(Packages:WaitForChild("GUI")),
	--[=[
		GUI allows you to design user interfaces via Luau code instead of placing stuff in PlayerGui (or in ScreenGui's).
		If you are new to making GUI using Luau, you may practice predicting how the output user interface looks like by:
			1. Designing a GUI in PlayerGui
			2. Inserting objects, then rewriting every properties into luau
				-> E.g. GUI.Create2DElement("Test Frame", "Frame", {
					BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				})
	--]=]
	
	Signal = require(Packages:WaitForChild("Signal")),
	--[=[
		Signal is basically BindableEvent, however you can connect and fire multiple functions at once.
		You can use this if you don't want to make extra unnecessary instances/objects into the game.
	--]=]
	
	Asset = require(Packages:WaitForChild("Asset")),
	--[=[
		Asset allows you to preload objects, and easily make loading screens
		by adding items into the load list, then preloading them all with one function.
		You can even view percentage which for size you can divide by 100 (assuming you're using Scales for loading bars)
	--]=]
	
	Database = require(Packages:WaitForChild("Database"))
	--[=[
		Database allows you to save data while making your code look cleaner,
		almost as if it was written in a different language.
	--]=]
}

--[=[
	For more information, extend this instance and extend Documentation,
	then pick modules that interest you the most.
--]=]

return VexKit
