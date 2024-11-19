local function on_tick(event)
	--| Players
	for ThePlayer, PlayerProperties in pairs(storage.AllPlayers) do
		local player = game.players[ThePlayer]
		--|| Player Launchers
		if PlayerProperties.state == "jumping" and player.character and PlayerProperties.sliding ~= true then
			player.character_running_speed_modifier = -0.75
			local FlyingItem = storage.FlyingItems[PlayerProperties.PlayerLauncher.tracker]
			local duration = game.tick - FlyingItem.StartTick
			local progress = duration / FlyingItem.AirTime
			local height = (duration / (FlyingItem.arc * FlyingItem.AirTime))
				- (duration ^ 2 / (FlyingItem.arc * FlyingItem.AirTime ^ 2))
			player
				.character
				.teleport -- predefined bounce "animation"({
					FlyingItem.start.x + (progress * FlyingItem.vector.x),
					FlyingItem.start.y + (progress * FlyingItem.vector.y) + height,
				})
			if PlayerProperties.PlayerLauncher.direction == "right" then
				player.character.walking_state = { walking = true, direction = defines.direction.east }
			elseif PlayerProperties.PlayerLauncher.direction == "left" then
				player.character.walking_state = { walking = true, direction = defines.direction.west }
			elseif PlayerProperties.PlayerLauncher.direction == "up" then
				player.character.walking_state = { walking = true, direction = defines.direction.north }
			elseif PlayerProperties.PlayerLauncher.direction == "down" then
				player.character.walking_state = { walking = true, direction = defines.direction.south }
			end

		--|| Ziplines
		elseif
			PlayerProperties.state == "zipline"
			and PlayerProperties.zipline.LetMeGuideYou
			and PlayerProperties.zipline.LetMeGuideYou.valid
			and player.character
		then
			local ZiplineStuff = PlayerProperties.zipline
			player.character.character_running_speed_modifier = -0.99999

			--||| Set the destination
			if
				ZiplineStuff.WhereDidYouComeFrom ~= nil
				and ZiplineStuff.WhereDidYouComeFrom.valid == true
				and ZiplineStuff.WhereDidYouGo == nil
				and ZiplineStuff.WhereDidYouComeFrom.get_wire_connector(defines.wire_connector_id.pole_copper, true).connection_count
					> 0
			then
				--game.print("searching"..game.tick)
				player.character.teleport({
					ZiplineStuff.ChuggaChugga.position.x,
					1.5 + ZiplineStuff.ChuggaChugga.position.y,
				})
				ZiplineStuff.succ.teleport(ZiplineStuff.WhereDidYouComeFrom.position)
				--|||| Analyze neighbors
				local possibilities = ZiplineStuff.WhereDidYouComeFrom.get_wire_connector(
					defines.wire_connector_id.pole_copper,
					true
				).real_connections -- table of connected pole entities
				for each, connection in pairs(possibilities) do
					local pole = connection.target.owner
					if ElectricPoleBlackList[pole.name] then
						possibilities[each] = nil
					end
				end
				local AngleSorted = {}
				local AutoPathHeading
				if ZiplineStuff.path == nil then
					--|||| Group them by direction
					for i, connection in pairs(possibilities) do
						local pole = connection.target.owner
						if pole.type == "electric-pole" and pole.type ~= "entity-ghost" then
							local ToXWireOffset3 =
								prototypes.recipe["RTGetTheGoods-" .. pole.name .. "X"].emissions_multiplier
							local ToYWireOffset3 =
								prototypes.recipe["RTGetTheGoods-" .. pole.name .. "Y"].emissions_multiplier
							local WhichWay = (
								math.deg(
									math.atan2(
										(
											ZiplineStuff.WhereDidYouComeFrom.position.y - (
												pole.position.y + ToYWireOffset3
											)
										),
										(
											ZiplineStuff.WhereDidYouComeFrom.position.x - (
												pole.position.x + ToXWireOffset3
											)
										)
									)
								) / 1
							) - 90

							if WhichWay < 0 then -- converts all results to 0 -> +1 orientation notation
								WhichWay = 360 + WhichWay
							end
							--game.print(WhichWay)
							if (WhichWay >= 337.5 and WhichWay < 360) or (WhichWay >= 0 and WhichWay < 22.5) then --U
								AngleSorted[0] = pole
							elseif WhichWay >= 22.5 and WhichWay < 67.5 then --UR
								AngleSorted[2] = pole
							elseif WhichWay >= 67.5 and WhichWay < 112.5 then --R
								AngleSorted[4] = pole
							elseif WhichWay >= 112.5 and WhichWay < 157.5 then --DR
								AngleSorted[6] = pole
							elseif WhichWay >= 157.5 and WhichWay < 202.5 then --D
								AngleSorted[8] = pole
							elseif WhichWay >= 202.5 and WhichWay < 247.5 then --DL
								AngleSorted[10] = pole
							elseif WhichWay >= 247.5 and WhichWay < 292.5 then --L
								AngleSorted[12] = pole
							elseif WhichWay >= 292.5 and WhichWay < 337.5 then --UL
								AngleSorted[14] = pole
							end
						end
					end
				else
					local pole
					for i, d in pairs(ZiplineStuff.path) do
						pole = d
						break
					end
					if pole.valid == false then
						GetOffZipline(player, PlayerProperties)
						player.print({ "zipline-stuff.missing" })
						break
					end
					local ToXWireOffset3 = prototypes.recipe["RTGetTheGoods-" .. pole.name .. "X"].emissions_multiplier
					local ToYWireOffset3 = prototypes.recipe["RTGetTheGoods-" .. pole.name .. "Y"].emissions_multiplier
					local WhichWay = (
						math.deg(
							math.atan2(
								(ZiplineStuff.LetMeGuideYou.position.y - (pole.position.y + ToYWireOffset3)),
								(ZiplineStuff.LetMeGuideYou.position.x - (pole.position.x + ToXWireOffset3))
							)
						) / 1
					) - 90

					if WhichWay < 0 then -- converts all results to 0 -> +1 orientation notation
						WhichWay = 360 + WhichWay
					end
					--game.print(WhichWay)
					if (WhichWay >= 337.5 and WhichWay < 360) or (WhichWay >= 0 and WhichWay < 22.5) then --U
						AutoPathHeading = 0
					elseif WhichWay >= 22.5 and WhichWay < 67.5 then --UR
						AutoPathHeading = 1
					elseif WhichWay >= 67.5 and WhichWay < 112.5 then --R
						AutoPathHeading = 2
					elseif WhichWay >= 112.5 and WhichWay < 157.5 then --DR
						AutoPathHeading = 3
					elseif WhichWay >= 157.5 and WhichWay < 202.5 then --D
						AutoPathHeading = 4
					elseif WhichWay >= 202.5 and WhichWay < 247.5 then --DL
						AutoPathHeading = 5
					elseif WhichWay >= 247.5 and WhichWay < 292.5 then --L
						AutoPathHeading = 6
					elseif WhichWay >= 292.5 and WhichWay < 337.5 then --UL
						AutoPathHeading = 7
					end
				end

				--|||| Check walking state
				if
					player.character.walking_state.walking == true
					or ZiplineStuff.LetMeGuideYou.speed ~= 0
					or ZiplineStuff.path ~= nil
				then
					local FD
					local heading
					if ZiplineStuff.path == nil then
						--||||| Set destination by matching walking state to a neighbor
						local WhenYou = player.character.walking_state.direction
						FD = AngleSorted[WhenYou]
						heading = WhenYou
						if FD == nil then
							if WhenYou == 14 then
								FD = AngleSorted[0]
								heading = 0
							else
								FD = AngleSorted[WhenYou + 2]
								heading = WhenYou + 2
							end
						end
						if FD == nil then
							if WhenYou == 0 then
								FD = AngleSorted[14]
								heading = 14
							else
								FD = AngleSorted[WhenYou - 2]
								heading = WhenYou - 2
							end
						end
					else
						for i, d in pairs(ZiplineStuff.path) do
							FD = d
							break
						end
						heading = AutoPathHeading
					end

					if FD and FD.valid then
						local current = ZiplineStuff.WhereDidYouComeFrom
						local FromXWireOffset =
							prototypes.recipe["RTGetTheGoods-" .. current.name .. "X"].emissions_multiplier
						local FromYWireOffset =
							prototypes.recipe["RTGetTheGoods-" .. current.name .. "Y"].emissions_multiplier
						local ToXWireOffset = prototypes.recipe["RTGetTheGoods-" .. FD.name .. "X"].emissions_multiplier
						local ToYWireOffset = prototypes.recipe["RTGetTheGoods-" .. FD.name .. "Y"].emissions_multiplier
						ZiplineStuff.LetMeGuideYou.teleport({
							current.position.x + FromXWireOffset,
							current.position.y + FromYWireOffset,
						})
						local angle = math.deg(
							math.atan2(
								(ZiplineStuff.LetMeGuideYou.position.y - (FD.position.y + ToYWireOffset)),
								(ZiplineStuff.LetMeGuideYou.position.x - (FD.position.x + ToXWireOffset))
							)
						)
						ZiplineStuff.LetMeGuideYou.orientation = (angle / 360) - 0.25 -- I think because Factorio's grid is x-axis flipped compared to a traditional graph, it needs this -0.25 adjustment
						ZiplineStuff.DaWhey = ZiplineStuff.LetMeGuideYou.orientation
						--storage.AllPlayers[ThePlayer].WhereDidYouComeFrom = arrived
						ZiplineStuff.WhereDidYouGo = FD
						ZiplineStuff.distance = math.sqrt(
							((current.position.y + FromYWireOffset) - (FD.position.y + ToYWireOffset)) ^ 2
								+ ((current.position.x + FromXWireOffset) - (FD.position.x + ToXWireOffset)) ^ 2
						)
						ZiplineStuff.FromWireOffset = { FromXWireOffset, FromYWireOffset }
						ZiplineStuff.ToWireOffset = { ToXWireOffset, ToYWireOffset }
						if heading == 0 then
							ZiplineStuff.ForwardDirection = { [14] = 3, [0] = 3, [2] = 3 }
							ZiplineStuff.BackwardsDirection = { [10] = 3, [8] = 3, [6] = 3 }
						elseif heading == 2 then
							ZiplineStuff.ForwardDirection = { [0] = 3, [2] = 3, [4] = 3 }
							ZiplineStuff.BackwardsDirection = { [12] = 3, [10] = 3, [8] = 3 }
						elseif heading == 4 then
							ZiplineStuff.ForwardDirection = { [2] = 3, [4] = 3, [6] = 3 }
							ZiplineStuff.BackwardsDirection = { [14] = 3, [12] = 3, [10] = 3 }
						elseif heading == 6 then
							ZiplineStuff.ForwardDirection = { [4] = 3, [6] = 3, [8] = 3 }
							ZiplineStuff.BackwardsDirection = { [0] = 3, [14] = 3, [12] = 3 }
						elseif heading == 8 then
							ZiplineStuff.ForwardDirection = { [6] = 3, [8] = 3, [10] = 3 }
							ZiplineStuff.BackwardsDirection = { [2] = 3, [0] = 3, [14] = 3 }
						elseif heading == 10 then
							ZiplineStuff.ForwardDirection = { [8] = 3, [10] = 3, [12] = 3 }
							ZiplineStuff.BackwardsDirection = { [4] = 3, [2] = 3, [0] = 3 }
						elseif heading == 12 then
							ZiplineStuff.ForwardDirection = { [10] = 3, [12] = 3, [14] = 3 }
							ZiplineStuff.BackwardsDirection = { [6] = 3, [4] = 3, [2] = 3 }
						elseif heading == 14 then
							ZiplineStuff.ForwardDirection = { [12] = 3, [14] = 3, [0] = 3 }
							ZiplineStuff.BackwardsDirection = { [8] = 3, [6] = 3, [4] = 3 }
						else
							ZiplineStuff.ForwardDirection = {}
							ZiplineStuff.BackwardsDirection = {}
						end
						--game.print("set destination, heading off in "..heading)
					else
						ZiplineStuff.LetMeGuideYou.speed = 0
						--game.print("not pressing a valid direction")
					end
				else
					ZiplineStuff.LetMeGuideYou.speed = 0
					--game.print("not pressing movement key")
				end

			--||| Do the movement
			elseif
				ZiplineStuff.WhereDidYouComeFrom.valid
				and ZiplineStuff.WhereDidYouGo.valid
				and ZiplineStuff.AreYouStillThere == true
			then
				--|||| Set/calc sliding "properties"
				ZiplineStuff.AreYouStillThere = false
				for the, connection in
					pairs(
						ZiplineStuff.WhereDidYouComeFrom.get_wire_connector(defines.wire_connector_id.pole_copper, true).real_connections
					)
				do
					local pole = connection.target.owner
					if ZiplineStuff.WhereDidYouGo.unit_number == pole.unit_number then
						ZiplineStuff.AreYouStillThere = true
					end
				end

				local FromStart = math.sqrt(
					(ZiplineStuff.LetMeGuideYou.position.y - (ZiplineStuff.WhereDidYouComeFrom.position.y + ZiplineStuff.FromWireOffset[2]))
							^ 2
						+ (ZiplineStuff.LetMeGuideYou.position.x - (ZiplineStuff.WhereDidYouComeFrom.position.x + ZiplineStuff.FromWireOffset[1]))
							^ 2
				)
				local FromEnd = math.sqrt(
					(ZiplineStuff.LetMeGuideYou.position.y - (ZiplineStuff.WhereDidYouGo.position.y + ZiplineStuff.ToWireOffset[2]))
							^ 2
						+ (ZiplineStuff.LetMeGuideYou.position.x - (ZiplineStuff.WhereDidYouGo.position.x + ZiplineStuff.ToWireOffset[1]))
							^ 2
				)
				--game.print("From start "..string.format("%.2f", FromStart).."/"..ZiplineStuff.distance)
				--game.print("From end "..string.format("%.9f", FromEnd).."/"..ZiplineStuff.distance)
				--game.print(FromStart+FromEnd)
				--|||| Before destination
				if FromStart <= ZiplineStuff.distance and FromEnd - 0.1 <= ZiplineStuff.distance then
					if settings.get_player_settings(player)["RTZiplineSmoothSetting"].value == "Bobbing Motion" then
						FollowZip = (
							3
							* (FromStart ^ 2 - FromStart * ZiplineStuff.distance)
							/ ZiplineStuff.distance ^ 2
						)
					else
						FollowZip = 0
					end

					player.character.teleport({
						ZiplineStuff.LetMeGuideYou.position.x,
						2 + ZiplineStuff.LetMeGuideYou.position.y - FollowZip,
					})
					ZiplineStuff.ChuggaChugga.teleport({
						ZiplineStuff.LetMeGuideYou.position.x,
						0.5
							+ ZiplineStuff.LetMeGuideYou.position.y
							- (3 * (FromStart ^ 2 - FromStart * ZiplineStuff.distance) / ZiplineStuff.distance ^ 2),
					})
					ZiplineStuff.LetMeGuideYou.orientation = ZiplineStuff.DaWhey

					if
						player.character.get_inventory(defines.inventory.character_guns)[player.character.selected_gun_index].valid_for_read
						and string.find(
							player.character.get_inventory(defines.inventory.character_guns)[player.character.selected_gun_index].name,
							"RTZiplineItem"
						)
						and player.character.get_inventory(defines.inventory.character_ammo)[player.character.selected_gun_index].valid_for_read
						and (player.character.walking_state.walking == true or ZiplineStuff.path)
						and ZiplineStuff.succ.energy ~= 0
					then
						local EquippedTrolley =
							player.character.get_inventory(defines.inventory.character_guns)[player.character.selected_gun_index].name
						local MaxSpeed = 0.3
						local accel = 0.004
						if EquippedTrolley == "RTZiplineItem" then
							MaxSpeed = 0.3
							accel = 0.004
						elseif EquippedTrolley == "RTZiplineItem2" then
							MaxSpeed = 0.6
							accel = 0.008
						elseif EquippedTrolley == "RTZiplineItem3" then
							MaxSpeed = 1.5
							accel = 0.012
						elseif EquippedTrolley == "RTZiplineItem4" then
							MaxSpeed = 4
							accel = 0.016
						elseif EquippedTrolley == "RTZiplineItem5" then
							MaxSpeed = 10
							accel = 0.05
						end
						if ZiplineStuff.path then
							MaxSpeed = (2 / 3) * MaxSpeed
						end
						if
							game.tick % 2 == 0
							and (
								ZiplineStuff.ForwardDirection[player.character.walking_state.direction] ~= nil
								or ZiplineStuff.path
							)
						then
							if ZiplineStuff.LetMeGuideYou.speed <= MaxSpeed then
								ZiplineStuff.LetMeGuideYou.speed = ZiplineStuff.LetMeGuideYou.speed + (accel * 2) --increments slower than 0.008 don't seem to do anything
							end
						elseif
							ZiplineStuff.path == nil
							and game.tick % 2 == 0
							and ZiplineStuff.BackwardsDirection[player.character.walking_state.direction] ~= nil
						then
							if ZiplineStuff.LetMeGuideYou.speed >= -MaxSpeed then
								ZiplineStuff.LetMeGuideYou.speed = ZiplineStuff.LetMeGuideYou.speed - (accel * 2)
							end
						end
					elseif game.tick % 2 == 0 then
						if ZiplineStuff.LetMeGuideYou.speed > 0 then
							ZiplineStuff.LetMeGuideYou.speed = ZiplineStuff.LetMeGuideYou.speed - 0.004
						elseif ZiplineStuff.LetMeGuideYou.speed < 0 then
							ZiplineStuff.LetMeGuideYou.speed = ZiplineStuff.LetMeGuideYou.speed + 0.004
						end
					end

				--|||| At/After destination
				elseif
					FromStart >= ZiplineStuff.distance
					and #ZiplineStuff.WhereDidYouGo.get_wire_connector(defines.wire_connector_id.pole_copper, true).real_connections
						> 1
				then
					--game.print("Arrived, removing destination to find a new one")
					ZiplineStuff.WhereDidYouComeFrom = ZiplineStuff.WhereDidYouGo
					ZiplineStuff.WhereDidYouGo = nil
					if ZiplineStuff.path then
						for i, d in pairs(ZiplineStuff.path) do
							ZiplineStuff.path[i] = nil
							break
						end
						if
							ZiplineStuff.FinalStop.valid == false
							or ZiplineStuff.WhereDidYouComeFrom.unit_number == ZiplineStuff.FinalStop.unit_number
						then
							GetOffZipline(player, PlayerProperties)
						end
					end

				--|||| Back at start
				elseif
					FromEnd - 0.1 > ZiplineStuff.distance
					and #ZiplineStuff.WhereDidYouGo.get_wire_connector(defines.wire_connector_id.pole_copper, true).real_connections
						> 1
				then
					--game.print("Returned, removing destination to find a new one")
					ZiplineStuff.LetMeGuideYou.speed = 0 --For some reason character gets stuck if I don't do this
					--ZiplineStuff.WhereDidYouComeFrom = ZiplineStuff.WhereDidYouGo
					ZiplineStuff.WhereDidYouGo = nil

				--|||| Hit dead end
				else
					GetOffZipline(player, PlayerProperties)
					--game.print("Dead end")
				end
			--||| Break if poles are invalid (destroyed or something)
			else -- One of the two ends is no longer valid
				GetOffZipline(player, PlayerProperties)
				--game.print("failsafe/wire destroyed")
			end
		--||| Zipline Failsafe
		elseif PlayerProperties.state == "zipline" and PlayerProperties.zipline.path == nil then
			GetOffZipline(player, PlayerProperties)

		--||| Set thrower range before placing
		elseif PlayerProperties.RangeAdjusting == true then
			-- keep it on

			--||| Failsafe failsafe. idk when this would happen but just in case
		elseif PlayerProperties.state ~= "default" and player.connected and player.character then
			player.character_running_speed_modifier = 0
			player.character.destructible = true
		end

		----------------- GUI stuff --------------------
		--[[ if (PlayerProperties.GUI.SwapTo) then
			if (PlayerProperties.GUI.SwapTo == "ZiplineTerminal") then
				ShowZiplineTerminalGUI(player, PlayerProperties.GUI.terminal)
				player.opened = player.gui.screen.RTZiplineTerminalGUI
			end
		elseif (PlayerProperties.GUI.CloseOut) then
			player.opened = nil
		end
		PlayerProperties.GUI = {} ]]
	end
end

return on_tick
