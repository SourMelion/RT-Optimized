-- Thrower Check
---- checks if thrower inserters have something in their hands and it's in the throwing position, then creates the approppriate projectile ----
script.on_nth_tick(3, function(event)
	for catapultID, properties in pairs(storage.CatapultList) do
		local catapult = properties.entity
		if catapult.valid then
			local CatapulyDestroyNumber = script.register_on_object_destroyed(catapult)
			-- power check. low power makes inserter arms stretch
			if
				properties.IsElectric == true
				and catapult.energy / catapult.electric_buffer_size >= 0.9
			then
				catapult.active = true
			elseif
				properties.IsElectric == true
				and catapult.is_connected_to_electric_network() == true
			then
				catapult.active = false
				rendering.draw_animation({
					animation = "RTMOREPOWER",
					x_scale = 0.5,
					y_scale = 0.5,
					target = catapult,
					surface = catapult.surface,
					time_to_live = 4,
				})
			end

			if catapult.held_stack.valid_for_read then -- if it has power
				local HeldItem = catapult.held_stack.name
				-- if it's passed the "half swing" point
				if
					(
						catapult.orientation == 0
						and catapult.held_stack_position.y
							>= catapult.position.y + properties.BurnerSelfRefuelCompensation
					)
					or (catapult.orientation == 0.25 and catapult.held_stack_position.x <= catapult.position.x - properties.BurnerSelfRefuelCompensation)
					or (catapult.orientation == 0.50 and catapult.held_stack_position.y <= catapult.position.y - properties.BurnerSelfRefuelCompensation)
					or (
						catapult.orientation == 0.75
						and catapult.held_stack_position.x
							>= catapult.position.x + properties.BurnerSelfRefuelCompensation
					)
				then
					-- activate/disable thrower based on overflow prevention
					if
						catapult.name ~= "RTThrower-PrimerThrower"
						and settings.global["RTOverflowComp"].value == true
						and properties.InSpace == false
					then
						-- pointing at some entity
						if
							properties.targets[HeldItem]
							and properties.targets[HeldItem].valid -- its an entity
							and storage.OnTheWay[script.register_on_object_destroyed(
								properties.targets[HeldItem]
							)] -- receptions are being tracked for the entity
							and storage.OnTheWay[script.register_on_object_destroyed(
								properties.targets[HeldItem]
							)][HeldItem]
						then -- receptions are being tracked for the entity for the particular item
							local TargetDestroyNumber =
								script.register_on_object_destroyed(properties.targets[HeldItem])
							if properties.targets[HeldItem].type ~= "transport-belt" then
								if storage.OnTheWay[TargetDestroyNumber][HeldItem] < 0 then
									storage.OnTheWay[TargetDestroyNumber][HeldItem] = 0 -- correct any miscalculaltions resulting in negative values
								end
								local total = storage.OnTheWay[TargetDestroyNumber][HeldItem]
									+ catapult.held_stack.count
								local inserted = properties.targets[HeldItem].insert({
									name = HeldItem,
									count = total,
									quality = catapult.held_stack.quality.name,
								})
								if inserted < total then
									catapult.active = false
								else
									catapult.active = true
								end
								if inserted > 0 then -- when the destination is full. Have to check otherwise there's an error
									properties.targets[HeldItem].remove_item({
										name = HeldItem,
										count = inserted,
										quality = catapult.held_stack.quality.name,
									})
								end
							elseif properties.targets[HeldItem].type == "transport-belt" then
								local incomming = 0
								for name, count in pairs(storage.OnTheWay[TargetDestroyNumber]) do
									incomming = incomming + count
								end
								local total = incomming
									+ properties.targets[HeldItem].get_transport_line(1).get_item_count()
									+ properties.targets[HeldItem].get_transport_line(2).get_item_count()
									+ catapult.held_stack.count
								if
									(properties.targets[HeldItem].belt_shape == "straight" and total <= 8)
									or (
										properties.targets[HeldItem].belt_shape ~= "straight" and total <= 7
									)
								then
									catapult.active = true
									if storage.HoverGFX[CatapulyDestroyNumber] then
										for playerID, graphic in
											pairs(storage.HoverGFX[CatapulyDestroyNumber])
										do
											graphic.destroy()
										end
										storage.HoverGFX[CatapulyDestroyNumber] = {}
									end
								else
									catapult.active = false
									if storage.HoverGFX[CatapulyDestroyNumber] == nil then
										storage.HoverGFX[CatapulyDestroyNumber] = {}
									end
									for ID, player in pairs(game.players) do
										if storage.HoverGFX[CatapulyDestroyNumber][ID] == nil then
											local hovering = false
											if
												player.selected
												and player.selected.unit_number == catapult.unit_number
											then
												hovering = true
											end
											storage.HoverGFX[CatapulyDestroyNumber][ID] = rendering.draw_text({
												text = { "RTmisc.EightMax" },
												surface = catapult.surface,
												target = catapult,
												alignment = "center",
												scale = 0.5,
												color = { 1, 1, 1 },
												players = { player },
												visible = hovering,
											})
										end
									end
								end
							end

						-- pointing at nothing/the ground
						elseif properties.targets[HeldItem] == "nothing" then
							catapult.active = true

						-- item needs path validation/is currently tracking path
						elseif properties.targets[HeldItem] == nil then
							-- start path tracking, repeatedly stops here until trace ends, setting the target in properties
							if
								properties.ImAlreadyTracer == nil
								or properties.ImAlreadyTracer == "traced"
							then
								properties.ImAlreadyTracer = "tracing"
								-- set tracer "projectile"
								local AirTime = 1
								storage.thrownItem[storage.FlightNumber] = {
									item = HeldItem, --not like it matters
									amount = 0, --not like it matters
									target = {
										x = properties.entity.drop_position.x,
										y = properties.entity.drop_position.y,
									},
									start = properties.entity.position,
									AirTime = AirTime,
									StartTick = event.tick,
									LandTick = event.tick + AirTime,
									tracing = catapultID,
									surface = catapult.surface,
									space = false, --necessary
								}
								storage.FlightNumber = storage.FlightNumber + 1
							end
							catapult.active = false

						-- first time throws for items to this target
						elseif
							properties.targets[HeldItem]
							and properties.targets[HeldItem].valid
							and storage.OnTheWay[script.register_on_object_destroyed(
									properties.targets[HeldItem]
								)]
								== nil
						then
							storage.OnTheWay[script.register_on_object_destroyed(
								properties.targets[HeldItem]
							)] =
								{}
							storage.OnTheWay[script.register_on_object_destroyed(
								properties.targets[HeldItem]
							)][HeldItem] =
								0

						-- first time throws for this particular item to this target
						elseif
							properties.targets[HeldItem]
							and properties.targets[HeldItem].valid
							and storage.OnTheWay[script.register_on_object_destroyed(
								properties.targets[HeldItem]
							)]
							and storage.OnTheWay[script.register_on_object_destroyed(
									properties.targets[HeldItem]
								)][HeldItem]
								== nil
						then
							storage.OnTheWay[script.register_on_object_destroyed(
								properties.targets[HeldItem]
							)][HeldItem] =
								0
						end
					-- overflow prevention is set to off
					else
						catapult.active = true
					end

					-- if the thrower is still active after the checks then:
					if catapult.active == true then
						if
							catapult.name == "RTThrower-PrimerThrower"
							and prototypes.entity["RTPrimerThrowerShooter-" .. HeldItem]
						then
							catapult.inserter_stack_size_override = 1
							catapult.active = false
							storage.PrimerThrowerLinks[script.register_on_object_destroyed(
								properties.entangled.detector
							)].ready =
								true
						else
							-- starting parameters
							local x = catapult.drop_position.x
							local y = catapult.drop_position.y
							local distance = math.sqrt(
								(x - catapult.held_stack_position.x) ^ 2
									+ (y - catapult.held_stack_position.y) ^ 2
							)
							-- calcaulte projectile parameters
							local start = catapult.held_stack_position
							local speed = 0.18
							if
								catapult.name == "RTThrower-EjectorHatchRT"
								or catapult.name == "RTThrower-FilterEjectorHatchRT"
							then
								distance = math.sqrt(
									(x - catapult.position.x) ^ 2 + (y - catapult.position.y) ^ 2
								) --this is one hella expensive operation --OPTOMIZE-math-1
								start = catapult.position
								speed = 0.25
							else
								catapult.surface.play_sound({
									path = "RTThrow",
									position = catapult.position,
									volume_modifier = 0.2,
								})
							end
							local AirTime = math.max(1, math.floor(distance / speed)) -- for super fast throwers that move right on top of their target
							local DestinationDestroyNumber
							if
								settings.global["RTOverflowComp"].value == true
								and properties.InSpace == false
							then
								if
									properties.targets[HeldItem] ~= nil
									and properties.targets[HeldItem].valid
								then
									DestinationDestroyNumber =
										script.register_on_object_destroyed(properties.targets[HeldItem])
									if storage.OnTheWay[DestinationDestroyNumber] == nil then
										storage.OnTheWay[DestinationDestroyNumber] = {}
										storage.OnTheWay[DestinationDestroyNumber][HeldItem] =
											catapult.held_stack.count
									elseif storage.OnTheWay[DestinationDestroyNumber][HeldItem] == nil then
										storage.OnTheWay[DestinationDestroyNumber][HeldItem] =
											catapult.held_stack.count
									else
										storage.OnTheWay[DestinationDestroyNumber][HeldItem] = storage.OnTheWay[DestinationDestroyNumber][HeldItem]
											+ catapult.held_stack.count
									end
								elseif properties.targets[HeldItem] == "nothing" then -- recheck pointing at nothing/things without unit_numbers
									properties.targets[HeldItem] = nil
								end
							end
							storage.thrownItem[storage.FlightNumber] = {
								item = HeldItem,
								amount = catapult.held_stack.count,
								quality = catapult.held_stack.quality.name,
								thrower = catapult,
								ThrowerPosition = catapult.position,
								target = { x = x, y = y },
								start = start,
								AirTime = AirTime,
								StartTick = game.tick,
								LandTick = game.tick + AirTime,
								destination = DestinationDestroyNumber,
								space = properties.InSpace,
								surface = catapult.surface,
							}
							if properties.InSpace == false then
								if
									prototypes.entity["RTItemProjectile-" .. HeldItem .. speed * 100]
								then
									catapult.surface.create_entity({
										name = "RTItemProjectile-" .. HeldItem .. speed * 100,
										position = catapult.held_stack_position,
										source_position = start,
										target_position = catapult.drop_position,
									})
								else
									catapult.surface.create_entity({
										name = "RTTestProjectile" .. speed * 100,
										position = catapult.held_stack_position,
										source_position = start,
										target_position = catapult.drop_position,
									})
								end
							else
								x = x
									+ (-storage.OrientationUnitComponents[catapult.orientation].x * 100)
								y = y
									+ (-storage.OrientationUnitComponents[catapult.orientation].y * 100)
								distance = math.sqrt(
									(x - catapult.held_stack_position.x) ^ 2
										+ (y - catapult.held_stack_position.y) ^ 2
								)
								AirTime = math.max(1, math.floor(distance / speed))
								local vector = {
									x = x - catapult.held_stack_position.x,
									y = y - catapult.held_stack_position.y,
								}
								local path = {}
								for i = 1, AirTime do
									local progress = i / AirTime
									path[i] = {
										x = catapult.held_stack_position.x + (progress * vector.x),
										y = catapult.held_stack_position.y + (progress * vector.y),
										height = 0,
									}
								end
								path.duration = AirTime
								storage.thrownItem[storage.FlightNumber].path = path
								storage.thrownItem[storage.FlightNumber].space = true
								storage.thrownItem[storage.FlightNumber].LandTick = game.tick + AirTime
								storage.thrownItem[storage.FlightNumber].sprite =
									rendering.draw_sprite({
										sprite = "item/" .. HeldItem,
										x_scale = 0.5,
										y_scale = 0.5,
										target = catapult.held_stack_position,
										surface = catapult.surface,
									})
								storage.thrownItem[storage.FlightNumber].spin = AirTime
							end
							if catapult.held_stack.item_number ~= nil then
								local CloudStorage = game.create_inventory(1)
								CloudStorage.insert(catapult.held_stack)
								storage.thrownItem[storage.FlightNumber].CloudStorage = CloudStorage
							end

							-- Ultracube irreplaceables detection & handling
							if
								storage.Ultracube
								and storage.Ultracube.prototypes.irreplaceable[HeldItem]
							then -- Ultracube mod is active, and the held item is an irreplaceable
								-- Sets cube_token_id and cube_should_hint for the new thrownItem entry
								CubethrownItem.create_token_for(
									storage.thrownItem[storage.FlightNumber]
								)
							end

							storage.FlightNumber = storage.FlightNumber + 1
							catapult.held_stack.clear()
						end
					end
				end
			elseif
				catapult.active == false and catapult.held_stack.valid_for_read == false
			then
				catapult.active = true
			end

			if properties.RangeAdjustable == true then
				local range = catapult.get_signal(
					{ type = "virtual", name = "ThrowerRangeSignal" },
					defines.wire_connector_id.circuit_red
				)
				if properties.range == nil or properties.range ~= range then
					if
						range > 0 and range <= catapult.prototype.inserter_drop_position[2] + 0.1
					then
						catapult.drop_position = {
							catapult.position.x
								+ -range * storage.OrientationUnitComponents[catapult.orientation].x,
							catapult.position.y
								+ -range * storage.OrientationUnitComponents[catapult.orientation].y,
						}
						properties.range = range
						if storage.CatapultList[CatapulyDestroyNumber] then
							storage.CatapultList[CatapulyDestroyNumber].targets = {}
							for componentUN, PathsItsPartOf in pairs(storage.ThrowerPaths) do
								for ThrowerUN, TrackedItems in pairs(PathsItsPartOf) do
									if ThrowerUN == CatapulyDestroyNumber then
										storage.ThrowerPaths[componentUN][ThrowerUN] = {}
									end
								end
							end
						end
					end
				end
			end
		elseif catapult.valid == false then
			storage.CatapultList[catapultID] = nil
		end
	end
end)
