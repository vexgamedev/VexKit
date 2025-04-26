local Core = {
	Promise = require(script.Promise)
}

function Core:NewPromise(
	callback: (
		resolve: (any?) -> (),
		reject: (string) -> ()
	) -> ()
): typeof(Core.Promise.new())
	return self.Promise.new(callback)
end

function Core.CFrameToTable(Input: CFrame)
	return table.pack(Input:GetComponents())
end

function Core.TableToCFrame(Input: {number})
	return CFrame.new(table.unpack(Input))
end

function Core.Vector3ToTable(Input: Vector3)
	return { Input.X, Input.Y, Input.Z }
end

function Core.TableToVector3(Input: {number})
	return Vector3.new(table.unpack(Input))
end

function Core.Vector2ToTable(Input: Vector2)
	return { Input.X, Input.Y }
end

function Core.TableToVector2(Input: {number})
	return Vector2.new(table.unpack(Input))
end

Core.__index = Core
return Core
