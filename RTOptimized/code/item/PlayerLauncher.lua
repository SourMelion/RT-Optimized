------ the thrower entity ----------
local PikachuFace = table.deepcopy(data.raw.inserter["inserter"])
PikachuFace.name = "PlayerLauncher"
PikachuFace.icon = "__RTOptimized__/graphics/PlayerLauncher/icon.png"
PikachuFace.icon_size = 32
PikachuFace.icon_mipmaps = 4
PikachuFace.minable = { mining_time = 0.2, result = "PlayerLauncherItem" }
PikachuFace.insert_position = { 0, -9.9 }
PikachuFace.pickup_position = { 0, -0.1 }
PikachuFace.hand_size = 0
PikachuFace.collision_box = { { -0.05, -0.05 }, { 0.05, 0.05 } } -- This size keeps it from being STOMPED when a player lands on it
PikachuFace.collision_mask =
	{ layers = { ["item"] = true, ["object"] = true, ["water_tile"] = true } } --not the player so they can step on it
PikachuFace.selection_box = { { -0.35, -0.35 }, { 0.35, 0.35 } }
PikachuFace.extension_speed = 0.027 -- default 0.03
PikachuFace.rotation_speed = 0.03 -- default 0.014
PikachuFace.fast_replaceable_group = nil
PikachuFace.next_upgrade = nil
PikachuFace.energy_source = { type = "void" }
nothing = {
	filename = "__RTOptimized__/graphics/nothing.png",
	priority = "extra-high",
	width = 32,
	height = 32,
	scale = 0.25,
}
PikachuFace.hand_base_picture = nothing
PikachuFace.hand_closed_picture = nothing
PikachuFace.hand_open_picture = nothing
PikachuFace.hand_base_shadow = nothing
PikachuFace.hand_closed_shadow = nothing
PikachuFace.hand_open_shadow = nothing
PikachuFace.platform_picture.sheet = {
	filename = "__RTOptimized__/graphics/PlayerLauncher/PlayerLauncher.png",
	priority = "extra-high",
	width = 105,
	height = 79,
	shift = nil, -- originally util.by_pixel(1.5, 7.5-1),
	scale = 0.5,
	--[[ 			hr_version =
			{
				filename = "__RTOptimized__/graphics/PlayerLauncher/PlayerLauncher.png",
				priority = "extra-high",
				width = 105,
				height = 79,
				shift = nil, -- originally util.by_pixel(1.5, 7.5-1),
				scale = 0.5
			} ]]
}

data:extend({
	{ --------- The thrower item -------------
		type = "item",
		name = "PlayerLauncherItem",
		icon = "__RTOptimized__/graphics/PlayerLauncher/icon.png",
		icon_size = 32,
		icon_mipmaps = 4,
		subgroup = "RT",
		order = "c",
		place_result = "PlayerLauncher",
		stack_size = 50,
	},

	{ --------- The thrower recipie ----------
		type = "recipe",
		name = "PlayerLauncherRecipe",
		enabled = false,
		energy_required = 0.5,
		ingredients = {
			{ type = "item", name = "BouncePlateItem", amount = 1 },
			{ type = "item", name = "iron-plate", amount = 4 },
		},
		results = {
			{ type = "item", name = "PlayerLauncherItem", amount = 1 },
		},
	},

	{ --------- bounce effect ----------
		type = "optimized-particle",
		name = "PlayerLauncherParticle",
		life_time = 8,
		pictures = {
			filename = "__RTOptimized__/graphics/BouncePlates/BouncePlate/Particle.png",
			--width = 64,
			--height = 64,
			size = 32,
			priority = "extra-high",
			line_length = 4, -- frames per row
			frame_count = 4, -- total frames
			animation_speed = 0.5,
		},
	},

	PikachuFace,
})