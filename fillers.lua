local getStackToTheRight = powertools.getStackToTheRight

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
			if node.name == "air" then
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
	description = "Floor Filler", --[[\nDigs tool.stackcount downwards, including punched node",]]
	inventory_image = "powertools_filler_floor.png",
	on_use = function(itemstack, user, pointed_thing)
		if pointed_thing.type == "node" then
			local to_place = getStackToTheRight(user)
			if to_place and minetest.registered_nodes[to_place] then
				local pos = pointed_thing.above
				local res = spreadFloor(pos, 15 * itemstack:get_count())
				-- to turn a radius of 10 into a manhattan radius:
				--   solve for 2x: sqrt(x^2 + x^2) = 10
				--   gives 2x = 14.14, rounded up is 15
				if res then
					for i = 1, #res do
						local toplace_pos = res[i]
						minetest.set_node(toplace_pos, {name = to_place})
					end
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
