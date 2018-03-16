
local function evaluate_bush(pos)
	local result = 0
	-- local near_count = 0
	-- near_count = count_nearby_bushes(pos)
	local this_node = minetest.get_node(pos)
	if this_node ~= nil then
		if string.sub(this_node.name, 0, 7) == "bushes:" then
			-- minetest.log("kill " .. this_node.name .. " at " .. minetest.pos_to_string(pos))
			minetest.remove_node(pos)
			minetest.set_node(pos, {name="default:dry_shrub"})
			result = 1
		-- else
			-- minetest.log("(verbose message in bushes_soil.evaluate_bush) not 'bushes:' node " .. this_node.name .. " at " .. minetest.pos_to_string(pos))
			-- minetest.log("keep " .. this_node.name .. " at " .. minetest.pos_to_string(pos))
		end
	-- else
		-- minetest.log("ERROR in bushes_soil.evaluate_bush: no node at " .. minetest.pos_to_string(pos))
	end
	return result
end

local function count_nearby_bushes(pos)
	-- '+' pattern:
	local near_count = 0
	local near_pos = pos
	local this_node = nil
	near_pos.z = near_pos.z - 1
	near_pos.x = near_pos.x - 1
	this_node = minetest.get_node(near_pos)
	if this_node ~= nil then
		if string.sub(this_node.name, 0, 7) == "bushes:" then
			near_count = near_count + 1
		end
	end
	near_pos.x = near_pos.x + 1
	-- evaluate_bush(near_pos)
	near_pos.x = near_pos.x + 1
	-- evaluate_bush(near_pos)
	near_pos.x = near_pos.x - 2

	near_pos.z = near_pos.z + 1
	near_pos.x = near_pos.x - 1
	this_node = minetest.get_node(near_pos)
	if this_node ~= nil then
		if string.sub(this_node.name, 0, 7) == "bushes:" then
			near_count = near_count + 1
		end
	end
	near_pos.x = near_pos.x + 1
	-- evaluate_bush(near_pos)
	near_pos.x = near_pos.x + 1
	this_node = minetest.get_node(near_pos)
	if this_node ~= nil then
		if string.sub(this_node.name, 0, 7) == "bushes:" then
			near_count = near_count + 1
		end
	end
	near_pos.x = near_pos.x - 2

	near_pos.z = near_pos.z + 1
	near_pos.x = near_pos.x - 1
	-- evaluate_bush(near_pos)
	near_pos.x = near_pos.x + 1
	this_node = minetest.get_node(near_pos)
	if this_node ~= nil then
		if string.sub(this_node.name, 0, 7) == "bushes:" then
			near_count = near_count + 1
		end
	end
	near_pos.x = near_pos.x + 1
	-- evaluate_bush(near_pos)
	near_pos.x = near_pos.x - 2
	return near_count
end

local function evaluate_bushes_square(pos)
	-- box pattern:
	local near_pos = minetest.string_to_pos(minetest.pos_to_string(pos))
	local radius = 2
	local width = radius * 2 + 1
	local height = width
	minetest.log("")
	minetest.log("CHECKING " .. minetest.pos_to_string(near_pos))
	near_pos.z = pos.z - radius
	near_pos.x = pos.x - radius
	-- (2nd 'for' param is inclusive max in lua)
	local line_x = near_pos.x
	minetest.log("checking from " .. minetest.pos_to_string(near_pos))
	for vert=1,height,1
	do
		near_pos.x = line_x
		for horz=1,width,1
		do
			if not (near_pos.x == pos.x and near_pos.z == pos.z) then
				evaluate_bush(near_pos)
				minetest.log("checking bush at " .. minetest.pos_to_string(near_pos))
			else
				minetest.log("skipping same at " .. minetest.pos_to_string(near_pos))
			end
			near_pos.x = near_pos.x + 1
		end
		near_pos.z = near_pos.z + 1
	end
end



local function evaluate_bushes_fill_recursively(pos, prev_pos, original_pos, killed_count)
	-- box pattern:
	local near_pos = minetest.string_to_pos(minetest.pos_to_string(pos))
	local radius = 2
	local width = radius * 2 + 1
	local height = width
	minetest.log("")
	minetest.log("CHECKING " .. minetest.pos_to_string(near_pos))
	near_pos.z = pos.z - radius
	near_pos.x = pos.x - radius
	-- (2nd 'for' param is inclusive max in lua)
	local line_x = near_pos.x
	minetest.log("checking from " .. minetest.pos_to_string(near_pos))
	killed_bush_positions = {}
	for vert=1,height,1
	do
		near_pos.x = line_x
		for horz=1,width,1
		do
			if not (near_pos.x == pos.x and near_pos.z == pos.z) then
				if not (near_pos.x == original_pos.x and near_pos.z == original_pos.z) then
					local this_result = evaluate_bush(near_pos)
					killed_count = killed_count + this_result
					if killed_count >= 8 then
						return killed_count
					else
						if this_result > 0 then
							table.insert(killed_bush_positions, minetest.string_to_pos(minetest.pos_to_string(near_pos)))
							-- killed_count = killed_count + evaluate_bushes_fill_recursively(near_pos, minetest.string_to_pos(minetest.pos_to_string(near_pos)), original_pos, killed_count)
						-- minetest.log("checking bush at " .. minetest.pos_to_string(near_pos))
					-- else
						-- minetest.log("skipping same at " .. minetest.pos_to_string(near_pos))
						end
					end
				end
			end
			near_pos.x = near_pos.x + 1
		end
		near_pos.z = near_pos.z + 1
	end
	-- do the recursion separately to create a nice fill pattern:
	for k,v in ipairs(killed_bush_positions) do
		if killed_count >= 8 then
			return killed_count
		else
			killed_count = killed_count + evaluate_bushes_fill_recursively(v, minetest.string_to_pos(minetest.pos_to_string(v)), original_pos, killed_count)
		end
	end
	return killed_count
end


local function evaluate_bushes_fill(pos)
	local prev_pos = minetest.string_to_pos(minetest.pos_to_string(pos))
	local original_pos = minetest.string_to_pos(minetest.pos_to_string(pos))
	evaluate_bushes_fill_recursively(pos, prev_pos, original_pos, 0)
end

-- minetest.register_on_punchnode(function(pos, node, puncher, pointed_thing)
--	if string.sub(node.name, 0, 7) == "bushes:" then
--		evaluate_bushes(pos)
--	end
-- end)

minetest.register_on_dignode(function(pos, oldnode, digger)
-- **Not recommended**; Use `on_destruct` or `after_dig_node` in node definition whenever possible. - <https://github.com/minetest/minetest/blob/master/doc/lua_api.txt>
	if string.sub(oldnode.name, 0, 7) == "bushes:" then
		evaluate_bushes_fill(pos)
	end
end)
