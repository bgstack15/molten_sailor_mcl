function molten_sailor_mcl.has_full_lava_suit(player)
	local inv = player:get_inventory()
	local armor_inv = player:get_inventory():get_list("armor")
	local has_helmet = inv:contains_item("armor","molten_sailor_mcl:helmet_obsidian")
	local has_chestplate = inv:contains_item("armor","molten_sailor_mcl:chestplate_obsidian")
	local has_pants = inv:contains_item("armor","molten_sailor_mcl:leggings_obsidian")
	local has_boots = inv:contains_item("armor","molten_sailor_mcl:boots_obsidian")
	return has_helmet and has_chestplate and has_pants and has_boots
end

-- copied from mcl_armor/damage.lua directly
local function use_durability(obj, inv, index, stack, uses)
	local def = stack:get_definition()
	mcl_util.use_item_durability(stack, uses)
	if stack:is_empty() and def and def._on_break then
		stack = def._on_break(obj) or stack
	end
	if inv then
		inv:set_stack("armor", index, stack)
	end
end

local durability_seconds = molten_sailor_mcl.durability_seconds
local timer = 0
minetest.register_globalstep(function(dtime)

	--[[
	-- this keeps the player from taking burning damage, but the suit still takes damage like the player would be so it is insufficient.
	for _,player in ipairs(minetest.get_connected_players()) do
		if molten_sailor_mcl.has_full_lava_suit(player) then
			mcl_burning.extinguish(player)
		end
	end
	--]]
	timer = timer + dtime;
	if timer >= 1 then
		local t0 = minetest.get_us_time()

		for _,player in ipairs(minetest.get_connected_players()) do
			local inv = player:get_inventory()
			local armor_inv = player:get_inventory():get_list("armor")
			local has_helmet = inv:contains_item("armor","molten_sailor_mcl:helmet_obsidian")
			local has_chestplate = inv:contains_item("armor","molten_sailor_mcl:chestplate_obsidian")
			local has_pants = inv:contains_item("armor","molten_sailor_mcl:leggings_obsidian")
			local has_boots = inv:contains_item("armor","molten_sailor_mcl:boots_obsidian")

			-- does the player wear a suit?
			molten_sailor_mcl.set_player_wearing(player, molten_sailor_mcl.has_full_lava_suit(player), has_helmet, armor_inv)

			-- is player on fire?
			local pos = player:get_pos()
			local on_fire = minetest.find_node_near(pos, 1, {"group:lava","group:fire"})

			if on_fire then
				minetest.sound_play("fire_extinguish_flame", {pos = pos,max_hear_distance = 2,	gain = 0.1,})
				if molten_sailor_mcl.durability_on and durability_seconds > 0 and (has_helmet or has_chestplate or has_pants or has_boots) then
					for i, stack in pairs(armor_inv) do
						if not stack:is_empty() then
							local name = stack:get_name()
							-- use one durability per loop (which is one second)
							use_durability(player, inv, i, stack, 1)
							core.log("action","item " .. name .. " uses is now at " .. stack:get_wear()/65535*durability_seconds .. "/" .. durability_seconds)
						end
					end
					if player:get_breath() < 3 then
						player:set_breath(3)
					end
				end -- if on_fire
			end -- for each player
		end -- if timer>1
		timer = 0

		local t1 = minetest.get_us_time()
		local diff = t1 - t0
		if diff > 10000 then
			minetest.log("warning", "[molten_sailor_mcl] update took " .. diff .. " us")
		end
	end
end)

-- lava suit prevents the 4 damage from a lava node
mcl_damage.register_modifier(function(obj, damage, reason)
	if obj:is_player() and (reason.type == "lava" or reason.type == "in_fire" or reason.type == "fire") and molten_sailor_mcl.has_full_lava_suit(obj) then
		return 0
	end
	return -- return nil to continue with previous damage value
end, -50)

-- loop over all registered nodes to modify group:set_on_fire to set_on_fire_classic
minetest.register_on_mods_loaded(function()
	for name, def in pairs(minetest.registered_nodes) do
		local set_on_fire_classic = def.groups["set_on_fire"]
		if set_on_fire_classic ~= nil then
			local groups = table.copy(def.groups)
			groups["set_on_fire_classic"] = set_on_fire_classic
			molten_sailor_mcl.override_groups(name, groups)
			core.log("verbose","[molten_sailor_mcl] adjusting for lava suit: " .. name)
		end
	end
end)

-- copied directly from mineclonia/mods/ENTITIES/mcl_burning/init.lua and then modified for lava suit protection
minetest.register_globalstep(function(dtime)
	for player in mcl_util.connected_players() do
		if molten_sailor_mcl.has_full_lava_suit(player) then
			return
		end
		local storage = mcl_burning.storage[player]
		if not mcl_burning.tick(player, dtime, storage) and not mcl_burning.is_affected_by_rain(player) then
			local nodes = mcl_burning.get_touching_nodes(player, {"group:set_on_fire_classic"}, storage)
			local burn_time = 0

			for _, pos in pairs(nodes) do
				local node = minetest.get_node(pos)
				local value = minetest.get_item_group(node.name, "set_on_fire_classic")
				if value > burn_time then
					burn_time = value
				end
			end

			if burn_time > 0 then
				mcl_burning.set_on_fire(player, burn_time)
			end
		end
	end
end)
