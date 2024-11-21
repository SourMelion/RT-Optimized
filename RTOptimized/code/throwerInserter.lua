function MakeThrowerVariant(inserter)
	TheItem = nil
	if (TheItem == nil) then
	TheItem = table.deepcopy(data.raw.item[inserter.minable.result])
end
	--TheItem = table.deepcopy(data.raw.item[inserter.minable.result])
	TheItem.name = "RTThrower-" .. TheItem.name .. "-Item"
	TheItem.subgroup = "throwers"
	TheItem.place_result = "RTThrower-" .. inserter.name
	if TheItem.icon then
		TheItem.icons = {
			{
				icon = TheItem.icon,
				icon_size = TheItem.icon_size,
				icon_mipmaps = TheItem.icon_mipmaps,
			},

			{
				icon = "__RTOptimized__/graphics/ThrowerInserter/overlay.png",
				icon_size = 64,
				icon_mipmaps = 4,
			},
		}
	else
		table.insert(TheItem.icons, {
			icon = "__RTOptimized__/graphics/ThrowerInserter/overlay.png",
			icon_size = 64,
			icon_mipmaps = 4,
		})
	end

	if inserter.name == "inserter" or inserter.name == "burner-inserter" then
		isitenabled = true
	else
		isitenabled = false
	end
	TheRecipe = {
		type = "recipe",
		name = "RTThrower-" .. inserter.name .. "-Recipe",
		enabled = isitenabled,
		energy_required = 1,
		ingredients = {
			{ type = "item", name = inserter.minable.result, amount = 1 },
			{ type = "item", name = "copper-cable", amount = 4 },
		},
		results = {
			{ type = "item", name = TheItem.name, amount = 1 },
		},
	}
	TheRecipe.localised_name =
		{ "thrower-gen.name", { "entity-name." .. inserter.name } }
	TheThrower = nil
	if (TheThrower == nil) then
		TheThrower = table.deepcopy(data.raw.inserter[inserter.name])
	end
	--TheThrower = table.deepcopy(data.raw.inserter[inserter.name])
	TheThrower.name = "RTThrower-" .. inserter.name
	TheThrower.minable = { mining_time = 0.1, result = TheItem.name }
	--TheThrower.localised_name ="Thrower "..inserter.name
	TheThrower.localised_name =
		{ "thrower-gen.name", { "entity-name." .. inserter.name } }
	TheThrower.insert_position = { 0, 15.2 }
	TheThrower.allow_custom_vectors = true
	ItsRange = 15

	if TheThrower.energy_per_rotation then
		TheThrower.energy_per_movement = "1J" -- this prevents inserters from elongating first and then rotating when energy is low
	end

	if TheThrower.name == "RTThrower-inserter" then
		TheThrower.extension_speed = 0.027 -- default 0.03, needs to be a but slower so we don't get LongB0is
		TheThrower.rotation_speed = 0.020 -- default 0.014
	elseif TheThrower.name == "RTThrower-long-handed-inserter" then
		TheThrower.insert_position = { 0, 25.2 }
		ItsRange = 25
	end

	if settings.startup["RTThrowersDynamicRange"].value == true then
		local original_inserter = data.raw.inserter[inserter.name]
		ItsRange = math.floor(
			math.sqrt(
				original_inserter.insert_position[1] ^ 2
					+ original_inserter.insert_position[2] ^ 2
			)
		) * 10 + 5
		TheThrower.insert_position = { 0, ItsRange + 0.2 }
	end

	if TheThrower.localised_description then
		TheThrower.localised_description = {
			"thrower-gen.HasDesc",
			tostring(ItsRange),
			TheThrower.localised_description,
		}
	else
		TheThrower.localised_description =
			{ "thrower-gen.DefaultDesc", tostring(ItsRange) }
	end
	TheThrower.hand_size = 0
	TheThrower.hand_base_picture = {
		filename = "__RTOptimized__/graphics/ThrowerInserter/hr-inserter-hand-base.png",
		priority = "extra-high",
		width = 32,
		height = 136,
		scale = 0.25,
	}
	TheThrower.hand_closed_picture = {
		filename = "__RTOptimized__/graphics/ThrowerInserter/hr-inserter-hand-closed.png",
		priority = "extra-high",
		width = 72,
		height = 164,
		scale = 0.25,
	}
	TheThrower.hand_open_picture = {
		filename = "__RTOptimized__/graphics/ThrowerInserter/hr-inserter-hand-open.png",
		priority = "extra-high",
		width = 72,
		height = 164,
		scale = 0.25,
	}

	if mods["Ultracube"] then
		data:extend({ TheThrower, TheItem }) -- Recipes and tech will be handled by Ultracube
	else
		data:extend({ TheThrower, TheItem, TheRecipe })
		if isitenabled == false then
			table.insert(
				data.raw["technology"]["RTThrowerTime"].effects,
				{ type = "unlock-recipe", recipe = TheRecipe.name }
			)
		end
	end
end

--- loop through data.raw ---------------------------------
---- Make thrower variants first so that the projectile generating will work

for key, inserter in pairs(data.raw.inserter) do
	-- lots of requirements to make sure not pick up any "function only" inserters from other mods --
	if
		settings.startup["RTThrowersSetting"].value == true
		and settings.startup["RTModdedThrowers"].value == true
	then
		if
			inserter.type == "inserter"
			and inserter.energy_source.type ~= "void"
			and inserter.draw_held_item ~= false
			and inserter.selectable_in_game ~= false
			and inserter.minable
			and inserter.minable.result
			and inserter.rotation_speed ~= 0
			and inserter.extension_speed ~= 0
			and data.raw.item[inserter.minable.result] ~= nil
			and inserter.selection_box[1][1] >= -0.5
			and inserter.selection_box[1][2] >= -0.5
			and inserter.selection_box[2][1] <= 0.5
			and inserter.selection_box[2][2] <= 0.5
			and not string.find(inserter.name, "RTThrower-")
		then
			MakeThrowerVariant(inserter)
		end
	elseif
		settings.startup["RTThrowersSetting"].value == true
		and settings.startup["RTModdedThrowers"].value == false
	then
		if
			inserter.name == "burner-inserter"
			or inserter.name == "inserter"
			or inserter.name == "fast-inserter"
			or inserter.name == "long-handed-inserter"
			or inserter.name == "filter-inserter"
			or inserter.name == "stack-filter-inserter"
			or inserter.name == "stack-inserter"
		then
			MakeThrowerVariant(inserter)
		end
	end
end
