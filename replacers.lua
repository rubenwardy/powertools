local getStackToTheRight = powertools.getStackToTheRight
local p = powertools

-- range fr : to comments are always inclusive

function quickdump(obj)
	minetest.debug(dump(obj))
end

p.smoother = {}

p.Histogram = {}
p.Histogram.__index = p.Histogram

-- wx, wy size for 0 : wx inclusive
-- wx = 2*W
function p.Histogram:new(wx, wy)
	local res = {data={}, wx=wx, wy=wy}
	setmetatable(res, p.Histogram)
	for ix = 0, wx do
		for iy = 0, wy do
			res.data[res:index(ix, iy)] = 0
		end end
	return res
end

-- range  0 : 2W square
function p.Histogram:add(x, y)
	local ix = self:index(x, y)
	self.data[ix] = self.data[ix] + 1
end

function p.Histogram:index(x, y)
	local ix = x * (self.wx + 1) + y
	return ix
end

function p.Histogram:get(x, y)
	return self.data[self:index(x, y)]
end

function powertools.Histogram:smooth()
	local old = {}
	for i = 0, #self.data do
		old[i] = self.data[i]
	end

	-- kw is radius of kernel (so total 2kw + 1)
	-- wx, wy is total width, height of affected area
	local kw = 2
	local cnt = math.pow(2*kw + 1, 2)
	quickdump({kw=kw, wx=self.wx, wy=self.wy, cnt=cnt, dat=self.data, old=old})
	for x = kw, (self.wx - kw) do  -- 1 : 2
	for y = kw, (self.wy - kw) do
		local sum = 0
		for kx = -kw, kw do
		for ky = -kw, kw do
			local px = x + kx -- range kw - kw : wx - kw + kw
			local py = y + ky -- that is 0 : wx
			local pix = self:index(px, py)
			quickdump({pix=pix, px=px, py=py, oldc=#old})
			sum = sum + (old[pix])
		end end

		local ix = self:index(x, y)
		self.data[ix] = math.floor(sum / cnt + 0.5)
	end end
	quickdump({old=old, data=self.data})
end

powertools.smoother.is_empty = function (cid)
	local itemname = minetest.get_name_from_content_id(cid)
	itemname = minetest.registered_aliases[itemname] or itemname
	local def = minetest.registered_nodes[itemname]
	if def == nil then return nil end
	return def['drawtype'] ~= 'normal'
end

-- incrementing Y is up
powertools.smoother.on_use = function (itemstack, user, pointed_thing)
	if pointed_thing.type == "node" then
		local pos = pointed_thing.under
		local W = 6
		local p1 = vector.add(pos, {x = -W, y = -W, z = -W})
		local p2 = vector.add(pos, {x = W, y = W, z = W})

		local vm = minetest.get_voxel_manip()
		local area1, area2 = vm:read_from_map(p1, p2)
		local raw = vm:get_data()

		local va = VoxelArea:new{MinEdge=area1, MaxEdge=area2}
		quickdump({p1=p1, p2=p2, area1=area1, area2=area2})

		local idair = minetest.get_content_id('air')
		local idstone = minetest.get_content_id('default:stone')

		-- build the histogram from the cube
		local histogram = powertools.Histogram:new(2*W, 2*W)
		minetest.debug(dump(histogram))
		for iz = -W, W do
			for iy = -W, W do
				for ix = -W, W do
					-- TODO can be optimized
					local ex = ix + pos.x
					local ey = iy + pos.y
					local ez = iz + pos.z

					local blix = va:index(ex, ey, ez)
					local bl = raw[blix]
					-- quickdump({bl=bl, idair=idair, effectiv={x=ex, y=ey, z=ez}, i={x=ix, y=iy, z=iz}, blix=blix, merry='xmas', blname=minetest.get_name_from_content_id(bl or 0)})
					--if bl ~= idair then
					if not powertools.smoother.is_empty(bl) then
						histogram:add(W + ix, W + iz)
					end
				end
			end
		end

		-- smooth the histogram
		histogram:smooth()

		-- TODO take a look at missing values in histogram
		-- appply the histogram back
		for iz = -W, W do
			for ix = -W, W do
				local h = histogram:get(W + ix, W + iz) or 0 -- range -W + W : W + W
				local prev = idstone
				for iy = -W, W do
					local blix = va:index(ix + pos.x, iy + pos.y, iz + pos.z)
					local cur = raw[blix]
					-- quickdump({ix=ix, blix=blix, cur=cur, h=h, iy=iy, iz=iz})
					if (W + iy) < h then
						if cur == idair then
							raw[blix] = prev
						end
					else
						raw[blix] = idair
					end

					prev = raw[blix]
				end
			end
		end


		vm:set_data(raw)
		vm:write_to_map()
	else
		minetest.chat_send_player(user:get_player_name(), "Please punch a node")
	end

end


-- TODO on_use doesn't work with replacing because it's not indirect enough

minetest.register_craftitem("powertools:smoother", {
	description = "Smoother", --[[\n" ..
		"Replaces node pointed at\n" ..
		"Node to be placed is of the type of the itemstack to the right",]]--
	inventory_image = "powertools_replacer_down_column.png",
	on_use = function(a, b, c) 
		return powertools.smoother.on_use(a,b,c)
	end
})

minetest.register_craftitem("powertools:replacer", {
	description = "Replacer", --[[\n" ..
		"Replaces node pointed at\n" ..
		"Node to be placed is of the type of the itemstack to the right",]]--
	inventory_image = "powertools_replacer_down_column.png",
	on_use = function(itemstack, user, pointed_thing)
		if pointed_thing.type == "node" then
			local to_place = getStackToTheRight(user):get_name()
			if to_place and minetest.registered_nodes[to_place] then
				local pos = pointed_thing.under
				minetest.set_node(pos, {name = to_place})
			else
				minetest.chat_send_player(user:get_player_name(),
					"Please put a valid node stack to the right of this tool to set the node to place")
			end
		else
			minetest.chat_send_player(user:get_player_name(), "Please punch a node")
		end
	end
})

minetest.register_craftitem("powertools:replacer_down_column", {
	description = "Down Column Replacer", --[[\n" ..
		"Places tool.stackcount downwards, including punched node\n" ..
		"Node to be placed is of the type of the itemstack to the right",]]--
	inventory_image = "powertools_replacer_down_column.png",
	on_use = function(itemstack, user, pointed_thing)
		if pointed_thing.type == "node" then
			local to_place = getStackToTheRight(user):get_name()
			if to_place and minetest.registered_nodes[to_place] then
				local pos = pointed_thing.under
				for i = 1, itemstack:get_count() do
					minetest.set_node(pos, {name = to_place})
					pos.y = pos.y - 1
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

minetest.register_craftitem("powertools:replacer_up_column", {
	description = "Up Column Replacer", --[[\n" ..
		"Places tool.stackcount upwards, including punched node\n" ..
		"Node to be placed is of the type of the itemstack to the right",]]--
	inventory_image = "powertools_replacer_up_column.png",
	on_use = function(itemstack, user, pointed_thing)
		if pointed_thing.type == "node" then
			local to_place = getStackToTheRight(user):get_name()
			if to_place and minetest.registered_nodes[to_place] then
				local pos = pointed_thing.under
				for i = 1, itemstack:get_count() do
					minetest.set_node(pos, {name = to_place})
					pos.y = pos.y + 1
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
