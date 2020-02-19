local getStackToTheRight = powertools.getStackToTheRight
local setStackToTheRight = powertools.setStackToTheRight

local creative_mode = minetest.setting_getbool("creative_mode")

function is_fillable(node_name)
	return node_name == "air" or node_name == "default:water_flowing" or node_name == "default:water_source" or node_name == "default:lava" or node_name == "default:lava_source"
end

-- todo: crafting
local function spreadFloor(start_pos, r)
	local res = {
		node_checked = {},
		to_fill = {},
		hasBeenChecked = function(self, pos)
			return self.node_checked[table.concat({pos.x, pos.y, pos.z}, "_")]
		end,
		markChecked = function(self, pos)
			self.node_checked[table.concat({pos.x, pos.y, pos.z}, "_")] = true
		end,
		addFill = function(self, pos)
			self.to_fill[#self.to_fill + 1] = {x=pos.x, y=pos.y, z=pos.z}
		end,
		foobar = function(self, pos)
			local idx = table.concat({pos.x, pos.y, pos.z}, "_")
			local tmp = self.node_checked[idx]
			self.node_checked[idx] = true
			return tmp
		end
	}

	local open = { { pos = start_pos, r = r} }
	local pointer = 1
	while pointer <= #open do
		local tocheck = open[pointer]
		local pos = tocheck.pos
		pointer = pointer + 1
		if tocheck.r <= 0 then
			return false
		else
			local node = minetest.get_node(pos)
			if is_fillable(node.name) then
				res:addFill(pos)

				local newpos = {x = pos.x - 1, y = pos.y, z = pos.z}
				if not res:foobar(newpos) then
					open[#open + 1] = {
						pos = newpos,
						r = tocheck.r - 1
					}
				end

				local newpos = {x = pos.x + 1, y = pos.y, z = pos.z}
				if not res:foobar(newpos) then
					open[#open + 1] = {
						pos = newpos,
						r = tocheck.r - 1
					}
				end

				local newpos = {x = pos.x, y = pos.y, z = pos.z - 1}
				if not res:foobar(newpos) then
					open[#open + 1] = {
						pos = newpos,
						r = tocheck.r - 1
					}
				end

				local newpos = {x = pos.x, y = pos.y, z = pos.z + 1}
				if not res:foobar(newpos) then
					open[#open + 1] = {
						pos = newpos,
						r = tocheck.r - 1
					}
				end
			end
		end
	end

	return res.to_fill
end

minetest.register_craftitem("powertools:filler_floor", {
	description = "Floor Filler", 
	inventory_image = "powertools_filler_floor.png",
	on_use = function(itemstack, user, pointed_thing)
		if pointed_thing.type == "node" then
			local to_place = getStackToTheRight(user)
			if to_place and minetest.registered_nodes[to_place:get_name()] then
				local pos = pointed_thing.above
				local res = spreadFloor(pos, 15 * itemstack:get_count())
				-- to turn a radius of 10 into a manhattan radius:
				--   solve for 2x: sqrt(x^2 + x^2) = 10
				--   gives 2x = 14.14, rounded up is 15
				if res then
					for i = 1, #res do
						local toplace_pos = res[i]
						if (not creative_mode) and (to_place:get_count() <= 0) then 
							break
						else
							if is_fillable(minetest.get_node(toplace_pos).name) then
								minetest.set_node(toplace_pos, {name = to_place:get_name()})
								to_place:take_item()
							end
						end
					end
					if not creative_mode then setStackToTheRight(user, to_place) end
					minetest.chat_send_player(user:get_player_name(), "Finished placing floor")
				else
					minetest.chat_send_player(user:get_player_name(), "Area too large to fill")
				end
			else
				minetest.chat_send_player(user:get_player_name(),
					"Please put a valid node stack to the right of this tool to set the node to place")
			end
		else
			minetest.chat_send_player(user:get_player_name(), "Please punch a node")
		end
	end
})

function fake_normalize(vec)
	--print("fake_normalize " .. dump(vec))
	local absx = math.abs(vec.x)
	local absz = math.abs(vec.z)
	if absx > absz then
		vec.z = 0
		if absx ~= 0 then
			vec.x = vec.x / absx
		end
	else
		vec.x = 0
		if absz ~= 0 then
			vec.z = vec.z / absz
		end
	end
	vec.y = 0

	--print("returning " .. dump(vec))
	return vec
end

minetest.register_craftitem("powertools:filler_row", {
	description = "Row Filler",
	inventory_image = "powertools_filler_row.png",
	on_use = function(itemstack, user, pointed_thing)
		if pointed_thing.type == "node" then
			local length = itemstack:get_count()
			local to_place = getStackToTheRight(user)
			if to_place and minetest.registered_nodes[to_place:get_name()] then
				local looking_vec = fake_normalize(user:get_look_dir())
				local p = pointed_thing.under
				local to_place_name = to_place:get_name()

				for i = 1,length do
					if (not creative_mode) and (to_place:get_count() <= 0) then 
						break
					else
						-- print("placing at " .. dump(p))
						if is_fillable(minetest.get_node(p).name) then
							to_place:take_item()
							minetest.set_node(p, {name = to_place_name})
						end
						p = vector.add(p, looking_vec)
					end
				end
				-- print("setting back " .. to_place:get_count())
				if not creative_mode then setStackToTheRight(user, to_place) end
			else
				minetest.chat_send_player(user:get_player_name(),
					"Please put a valid node stack to the right of this tool to set the node to place")
			end
		else
			minetest.chat_send_player(user:get_player_name(), "Please punch a node")
		end
	end
})
minetest.register_craft({
	output = "powertools:filler_row",
	recipe = {
		{"default:gold_ingot", "default:gold_ingot", "default:gold_ingot"},
		{"default:emerald", "default:sapphire", "default:emerald"},
		{"default:mese_crystal", "default:mese_crystal", "default:mese_crystal"}
	}
})

minetest.register_craft({
	output = "powertools:filler_floor",
	recipe = {
		{"default:gold_ingot", "default:gold_ingot", "default:gold_ingot"},
		{"default:sapphire", "default:diamond", "default:sapphire"},
		{"default:mese_crystal", "default:mese_crystal", "default:mese_crystal"}
	}
})
