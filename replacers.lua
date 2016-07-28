local getStackToTheRight = powertools.getStackToTheRight

minetest.register_craftitem("powertools:replacer_down_column", {
	description = "Down Column Replacer\n" ..
		"Places tool.stackcount downwards, including punched node\n" ..
		"Node to be placed is of the type of the itemstack to the right",
	inventory_image = "powertools_replacer_down_column.png",
	on_use = function(itemstack, user, pointed_thing)
		if pointed_thing.type == "node" then
			local to_place = getStackToTheRight(user)
			if to_place then
				local pos = pointed_thing.under
				for i = 1, itemstack:get_count() do
					minetest.set_node(pos, {name = to_place})
					pos.y = pos.y - 1
				end
			else
				minetest.chat_send_player(user:get_player_name(), "Please put a node stack to the right of this tool to set the node to place")
			end
		else
			minetest.chat_send_player(user:get_player_name(), "Please punch a node")
		end
	end
})

minetest.register_craftitem("powertools:replacer_up_column", {
	description = "Up Column Replacer\n" ..
		"Places tool.stackcount upwards, including punched node\n" ..
		"Node to be placed is of the type of the itemstack to the right",
	inventory_image = "powertools_replacer_up_column.png",
	on_use = function(itemstack, user, pointed_thing)
		if pointed_thing.type == "node" then
			local to_place = getStackToTheRight(user)
			if to_place then
				local pos = pointed_thing.under
				for i = 1, itemstack:get_count() do
					minetest.set_node(pos, {name = to_place})
					pos.y = pos.y + 1
				end
			else
				minetest.chat_send_player(user:get_player_name(), "Please put a node stack to the right of this tool to set the node to place")
			end
		else
			minetest.chat_send_player(user:get_player_name(), "Please punch a node")
		end
	end
})
