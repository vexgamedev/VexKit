-- Vex.Input || @vexgamedev
-- Code cringe alert: Level Mild

local Database = { DataStores = {} }
local DataStoreService = require(script.DataStore)

function Database:GetDataStore(Name: string)
	return DataStoreService.new(Name)
end

return Database
