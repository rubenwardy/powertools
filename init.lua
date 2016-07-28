powertools = {}

function powertools.getStackToTheRight(player)
	local idx = player:get_wield_index()
	local inv = minetest.get_inventory({
		type = "player",
		name = player:get_player_name()
	})
	if idx < player:hud_get_hotbar_itemcount() then
		local stack = inv:get_stack("main", idx + 1)
		return stack and stack:get_name()
	else
		return nil
	end
end

dofile(minetest.get_modpath("powertools") .. "/diggers.lua")
dofile(minetest.get_modpath("powertools") .. "/replacers.lua")
