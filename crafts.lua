local m = molten_sailor_mcl.main
local c = molten_sailor_mcl.coolant
local b = molten_sailor_mcl.boat
core.register_craft({
	output = "molten_sailor_mcl:helmet_obsidian",
	recipe = {
		{m , "mcl_armor:helmet_diamond",  m},
		{m ,         c                 ,  m},
		{"",        ""                 , ""},
	}
})
core.register_craft({
	output = "molten_sailor_mcl:chestplate_obsidian",
	recipe = {
		{m , "mcl_armor:chestplate_diamond",  m},
		{m ,         c                     ,  m},
		{m ,         m                     ,  m},
	}
})
core.register_craft({
	output = "molten_sailor_mcl:leggings_obsidian",
	recipe = {
		{m , "mcl_armor:leggings_diamond",  m},
		{m ,         c                   ,  m},
		{"",        ""                   , ""},
	}
})
core.register_craft({
	output = "molten_sailor_mcl:boots_obsidian",
	recipe = {
		{m , "mcl_armor:boots_diamond",  m},
		{m ,         c                ,  m},
		{"",        ""                , ""},
	}
})
