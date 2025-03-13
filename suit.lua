--effects:
--increase speed so can move nice in lava, but can't jump and useless as armor so not good as a speed suit.

local S = core.get_translator(core.get_current_modname())

mcl_armor.register_set({
	name = "obsidian",
	descriptions = {
		head  = S("Anti-lava Helmet"),
		torso = S("Anti-lava Chestplate"),
		legs  = S("Anti-lava Pants"),
		feet  = S("Anti-lava Boots"),
	},
	durability = molten_sailor_mcl.durability_seconds,
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
	-- WORKHERE: if you switch to diamond boots directly, then this doff does not get called!
	on_unequip_callbacks = {
		head  = function (obj, itemstack) molten_sailor_mcl.doff(obj, itemstack) end,
		torso = function (obj, itemstack) molten_sailor_mcl.doff(obj, itemstack) end,
		legs  = function (obj, itemstack) molten_sailor_mcl.doff(obj, itemstack) end,
		feet  = function (obj, itemstack) molten_sailor_mcl.doff(obj, itemstack) end
	},
   toughness = 2,
})

function molten_sailor_mcl.don(obj, itemstack)
	if obj:is_player() then
		local player = obj
		if molten_sailor_mcl.has_full_lava_suit(player) then
			core.log("action",player:get_player_name() .. " is now wearing full lava suit.")
			-- This is for physics but the following line seems to have no effect. Help wanted!
			--player:set_physics_override({speed=0.15, gravity=1.0})
         -- WORKHERE: get jump turned back on when this is over.
			player:set_physics_override({jump=0})
		end
	end
	return true
end

function molten_sailor_mcl.doff(obj, itemstack)
	if obj:is_player() then
		local player = obj
		if not molten_sailor_mcl.has_full_lava_suit(player) then
			core.log("action",player:get_player_name() .. " now has an incomplete lava suit.")
			player:set_physics_override({jump=1})
		end
	end
	return true
end
