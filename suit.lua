--effects:
--increase speed so can move nice in lava, but can't jump and useless as armor so not good as a speed suit.

local S = core.get_translator(core.get_current_modname())

local durability_seconds = molten_sailor_mcl.durability_seconds
-- set to a modest number so incidental damage does not destroy the outfit
if durability_seconds == 0 then
   molten_sailor_mcl.durability_on = false
   durability_seconds = 60
end

mcl_armor.register_set({
	name = "obsidian",
	descriptions = {
		head  = S("Anti-lava Helmet"),
		torso = S("Anti-lava Chestplate"),
		legs  = S("Anti-lava Pants"),
		feet  = S("Anti-lava Boots"),
	},
	durability = durability_seconds,
	enchantability = 0,
	points = {
		head  = 0,
		torso = 0,
		legs  = 0,
		feet  = 0,
	},
	craft_material = nil, -- use custom recipes below
	repair_material = "group:ice",
	groups = { fire_immune=1 },
	on_equip_callbacks = {
		head  = function (obj, itemstack) molten_sailor_mcl.don(obj, itemstack) end,
		torso = function (obj, itemstack) molten_sailor_mcl.don(obj, itemstack) end,
		legs  = function (obj, itemstack) molten_sailor_mcl.don(obj, itemstack) end,
		feet  = function (obj, itemstack) molten_sailor_mcl.don(obj, itemstack) end
	},
	on_unequip_callbacks = {
		head  = function (obj, itemstack) molten_sailor_mcl.doff(obj, itemstack) end,
		torso = function (obj, itemstack) molten_sailor_mcl.doff(obj, itemstack) end,
		legs  = function (obj, itemstack) molten_sailor_mcl.doff(obj, itemstack) end,
		feet  = function (obj, itemstack) molten_sailor_mcl.doff(obj, itemstack) end
	},
	toughness = 2,
})

-- mostly not needed because it the global step can capture it too, but doing it here makes it immediate which users will want.
function molten_sailor_mcl.don(obj, itemstack)
	if obj:is_player() then
		local player = obj
		if molten_sailor_mcl.has_full_lava_suit(player) then
			core.log("action",player:get_player_name() .. " is now wearing full lava suit.")
			playerphysics.add_physics_factor(player, "jump", "lava_suit", 0)
			playerphysics.add_physics_factor(player, "gravity", "lava_suit", 0.25)
			playerphysics.add_physics_factor(player, "speed", "lava_suit", 2)
		end
	end
	return true
end

-- mostly not needed because it will not be called if a player directly switches to, e.g., diamond boots
function molten_sailor_mcl.doff(obj, itemstack)
	if obj:is_player() then
		local player = obj
		if not molten_sailor_mcl.has_full_lava_suit(player) then
			core.log("action",player:get_player_name() .. " now has an incomplete lava suit.")
			playerphysics.remove_physics_factor(player, "jump", "lava_suit")
			playerphysics.remove_physics_factor(player, "gravity", "lava_suit")
			playerphysics.remove_physics_factor(player, "speed", "lava_suit")
		end
	end
	return true
end

local timer = 0
core.register_globalstep(function(dtime)
	timer = timer + dtime;
	if timer >= 1 then
		for _,player in ipairs(minetest.get_connected_players()) do
			if molten_sailor_mcl.has_full_lava_suit(player) then
				playerphysics.add_physics_factor(player, "jump", "lava_suit", 0)
				playerphysics.add_physics_factor(player, "gravity", "lava_suit", 0.25)
				-- WORKHERE: check if standing on lava? How about that on_fire attribute elsewhere?
				playerphysics.add_physics_factor(player, "speed", "lava_suit", 2)
			else
				playerphysics.remove_physics_factor(player, "jump", "lava_suit")
				playerphysics.remove_physics_factor(player, "gravity", "lava_suit")
				playerphysics.remove_physics_factor(player, "speed", "lava_suit")
			end -- if has lava suit
		end -- for player in connected players
	end -- if timer
	timer = 0
end)
