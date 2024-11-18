local handle_players = require("__RTOptimized__.script.players.on_tick")
local handle_trains = require("__RTOptimized__.script.trains.on_tick")
local handle_items = require("__RTOptimized__.script.event.FlyingItems")

local function on_tick(event)
	handle_players(event)
	handle_trains(event)
	handle_items(event)
	if (storage.clock[game.tick]) then
		--=== destroy
		if (storage.clock[game.tick].destroy) then
			for each, entity in pairs(storage.clock[game.tick].destroy) do
				if (entity.valid) then
					entity.destroy()
				end
			end
		end

	end
end

return on_tick
