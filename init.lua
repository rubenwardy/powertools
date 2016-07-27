minetest.register_craftitem("powertools:down_stack_digger", {
	description = "Down stack Digger",
	inventory_image = "powertools_down_stack_digger.png",
	on_use = function(itemstack, user, pointed_thing)
		if pointed_thing.type == "node" then
			local node = minetest.get_node(pointed_thing.under)
			local pos = pointed_thing.under
			for i=1, itemstack:get_count() do
				minetest.dig_node(pos)
				pos.y = pos.y - 1
			end
		else
			minetest.chat_send_player(user:get_player_name(), "Please punch a node")
		end
	end
})

minetest.register_craftitem("powertools:down_stack_digger_conditional", {
	description = "Conditional Down Stack Digger",
	inventory_image = "powertools_down_stack_digger_conditional.png",
	on_use = function(itemstack, user, pointed_thing)
		if pointed_thing.type == "node" then
			local condition = "default:dirt_with_grass"
			local node = minetest.get_node(pointed_thing.under)
			if not condition or node.name == condition then
				local pos = pointed_thing.under
				for i=1, itemstack:get_count() do
					minetest.dig_node(pos)
					pos.y = pos.y - 1
				end
			else
				minetest.chat_send_player(user:get_player_name(), "Please punch a node of type " .. condition)
			end
		else
			minetest.chat_send_player(user:get_player_name(), "Please punch a node")
		end
	end
})
