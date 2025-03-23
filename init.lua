molten_sailor_mcl = {
	durability_seconds = tonumber(minetest.settings:get("molten_sailor_mcl.durability_seconds")) or 1200,
   main = "mcl_core:obsidian",
   coolant = "group:ice",
   boat = "group:boat",
}

local MP = minetest.get_modpath("molten_sailor_mcl")
dofile(MP.."/helpers.lua")
dofile(MP.."/boat.lua")
dofile(MP.."/suit.lua")
dofile(MP.."/crafts.lua")
dofile(MP.."/hud.lua")
dofile(MP.."/burning.lua")

print("[OK] molten_sailor_mcl")
core.log("action","[molten_sailor_mcl] using durability " .. molten_sailor_mcl.durability_seconds)
