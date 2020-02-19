local getStackToTheRight = powertools.getStackToTheRight

minetest.register_craftitem("powertools:digger_down_column", {
	description = "Down Column Digger", --[[\nDigs tool.stackcount downwards, including punched node",]]
	inventory_image = "powertools_digger_down_column.png",
	on_use = function(itemstack, user, pointed_thing)
		if pointed_thing.type == "node" then
			local pos = pointed_thing.under
			for i=1, itemstack:get_count() do
				minetest.set_node(pos, {name="air"})
				pos.y = pos.y - 1
			end
		else
			minetest.chat_send_player(user:get_player_name(), "Please punch a node")
		end
	end
})

minetest.register_craftitem("powertools:digger_down_column_conditional_start", {
	description = "Conditional (Start) Down Column Digger", --[[\n" ..
		"Digs tool.stackcount downwards, including punched node\n" ..
		"Only works if the punched node is the same as the stack to the right of the tool.",]]
	inventory_image = "powertools_digger_down_column_conditional_start.png",
	on_use = function(itemstack, user, pointed_thing)
		if pointed_thing.type == "node" then
			local condition = getStackToTheRight(user):get_name()
			print(dump(condition))
			local node = minetest.get_node(pointed_thing.under)
			if not condition then
				minetest.chat_send_player(user:get_player_name(), "Please put a node stack to the right of this tool to set the start condition")
			elseif node.name == condition then
				local pos = pointed_thing.under
				for i=1, itemstack:get_count() do
					minetest.set_node(pos, {name="air"})
					pos.y = pos.y - 1
				end
			elseif minetest.registered_nodes[condition] then
				minetest.chat_send_player(user:get_player_name(), "Please punch a node of type " .. condition)
			else
				minetest.chat_send_player(user:get_player_name(), "Please put a valid node stack to the right of this tool. (" ..
					condition .. " is not a valid node)")
			end
		else
			minetest.chat_send_player(user:get_player_name(), "Please punch a node")
		end
	end
})

minetest.register_craftitem("powertools:digger_down_column_conditional_same", {
	description = "Conditional (Same) Down Column Digger", --[[\n" ..
		"Digs tool.stackcount downwards, including punched node\n" ..
		"Only removes nodes that are the same as the stack to the right of the tool",]]
	inventory_image = "powertools_digger_down_column_conditional_same.png",
	on_use = function(itemstack, user, pointed_thing)
		if pointed_thing.type == "node" then
			local condition = getStackToTheRight(user):get_name()
			if condition then
				local pos = pointed_thing.under
				for i=1, itemstack:get_count() do
					if minetest.get_node(pos).name == condition then
						minetest.set_node(pos, {name="air"})
					end
					pos.y = pos.y - 1
				end
			else
				minetest.chat_send_player(user:get_player_name(), "Please put a node stack to the right of this tool to set the condition")
			end
		else
			minetest.chat_send_player(user:get_player_name(), "Please punch a node")
		end
	end
})
