require("code.technology")
require("code.sounds")
require("code.TabSortingStuff")
require("code.item.Trains.PropHunt")

if settings.startup["RTThrowersSetting"].value == true then
	require("code.item.BouncePlates.BouncePlate")
	require("code.item.BouncePlates.DirectedBouncePlate")
	require("code.item.BouncePlates.DirectorBouncePlate")
	require("code.item.PlayerLauncher")
	require("code.item.OpenContainer")
	require("code.item.hatch")

	if settings.startup["RTBounceSetting"].value == true then
		require("code.item.BouncePlates.PrimerBouncePlate")
		--require("prototypes.BouncePlates.SignalBouncePlate")

		require("code.item.PrimerThrower.CheckingTurret")
		require("code.item.PrimerThrower.PrimerThrowerInserter")

		if settings.startup["RTTrainRampSetting"].value == true then
			require("code.item.Trains.PayloadWagon")
		end
	end

	if
		settings.startup["RTTrainBounceSetting"].value == true
		and settings.startup["RTTrainRampSetting"].value == true
	then
		require("code.item.BouncePlates.TrainBouncePlate")
		require("code.item.BouncePlates.TrainDirectedBouncePlate")
	end
end

if settings.startup["RTTrainRampSetting"].value == true then
	require("code.item.Trains.prototypes.ramps")
	require("code.item.Trains.sprites.base")
	require("code.item.Trains.GhostLoco")
	if settings.startup["RTImpactSetting"].value == true then
		require("code.item.Trains.ImpactWagon")
	end
end

if settings.startup["RTZiplineSetting"].value == true then
	require("code.item.zipline")
end

data:extend({
	{
		type = "custom-input",
		name = "RTInteract",
		key_sequence = "F",
	},
	-- {
	-- type = "custom-input",
	-- name = "RTtcaretnI",
	-- key_sequence = "SHIFT + F"
	-- },
	{
		type = "custom-input",
		name = "RTClick",
		key_sequence = "",
		linked_game_control = "open-gui",
	},
	{
		type = "sprite",
		name = "RTBlank",
		filename = "__RTOptimized__/graphics/nothing.png",
		size = 1,
	},
	{
		type = "animation",
		name = "RTMOREPOWER",
		filename = "__RTOptimized__/graphics/NoPowerBlink.png",
		size = { 64, 64 },
		frame_count = 2,
		line_length = 2,
		animation_speed = 1 / 30,
	},
	{
		type = "animation",
		name = "RTHoojinTime",
		filename = "__RTOptimized__/graphics/TrainRamp/trains/base/WatchHimHooj.png",
		size = { 128, 222 },
		frame_count = 7,
		line_length = 7,
		shift = { 0, -1.5 },
		scale = 0.75,
	},
	{
		type = "sticker",
		name = "RTSaysYourCrosshairIsTooLow",
		duration_in_ticks = math.floor(60 * 28.13),
		working_sound = {
			sound = {
				filename = "__RTOptimized__/graphics/TrainRamp/trains/base/Crank dat Hooja Boi.ogg",
				volume = 0.5,
			},
			use_doppler_shift = false,
		},
	},
	{
		type = "custom-input",
		name = "DebugAdvanceActionProcess",
		key_sequence = "BACKSLASH",
		enabled_while_in_cutscene = true,
	},
	{
		type = "virtual-signal",
		name = "ThrowerRangeSignal",
		icon = "__RTOptimized__/graphics/RangeSignaling.png",
		icon_size = 64,
	},
	{
		type = "stream",
		name = "RTTestProjectile18",
		particle_spawn_interval = 0,
		particle_spawn_timeout = 0,
		particle_vertical_acceleration = 0.0035,
		particle_horizontal_speed = 0.18,
		particle_horizontal_speed_deviation = 0,
		particle = {
			layers = {
				{
					filename = "__RTOptimized__/graphics/icon.png",
					line_length = 1,
					frame_count = 1,
					priority = "high",
					size = 32,
					scale = 19.2 / 32,
				},
			},
		},
		shadow = {
			layers = {
				{
					filename = "__RTOptimized__/graphics/icon.png",
					line_length = 1,
					frame_count = 1,
					priority = "high",
					size = 32,
					scale = 19.2 / 32,
					tint = { 0, 0, 0, 0.5 },
				},
			},
		},
		oriented_particle = true,
	},
	{
		type = "stream",
		name = "RTTestProjectile25",
		particle_spawn_interval = 0,
		particle_spawn_timeout = 0,
		particle_vertical_acceleration = 0.0035,
		particle_horizontal_speed = 0.25,
		particle_horizontal_speed_deviation = 0,
		particle = {
			layers = {
				{
					filename = "__RTOptimized__/graphics/icon.png",
					line_length = 1,
					frame_count = 1,
					priority = "high",
					size = 32,
					scale = 19.2 / 32,
				},
			},
		},
		shadow = {
			layers = {
				{
					filename = "__RTOptimized__/graphics/icon.png",
					line_length = 1,
					frame_count = 1,
					priority = "high",
					size = 32,
					scale = 19.2 / 32,
					tint = { 0, 0, 0, 0.5 },
				},
			},
		},
		oriented_particle = true,
	},
	{
		type = "stream",
		name = "RTTestProjectile60",
		particle_spawn_interval = 0,
		particle_spawn_timeout = 0,
		particle_vertical_acceleration = 0.0035,
		particle_horizontal_speed = 0.6,
		particle_horizontal_speed_deviation = 0,
		particle = {
			layers = {
				{
					filename = "__RTOptimized__/graphics/icon.png",
					line_length = 1,
					frame_count = 1,
					priority = "high",
					size = 32,
					scale = 19.2 / 32,
				},
			},
		},
		shadow = {
			layers = {
				{
					filename = "__RTOptimized__/graphics/icon.png",
					line_length = 1,
					frame_count = 1,
					priority = "high",
					size = 32,
					scale = 19.2 / 32,
					tint = { 0, 0, 0, 0.5 },
				},
			},
		},
		oriented_particle = true,
	},
})
