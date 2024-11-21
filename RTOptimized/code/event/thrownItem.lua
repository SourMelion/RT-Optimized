--TO_DO
--simplify bounce plates, make them have a 1 slot inventory, and simply treat the throwing same as
--	-> throwerinserters, handle directionality by a simple property stored on the bounce plate
--	-> litteraly bouncepad.throwDirection = "up"  otehr values, "same" "left" "right" "down"
--	-> probly make a configuration window like bobs and use that to configure distance and direction
--	-> just a simple check for wheter or not the item was thrown to it to determine wheter or not to
--	-> throw it, so it cant be used as a free energy thrower
--rename bouncePlate to bouncepad, its bouncepad ingame why shuld it be different in code

--VARIABLES

--FUNCTIONS

--EVENTS

--RUNTIME

if script.active_mods["Ultracube"] then
	CubethrownItem = require("code.ultracube.cube_flying_items")
end

local function on_tick(event)
	for each, thrownItem in pairs(storage.thrownItem) do
		local clear = true

		if event.tick == thrownItem.LandTick and thrownItem.space == false then
			--game.print(each);	--DEBUG
			local ThingLandedOn = thrownItem.surface.find_entities_filtered({
				position = {
					math.floor(thrownItem.target.x) + 0.5,
					math.floor(thrownItem.target.y) + 0.5,
				},
				collision_mask = "object",
			})[1]
			local LandedOnCargoWagon = thrownItem.surface.find_entities_filtered({
				area = {
					{ thrownItem.target.x - 0.5, thrownItem.target.y - 0.5 },
					{ thrownItem.target.x + 0.5, thrownItem.target.y + 0.5 },
				},
				type = "cargo-wagon",
			})[1]
			-- landed on something
			if ThingLandedOn then
				if string.find(ThingLandedOn.name, "BouncePlate") then -- if that thing was a bounce plate
					if thrownItem.sprite then -- from impact unloader
						thrownItem.sprite.destroy()
						thrownItem.sprite = nil
					end
					if thrownItem.shadow and thrownItem.player == nil then -- from impact unloader
						thrownItem.shadow.destroy()
						thrownItem.shadow = nil
					end
					clear = false
					local unitx = 1
					local unity = 1
					local effect = "BouncePlateParticle"
					if string.find(ThingLandedOn.name, "DirectedBouncePlate") then
						unitx = storage.OrientationUnitComponents[ThingLandedOn.orientation].x
						unity = storage.OrientationUnitComponents[ThingLandedOn.orientation].y
						if thrownItem.player then
							storage.AllPlayers[thrownItem.player.index].PlayerLauncher.direction =
								storage.OrientationUnitComponents[ThingLandedOn.orientation].name
						end
					elseif string.find(ThingLandedOn.name, "DirectorBouncePlate") then
						for section = 1, 4 do
							for slot = 1, 10 do
								local setting = ThingLandedOn.get_or_create_control_behavior()
									.get_section(section)
									.get_slot(slot).value
								if setting and setting.name and setting.name == thrownItem.item then
									if section == 1 then
										unitx = 0
										unity = -1
										effect = "BouncePlateParticlered"
									elseif section == 2 then
										unitx = 1
										unity = 0
										effect = "BouncePlateParticlegreen"
									elseif section == 3 then
										unitx = 0
										unity = 1
										effect = "BouncePlateParticleblue"
									elseif section == 4 then
										unitx = -1
										unity = 0
										effect = "BouncePlateParticleyellow"
									end
									goto labelK
								end
							end
						end
						::labelK:: --we shuld not be using label ffs, not eavrybody knows and
						--	-> understand them and they are very rarely necesarry
						if unitx == 1 and unity == 1 then -- if there is no matching signal
							if
								thrownItem.start.y > thrownItem.target.y
								and math.abs(thrownItem.start.y - thrownItem.target.y)
									> math.abs(thrownItem.start.x - thrownItem.target.x)
							then
								unitx = 0
								unity = -1
							elseif
								thrownItem.start.y < thrownItem.target.y
								and math.abs(thrownItem.start.y - thrownItem.target.y)
									> math.abs(thrownItem.start.x - thrownItem.target.x)
							then
								unitx = 0
								unity = 1
							elseif
								thrownItem.start.x > thrownItem.target.x
								and math.abs(thrownItem.start.y - thrownItem.target.y)
									< math.abs(thrownItem.start.x - thrownItem.target.x)
							then
								unitx = -1
								unity = 0
							elseif
								thrownItem.start.x < thrownItem.target.x
								and math.abs(thrownItem.start.y - thrownItem.target.y)
									< math.abs(thrownItem.start.x - thrownItem.target.x)
							then
								unitx = 1
								unity = 0
							end
						end
					elseif string.find(ThingLandedOn.name, "BouncePlate") then
						---- determine "From" direction ----
						local origin = thrownItem.ThrowerPosition or thrownItem.start
						if
							origin.y > thrownItem.target.y
							and math.abs(origin.y - thrownItem.target.y)
								> math.abs(origin.x - thrownItem.target.x)
						then
							unitx = 0
							unity = -1
						elseif
							origin.y < thrownItem.target.y
							and math.abs(origin.y - thrownItem.target.y)
								> math.abs(origin.x - thrownItem.target.x)
						then
							unitx = 0
							unity = 1
						elseif
							origin.x > thrownItem.target.x
							and math.abs(origin.y - thrownItem.target.y)
								< math.abs(origin.x - thrownItem.target.x)
						then
							unitx = -1
							unity = 0
						elseif
							origin.x < thrownItem.target.x
							and math.abs(origin.y - thrownItem.target.y)
								< math.abs(origin.x - thrownItem.target.x)
						then
							unitx = 1
							unity = 0
						end
					end

					---- Bounce modifiers ----
					-- Defaults --
					local primable = ""
					local range = 9.9
					local RangeBonus = 0
					local SidewaysShift = 0
					local tunez = "bounce"
					if string.find(ThingLandedOn.name, "Train") then
						range = 39.9
					elseif
						ThingLandedOn.name == "BouncePlate5"
						or ThingLandedOn.name == "DirectedBouncePlate5"
					then
						range = 4.9
					elseif
						ThingLandedOn.name == "BouncePlate15"
						or ThingLandedOn.name == "DirectedBouncePlate15"
					then
						range = 14.9
					end

					-- Modifiers --
					if
						ThingLandedOn.name == "PrimerBouncePlate"
						and thrownItem.player == nil
						and prototypes.entity[thrownItem.item .. "-projectileFromRenaiTransportationPrimed"]
					then
						primable = "Primed"
						RangeBonus = 30
						tunez = "PrimeClick"
						effect = "PrimerBouncePlateParticle"
					elseif
						ThingLandedOn.name == "PrimerSpreadBouncePlate"
						and thrownItem.player == nil
						and prototypes.entity[thrownItem.item .. "-projectileFromRenaiTransportationPrimed"]
					then
						primable = "Primed"
						tunez = "PrimeClick"
						effect = "PrimerBouncePlateParticle"
					elseif ThingLandedOn.name == "SignalBouncePlate" then
						ThingLandedOn.get_control_behavior().enabled =
							not ThingLandedOn.get_control_behavior().enabled
						effect = "SignalBouncePlateParticle"
					end

					if not thrownItem.tracing then --if its an item and not a tracer
						---- Creating the bounced thing ----
						if primable == "Primed" then
							for kidamogus = 1, thrownItem.amount do
								if ThingLandedOn.name == "PrimerSpreadBouncePlate" then
									RangeBonus = math.random(270, 300) * 0.1
									SidewaysShift = math.random(-200, 200) * 0.1
								end
								ThingLandedOn.surface.create_entity({
									name = thrownItem.item
										.. "-projectileFromRenaiTransportation"
										.. primable,
									position = ThingLandedOn.position, --required setting for rendering, doesn't affect spawn
									source = event.source_entity, --defaults to nil if there was no source_entity and uses source_position instead
									source_position = ThingLandedOn.position,
									target_position = {
										ThingLandedOn.position.x
											+ unitx * (range + RangeBonus)
											+ unity * SidewaysShift,
										ThingLandedOn.position.y
											+ unity * (range + RangeBonus)
											+ unitx * SidewaysShift,
									},
									force = ThingLandedOn.force,
								})
							end
						else
							local TargetX = ThingLandedOn.position.x
								+ unitx * (range + RangeBonus)
								+ unity * SidewaysShift
							local TargetY = ThingLandedOn.position.y
								+ unity * (range + RangeBonus)
								+ unitx * SidewaysShift
							local distance = math.sqrt(
								(TargetX - ThingLandedOn.position.x) ^ 2
									+ (TargetY - ThingLandedOn.position.y) ^ 2
							)
							if string.find(ThingLandedOn.name, "Train") then
								thrownItem.speed = 0.6
							else
								thrownItem.speed = 0.18
							end
							local AirTime = math.floor(distance / thrownItem.speed)
							thrownItem.target = { x = TargetX, y = TargetY }
							thrownItem.start = ThingLandedOn.position
							thrownItem.ThrowerPosition = ThingLandedOn.position
							thrownItem.StartTick = game.tick
							thrownItem.AirTime = AirTime
							thrownItem.LandTick = game.tick + AirTime
							if thrownItem.player == nil then -- the player doesnt have a projectile sprite
								if
									prototypes.entity["RTItemProjectile-" .. thrownItem.item .. thrownItem.speed * 100]
								then
									thrownItem.surface.create_entity({
										name = "RTItemProjectile-"
											.. thrownItem.item
											.. thrownItem.speed * 100,
										position = ThingLandedOn.position,
										source_position = ThingLandedOn.position,
										target_position = { TargetX, TargetY },
									})
								else
									thrownItem.surface.create_entity({
										name = "RTTestProjectile" .. thrownItem.speed * 100,
										position = ThingLandedOn.position,
										source_position = ThingLandedOn.position,
										target_position = { TargetX, TargetY },
									})
								end

								-- (If applicable) Update Ultracube ownership token to keep its timeout set to just after each bounce
								if storage.Ultracube and thrownItem.cube_token_id then -- Ultracube is active, and the flying item has an associated ownership token
									CubethrownItem.bounce_update(thrownItem)
								end
							else -- the player does have a vector
								thrownItem.vector = {
									x = TargetX - ThingLandedOn.position.x,
									y = TargetY - ThingLandedOn.position.y,
								}
							end
						end
						ThingLandedOn.surface.create_particle({
							name = effect,
							position = ThingLandedOn.position,
							movement = { 0, 0 },
							height = 0,
							vertical_speed = 0.1,
							frame_speed = 1,
						})
						ThingLandedOn.surface.play_sound({
							path = tunez,
							position = ThingLandedOn.position,
							volume = 0.7,
						})
					else --it is a tracer
						-- add the bounce pad to the bounce path list if its a tracer
						if primable ~= "Primed" then
							local OnDestroyNumber =
								script.register_on_object_destroyed(ThingLandedOn)
							if storage.ThrowerPaths[OnDestroyNumber] == nil then
								storage.ThrowerPaths[OnDestroyNumber] = {}
								storage.ThrowerPaths[OnDestroyNumber][thrownItem.tracing] = {}
								storage.ThrowerPaths[OnDestroyNumber][thrownItem.tracing][thrownItem.item] =
									true
							elseif
								storage.ThrowerPaths[OnDestroyNumber][thrownItem.tracing] == nil
							then
								storage.ThrowerPaths[OnDestroyNumber][thrownItem.tracing] = {}
								storage.ThrowerPaths[OnDestroyNumber][thrownItem.tracing][thrownItem.item] =
									true
							else
								storage.ThrowerPaths[OnDestroyNumber][thrownItem.tracing][thrownItem.item] =
									true
							end

							local x = ThingLandedOn.position.x
								+ unitx * (range + RangeBonus)
								+ unity * SidewaysShift
							local y = ThingLandedOn.position.y
								+ unity * (range + RangeBonus)
								+ unitx * SidewaysShift
							thrownItem.target = { x = x, y = y }
							thrownItem.start = ThingLandedOn.position
							thrownItem.StartTick = game.tick
							thrownItem.AirTime = 1
							thrownItem.LandTick = game.tick + 1
						else
							storage.CatapultList[thrownItem.tracing].ImAlreadyTracer = "traced"
							storage.CatapultList[thrownItem.tracing].targets[thrownItem.item] =
								"nothing"
							clear = true
						end
					end

					-- non-tracers falling on something
				elseif thrownItem.tracing == nil then
					-- players falling on something
					if thrownItem.player then
						---- Doesn't make sense for player landing on cliff to destroy it ----
						if ThingLandedOn.name == "cliff" then
							thrownItem.player.teleport(
								ThingLandedOn.surface.find_non_colliding_position(
									"iron-chest",
									thrownItem.target,
									0,
									0.5
								)
							)
						elseif ThingLandedOn.name ~= "PlayerLauncher" then
							---- Damage the player based on thing's size and destroy what they landed on to prevent getting stuck ----
							thrownItem.player.character.damage(
								10
									* (ThingLandedOn.bounding_box.right_bottom.x - ThingLandedOn.bounding_box.left_top.x)
									* (
										ThingLandedOn.bounding_box.right_bottom.y
										- ThingLandedOn.bounding_box.left_top.y
									),
								"neutral",
								"impact",
								ThingLandedOn
							)
							ThingLandedOn.die()
						end
						-- items falling on something
					else
						if
							ThingLandedOn.name == "OpenContainer"
							and ThingLandedOn.can_insert({
								name = thrownItem.item,
								quality = thrownItem.quality,
							})
						then
							if thrownItem.CloudStorage then
								ThingLandedOn.insert(thrownItem.CloudStorage[1])
								thrownItem.CloudStorage.destroy()
							elseif storage.Ultracube and thrownItem.cube_token_id then -- Ultracube is active, and the flying item has an associated ownership token
								CubethrownItem.release_and_insert(thrownItem, ThingLandedOn)
							else
								ThingLandedOn.insert({
									name = thrownItem.item,
									count = thrownItem.amount,
								})
							end
							ThingLandedOn.surface.play_sound({
								path = "RTClunk",
								position = ThingLandedOn.position,
								volume_modifier = 0.9,
							})

							---- If the thing it landed on has an inventory and a hatch, insert the item ----
						elseif
							ThingLandedOn.surface.find_entity("HatchRT", {
								math.floor(thrownItem.target.x) + 0.5,
								math.floor(thrownItem.target.y) + 0.5,
							}) and ThingLandedOn.can_insert({ name = thrownItem.item })
						then
							if thrownItem.CloudStorage then
								ThingLandedOn.insert(thrownItem.CloudStorage[1])
								thrownItem.CloudStorage.destroy()
							elseif storage.Ultracube and thrownItem.cube_token_id then -- Ultracube is active, and the flying item has an associated ownership token
								CubethrownItem.release_and_insert(thrownItem, ThingLandedOn)
							else
								ThingLandedOn.insert({
									name = thrownItem.item,
									count = thrownItem.amount,
								})
							end
							ThingLandedOn.surface.play_sound({
								path = "RTClunk",
								position = ThingLandedOn.position,
								volume_modifier = 0.7,
							})

							---- If it landed on something but there's also a cargo wagon there
						elseif
							LandedOnCargoWagon ~= nil
							and LandedOnCargoWagon.can_insert({ name = thrownItem.item })
						then
							if thrownItem.CloudStorage then
								LandedOnCargoWagon.insert(thrownItem.CloudStorage[1])
								thrownItem.CloudStorage.destroy()
							elseif storage.Ultracube and thrownItem.cube_token_id then -- Ultracube is active, and the flying item has an associated ownership token
								CubethrownItem.release_and_insert(thrownItem, LandedOnCargoWagon)
							else
								LandedOnCargoWagon.insert({
									name = thrownItem.item,
									count = thrownItem.amount,
								})
							end

							-- If it's an Ultracube thrownItem, just spill it near whatever it landed on, potentially onto a belt
						elseif storage.Ultracube and thrownItem.cube_token_id then -- Ultracube is active, and the flying item has an associated ownership token
							CubethrownItem.release_and_spill(thrownItem, ThingLandedOn)

							---- otherwise it bounces off whatever it landed on and lands as an item on the nearest empty space within 10 tiles. destroyed if no space ----
						else
							if thrownItem.CloudStorage then -- for things with data/tags or whatever, should only ever be 1 in stack
								if ThingLandedOn.type == "transport-belt" then
									for l = 1, 2 do
										for i = 0, 0.9, 0.1 do
											if
												thrownItem.CloudStorage[1].count > 0
												and ThingLandedOn.get_transport_line(l).can_insert_at(i) == true
											then
												ThingLandedOn.get_transport_line(l)
													.insert_at(i, thrownItem.CloudStorage[1])
												thrownItem.CloudStorage[1].count = thrownItem.CloudStorage[1].count
													- 1
											end
										end
									end
								end
								thrownItem.CloudStorage.destroy()
							else -- depreciated drop method from old item tracking system
								local total = thrownItem.amount
								if ThingLandedOn.type == "transport-belt" then
									for l = 1, 2 do
										for i = 0, 0.9, 0.1 do
											if
												total > 0
												and ThingLandedOn.get_transport_line(l).can_insert_at(i) == true
											then
												ThingLandedOn.get_transport_line(l)
													.insert_at(i, { name = thrownItem.item, count = 1 })
												total = total - 1
											end
										end
									end
								end
								if total > 0 then
									if settings.global["RTSpillSetting"].value == "Destroy" then
										thrownItem.surface.pollute(thrownItem.target, total * 0.5)
										thrownItem.surface.create_entity({
											name = "water-splash",
											position = thrownItem.target,
										})
									else
										local spilt = thrownItem.surface.spill_item_stack({
											position = thrownItem.surface.find_non_colliding_position(
												"item-on-ground",
												thrownItem.target,
												500,
												0.1
											),
											stack = {
												name = thrownItem.item,
												count = total,
												quality = thrownItem.quality,
											},
										})
										if settings.global["RTSpillSetting"].value == "Spill and Mark" then
											for every, thing in pairs(spilt) do
												thing.order_deconstruction("player")
											end
										end
									end
								end
							end
						end
					end
					-- tracers falling on something
				else
					if storage.CatapultList[thrownItem.tracing] then
						if LandedOnCargoWagon then
							local OnDestroyNumber =
								script.register_on_object_destroyed(LandedOnCargoWagon)
							storage.CatapultList[thrownItem.tracing].targets[thrownItem.item] =
								LandedOnCargoWagon
							if storage.ThrowerPaths[OnDestroyNumber] == nil then
								storage.ThrowerPaths[OnDestroyNumber] = {}
								storage.ThrowerPaths[OnDestroyNumber][thrownItem.tracing] = {}
								storage.ThrowerPaths[OnDestroyNumber][thrownItem.tracing][thrownItem.item] =
									true
							elseif
								storage.ThrowerPaths[OnDestroyNumber][thrownItem.tracing] == nil
							then
								storage.ThrowerPaths[OnDestroyNumber][thrownItem.tracing] = {}
								storage.ThrowerPaths[OnDestroyNumber][thrownItem.tracing][thrownItem.item] =
									true
							else
								storage.ThrowerPaths[OnDestroyNumber][thrownItem.tracing][thrownItem.item] =
									true
							end
						elseif ThingLandedOn.unit_number == nil then -- cliffs/trees/other things without unit_numbers
							storage.CatapultList[thrownItem.tracing].targets[thrownItem.item] =
								"nothing"
						else
							local OnDestroyNumber =
								script.register_on_object_destroyed(ThingLandedOn)
							storage.CatapultList[thrownItem.tracing].targets[thrownItem.item] =
								ThingLandedOn
							if storage.ThrowerPaths[OnDestroyNumber] == nil then
								storage.ThrowerPaths[OnDestroyNumber] = {}
								storage.ThrowerPaths[OnDestroyNumber][thrownItem.tracing] = {}
								storage.ThrowerPaths[OnDestroyNumber][thrownItem.tracing][thrownItem.item] =
									true
							elseif
								storage.ThrowerPaths[OnDestroyNumber][thrownItem.tracing] == nil
							then
								storage.ThrowerPaths[OnDestroyNumber][thrownItem.tracing] = {}
								storage.ThrowerPaths[OnDestroyNumber][thrownItem.tracing][thrownItem.item] =
									true
							else
								storage.ThrowerPaths[OnDestroyNumber][thrownItem.tracing][thrownItem.item] =
									true
							end
						end
						storage.CatapultList[thrownItem.tracing].ImAlreadyTracer = "traced"
					end
				end

				-- didn't land on anything
			elseif thrownItem.tracing == nil then -- thrown items
				local ProjectileSurface = thrownItem.surface
				if
					ProjectileSurface.find_tiles_filtered({
						position = thrownItem.target,
						radius = 1,
						limit = 1,
						collision_mask = "lava_tile",
					})[1] ~= nil
				then
					ProjectileSurface.create_entity({
						name = "wall-explosion",
						position = thrownItem.target,
					})
					ProjectileSurface.create_trivial_smoke({
						name = "fire-smoke",
						position = thrownItem.target,
					})
					if thrownItem.player then
						thrownItem.player.character.die()
					else
						if
							(
								thrownItem.item == "ironclad"
								or thrownItem.item == "ironclad-ironclad-mortar"
								or thrownItem.item == "ironclad-ironclad-cannon"
							)
							and script.active_mods["aai-vehicles-ironclad"]
							and ProjectileSurface.can_place_entity({
									name = "ironclad",
									position = thrownItem.target,
								})
								== true
						then
							ProjectileSurface.create_entity({
								name = thrownItem.item,
								position = thrownItem.target,
								force = "player",
								raise_built = true,
							})
						elseif storage.Ultracube and thrownItem.cube_token_id then -- Ultracube is active, and the flying item has an associated ownership token
							CubethrownItem.panic(thrownItem) -- Purposefully resort to Ultracube forced recovery
						else
							ProjectileSurface.pollute(thrownItem.target, thrownItem.amount * 0.5)
						end

						if thrownItem.CloudStorage then
							thrownItem.CloudStorage.destroy()
						end
					end
				elseif
					ProjectileSurface.find_tiles_filtered({
						position = thrownItem.target,
						radius = 0.01,
						limit = 1,
						collision_mask = "player",
					})[1] ~= nil
				then -- in theory, tiles the player cant walk on are some sort of fluid or other non-survivable ground
					ProjectileSurface.create_entity({
						name = "water-splash",
						position = thrownItem.target,
					})
					for eee = 1, 2 do
						ProjectileSurface.create_particle({
							name = "metal-particle-small",
							position = thrownItem.target,
							movement = { -0.01, 0 },
							height = 0,
							vertical_speed = -0.1,
							frame_speed = 0,
						})
					end

					if thrownItem.player then
						thrownItem.player.character.die()
					else
						if thrownItem.item == "raw-fish" then
							for i = 1, math.floor(thrownItem.amount / 5) do
								ProjectileSurface.create_entity({
									name = "fish",
									position = thrownItem.target,
								})
							end
						elseif
							(
								thrownItem.item == "ironclad"
								or thrownItem.item == "ironclad-ironclad-mortar"
								or thrownItem.item == "ironclad-ironclad-cannon"
							)
							and script.active_mods["aai-vehicles-ironclad"]
							and ProjectileSurface.can_place_entity({
									name = "ironclad",
									position = thrownItem.target,
								})
								== true
						then
							ProjectileSurface.create_entity({
								name = thrownItem.item,
								position = thrownItem.target,
								force = "player",
								raise_built = true,
							})
						elseif storage.Ultracube and thrownItem.cube_token_id then -- Ultracube is active, and the flying item has an associated ownership token
							CubethrownItem.panic(thrownItem) -- Purposefully resort to Ultracube forced recovery
						else
							ProjectileSurface.pollute(thrownItem.target, thrownItem.amount * 0.5)
						end

						if thrownItem.CloudStorage then
							thrownItem.CloudStorage.destroy()
						end
					end
				else
					if thrownItem.player == nil then
						if thrownItem.CloudStorage then
							local spilt = ProjectileSurface.spill_item_stack({
								position = ProjectileSurface.find_non_colliding_position(
									"item-on-ground",
									thrownItem.target,
									500,
									0.1
								),
								stack = thrownItem.CloudStorage[1],
							})
							if settings.global["RTSpillSetting"].value == "Spill and Mark" then
								for every, thing in pairs(spilt) do
									thing.order_deconstruction("player")
								end
							end
							thrownItem.CloudStorage.destroy()
						elseif storage.Ultracube and thrownItem.cube_token_id then -- Ultracube is active, and the flying item has an associated ownership token
							CubethrownItem.release_and_spill(thrownItem)
						else
							local spilt = ProjectileSurface.spill_item_stack({
								position = ProjectileSurface.find_non_colliding_position(
									"item-on-ground",
									thrownItem.target,
									500,
									0.1
								),
								stack = {
									name = thrownItem.item,
									count = thrownItem.amount,
									quality = thrownItem.quality,
								},
							})
							if settings.global["RTSpillSetting"].value == "Spill and Mark" then
								for every, thing in pairs(spilt) do
									thing.order_deconstruction("player")
								end
							end
						end
					end
				end

				-- tracer
			elseif
				thrownItem.tracing ~= nil and storage.CatapultList[thrownItem.tracing]
			then
				--game.print(thrownItem.tracing)
				storage.CatapultList[thrownItem.tracing].ImAlreadyTracer = "traced"
				storage.CatapultList[thrownItem.tracing].targets[thrownItem.item] =
					"nothing"
			end

			if clear == true then
				if
					thrownItem.tracing == nil
					and thrownItem.destination ~= nil
					and storage.OnTheWay[thrownItem.destination]
				then
					storage.OnTheWay[thrownItem.destination][thrownItem.item] = storage.OnTheWay[thrownItem.destination][thrownItem.item]
						- thrownItem.amount
				end
				if thrownItem.player then
					storage.AllPlayers[thrownItem.player.index].state = "default"
					thrownItem.player.character_running_speed_modifier = thrownItem.IAmSpeed
					thrownItem.player.character.walking_state =
						{ walking = false, direction = thrownItem.player.character.direction }
				end
				if thrownItem.sprite then -- from impact unloader
					thrownItem.sprite.destroy()
				end
				if thrownItem.shadow then -- from impact unloader
					thrownItem.shadow.destroy()
				end
				storage.thrownItem[each] = nil
			end
		elseif event.tick == thrownItem.LandTick and thrownItem.space == true then
			if thrownItem.sprite then -- from impact unloader/space throw
				thrownItem.sprite.destroy()
			end
			if thrownItem.shadow then -- from impact unloader/space throw
				thrownItem.shadow.destroy()
			end
			storage.thrownItem[each] = nil
		end

		-- Ultracube non-sprite item position updating. Only done for items that require hinting as those are the ones the cube camera follows
		if
			storage.Ultracube
			and thrownItem.sprite == nil
			and thrownItem.cube_should_hint
			and event.tick < thrownItem.LandTick
		then
			CubethrownItem.item_with_stream_update(thrownItem)
		end
	end
end

return on_tick
