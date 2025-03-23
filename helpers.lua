-- File: helpers.lua
-- Author: bgstack15
-- SPDX-License-Identifier: GPL-3.0-only
-- Reference:
--    https://forum.luanti.org/viewtopic.php?f=47&t=4668&p=238850#p238850 add to groups
function molten_sailor_mcl.override_groups(node, additional_groups)
	local def = core.registered_nodes[node]
	local groups = table.copy(def.groups)
	for k,v in pairs(additional_groups) do
		groups[k] = v
	end
	groups["set_on_fire"] = nil
	core.override_item(node, { groups = groups } )
end
