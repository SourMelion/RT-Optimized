data:extend({
	{
		type = "sprite",
		name = "RTPrimerRangeOverlay",
		filename = "__RT-Optimized__/graphics/PrimeRange.png",
		size = 640
	},
	
	{
		type = "sprite",
		name = "RTPrimerSpreadRangeOverlay",
		filename = "__RT-Optimized__/graphics/PrimeSpreadRange.png",
		size = 640
	},
	
	{ --------- Bounce plate entity --------------
		type = "simple-entity-with-owner",
		name = "PrimerBouncePlate",
		icon = "__RT-Optimized__/graphics/BouncePlates/PrimerBouncePlate/PrimerPlateIconn.png",
		icon_size = 64,
		flags = {"placeable-neutral", "player-creation"},
		minable = {mining_time = 0.2, result = "PrimerBouncePlateItem"},
		max_health = 200,
	    collision_box = {{-0.25, -0.25}, {0.25, 0.25}}, --{{-0.35, -0.35}, {0.35, 0.35}},
		selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
		fast_replaceable_group = "bouncers",
		picture = 
			{
			layers = 
				{
					{
						filename = "__RT-Optimized__/graphics/BouncePlates/BouncePlate/shadow.png",
						priority = "medium",
						width = 66,
						height = 76,
						shift = util.by_pixel(8, -0.5),
						scale = 0.5
					},
					{
						filename = "__RT-Optimized__/graphics/BouncePlates/PrimerBouncePlate/PrimerPlate.png",
						priority = "medium",
						width = 66,
						height = 76,
						shift = util.by_pixel(-0.5, -0.5),
						scale = 0.5
					},
				}
			},
		radius_visualisation_specification =
			{
				sprite = 
					{
						filename = "__RT-Optimized__/graphics/PrimeRange.png",
						size = 640
					},
				draw_on_selection = true,
				distance = 40
			}
	},
	
	{ --------- The Bounce plate item -------------
		type = "item",
		name = "PrimerBouncePlateItem",
		icon = "__RT-Optimized__/graphics/BouncePlates/PrimerBouncePlate/PrimerPlateIconn.png",
		icon_size = 64, --icon_mipmaps = 4,
		subgroup = "RT",
		order = "a-b",
		place_result = "PrimerBouncePlate",
		stack_size = 50
	},
	
	{ --------- The Bounce plate recipie ----------
		type = "recipe",
		name = "PrimerBouncePlateRecipie",
		enabled = false,
		energy_required = 1,
		ingredients = 
			{
				{type="item", name="BouncePlateItem", amount=1},
				{type="item", name="electronic-circuit", amount=2},
				{type="item", name="coal", amount=5}
			},
		results = {
			{type="item", name="PrimerBouncePlateItem", amount=1}
		}
	},
	
	{ --------- bounce effect ----------
		type = "optimized-particle",
		name = "PrimerBouncePlateParticle",
		life_time = 8,
		render_layer = "higher-object-above",		
		pictures =
			{
			  filename = "__RT-Optimized__/graphics/BouncePlates/PrimerBouncePlate/PrimerParticle.png",
			  --width = 64,
			  --height = 64,
			  size = 32,
			  priority = "extra-high",
			  line_length = 4, -- frames per row
			  frame_count = 4, -- total frames
			  animation_speed = 0.5
			}
	},
--------------------------- Spread mode -------------
	{ --------- Spread mode entity --------------
		type = "simple-entity-with-owner",
		name = "PrimerSpreadBouncePlate",
		icon = "__RT-Optimized__/graphics/BouncePlates/PrimerBouncePlate/PrimerPlateIconn.png",
		icon_size = 64,
		flags = {"placeable-neutral", "player-creation"},
		minable = {mining_time = 0.2, result = "PrimerBouncePlateItem"},
		placeable_by = {item = "PrimerBouncePlateItem", count = 1},
		max_health = 200,
	    collision_box = {{-0.25, -0.25}, {0.25, 0.25}}, --{{-0.35, -0.35}, {0.35, 0.35}},
		selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
		fast_replaceable_group = "bouncers",
		picture = 
			{
			layers =
				{
					{
						filename = "__RT-Optimized__/graphics/BouncePlates/BouncePlate/shadow.png",
						priority = "medium",
						width = 66,
						height = 76,
						shift = util.by_pixel(8, -0.5),
						scale = 0.5
					},
					{
						filename = "__RT-Optimized__/graphics/BouncePlates/PrimerBouncePlate/PrimerSpreadPlate.png",
						priority = "medium",
						width = 66,
						height = 76,
						shift = util.by_pixel(-0.5, -0.5),
						scale = 0.5
					}
				}
			},
		radius_visualisation_specification =
			{
				sprite = 
					{
						filename = "__RT-Optimized__/graphics/PrimeSpreadRange.png",
						size = 640
					},
				draw_on_selection = true,
				distance = 40
			}
	}
})