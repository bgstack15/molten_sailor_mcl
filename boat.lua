--
-- Helper functions
--

local function is_water(pos)
	local nn = minetest.get_node(pos).name
	return minetest.get_item_group(nn, "lava") ~= 0
end


local function get_sign(i)
	if i == 0 then
		return 0
	else
		return i / math.abs(i)
	end
end


local function get_velocity(v, yaw, y)
	local x = -math.sin(yaw) * v
	local z =  math.cos(yaw) * v
	return {x = x, y = y, z = z}
end


local function get_v(v)
	return math.sqrt(v.x ^ 2 + v.z ^ 2)
end

--
--lava Boat entity
--

local lava_boat = {
	initial_properties = {
		physical = true,
		-- Warning: Do not change the position of the collisionbox top surface,
		-- lowering it causes the boat to fall through the world if underwater
		collisionbox = {-0.5, -0.35, -0.5, 0.5, 0.3, 0.5},
		visual = "mesh",
		mesh = "molten_sailor_lava_boat.obj",
		textures = {"default_obsidian.png"},
	},

	driver = nil,
	v = 0,
	last_v = 0,
	removed = false,
	auto = false
}


function lava_boat.on_rightclick(self, clicker)
	if not clicker or not clicker:is_player() then
		return
	end
	local name = clicker:get_player_name()
	if self.driver and name == self.driver then
		self.driver = nil
		self.auto = false
		clicker:set_detach()
		mcl_player.player_attached[name] = false
		mcl_player.player_set_animation(clicker, "stand" , 30)
		local pos = clicker:get_pos()
		pos = {x = pos.x, y = pos.y + 0.2, z = pos.z}
		minetest.after(0.1, function()
			clicker:set_pos(pos)
		end)
	elseif not self.driver then
		local attach = clicker:get_attach()
		if attach and attach:get_luaentity() then
			local luaentity = attach:get_luaentity()
			if luaentity.driver then
				luaentity.driver = nil
			end
			clicker:set_detach()
		end
		self.driver = name
		clicker:set_attach(self.object, "",
			{x = 0.5, y = 1, z = -3}, {x = 0, y = 0, z = 0})
		mcl_player.player_attached[name] = true
		minetest.after(0.2, function()
			mcl_player.player_set_animation(clicker, "sit" , 30)
		end)
		clicker:set_look_horizontal(self.object:get_yaw())
	end
end


-- If driver leaves server while driving boat
function lava_boat.on_detach_child(self, child)
	self.driver = nil
	self.auto = false
end


function lava_boat.on_activate(self, staticdata, dtime_s)
	self.object:set_armor_groups({immortal = 1})
	if staticdata then
		self.v = tonumber(staticdata)
	end
	self.last_v = self.v
end


function lava_boat.get_staticdata(self)
	return tostring(self.v)
end


function lava_boat.on_punch(self, puncher)
	if not puncher or not puncher:is_player() or self.removed then
		return
	end

	local name = puncher:get_player_name()
	if self.driver and name == self.driver then
		self.driver = nil
		puncher:set_detach()
		mcl_player.player_attached[name] = false
	end
	if not self.driver then
		self.removed = true
		local inv = puncher:get_inventory()
		if (not minetest.is_creative_enabled(name))
				or not inv:contains_item("main", "molten_sailor_mcl:lava_boat") then
			local leftover = inv:add_item("main", "molten_sailor_mcl:lava_boat")
			-- if no room in inventory add a replacement boat to the world
			if not leftover:is_empty() then
				minetest.add_item(self.object:get_pos(), leftover)
			end
		end
		-- delay remove to ensure player is detached
		minetest.after(0.1, function()
			self.object:remove()
		end)
	end
end


function lava_boat.on_step(self, dtime)
	self.v = get_v(self.object:get_velocity()) * get_sign(self.v)
	if self.driver then
		local driver_objref = minetest.get_player_by_name(self.driver)
		if driver_objref then
			local ctrl = driver_objref:get_player_control()
			if ctrl.up and ctrl.down then
				if not self.auto then
					self.auto = true
					minetest.chat_send_player(self.driver, "[Lava boat] Cruise on")
				end
			elseif ctrl.down then
				self.v = self.v - dtime * 1.8
				if self.auto then
					self.auto = false
					minetest.chat_send_player(self.driver, "[Lava boat] Cruise off")
				end
			elseif ctrl.up or self.auto then
				self.v = self.v + dtime * 1.8
			end
			if ctrl.left then
				if self.v < -0.001 then
					self.object:set_yaw(self.object:get_yaw() - dtime * 0.9)
				else
					self.object:set_yaw(self.object:get_yaw() + dtime * 0.9)
				end
			elseif ctrl.right then
				if self.v < -0.001 then
					self.object:set_yaw(self.object:get_yaw() + dtime * 0.9)
				else
					self.object:set_yaw(self.object:get_yaw() - dtime * 0.9)
				end
			end
		end
	end
	local velo = self.object:get_velocity()
	if self.v == 0 and velo.x == 0 and velo.y == 0 and velo.z == 0 then
		self.object:set_pos(self.object:get_pos())
		return
	end
	local s = get_sign(self.v)
	self.v = self.v - dtime * 0.6 * s
	if s ~= get_sign(self.v) then
		self.object:set_velocity({x = 0, y = 0, z = 0})
		self.v = 0
		return
	end
	if math.abs(self.v) > 5 then
		self.v = 5 * get_sign(self.v)
	end

	local p = self.object:get_pos()
	p.y = p.y - 0.5
	local new_velo
	local new_acce = {x = 0, y = 0, z = 0}
	if not is_water(p) then
		local nodedef = minetest.registered_nodes[minetest.get_node(p).name]
		if (not nodedef) or nodedef.walkable then
			self.v = 0
			new_acce = {x = 0, y = 1, z = 0}
		else
			new_acce = {x = 0, y = -9.8, z = 0}
		end
		new_velo = get_velocity(self.v, self.object:get_yaw(),
			self.object:get_velocity().y)
		self.object:set_pos(self.object:get_pos())
	else
		p.y = p.y + 1
		if is_water(p) then
			local y = self.object:get_velocity().y
			if y >= 5 then
				y = 5
			elseif y < 0 then
				new_acce = {x = 0, y = 20, z = 0}
			else
				new_acce = {x = 0, y = 5, z = 0}
			end
			new_velo = get_velocity(self.v, self.object:get_yaw(), y)
			self.object:set_pos(self.object:get_pos())
		else
			new_acce = {x = 0, y = 0, z = 0}
			if math.abs(self.object:get_velocity().y) < 1 then
				local pos = self.object:get_pos()
				pos.y = math.floor(pos.y) + 0.5
				self.object:set_pos(pos)
				new_velo = get_velocity(self.v, self.object:get_yaw(), 0)
			else
				new_velo = get_velocity(self.v, self.object:get_yaw(),
					self.object:get_velocity().y)
				self.object:set_pos(self.object:get_pos())
			end
		end
	end
	self.object:set_velocity(new_velo)
	self.object:set_acceleration(new_acce)
end



minetest.register_entity("molten_sailor_mcl:lava_boat", lava_boat)


minetest.register_craftitem("molten_sailor_mcl:lava_boat", {
	description = "Lava Boat",
	inventory_image = "molten_sailor_boats_inventory.png",
	wield_image = "molten_sailor_boats_wield.png",
	wield_scale = {x = 2, y = 2, z = 1},
	liquids_pointable = true,
	--groups = {flammable = 2},

	on_place = function(itemstack, placer, pointed_thing)
		local under = pointed_thing.under
		local node = minetest.get_node(under)
		local udef = minetest.registered_nodes[node.name]
		if udef and udef.on_rightclick and
				not (placer and placer:is_player() and
				placer:get_player_control().sneak) then
			return udef.on_rightclick(under, node, placer, itemstack,
				pointed_thing) or itemstack
		end

		if pointed_thing.type ~= "node" then
			return itemstack
		end
		if not is_water(pointed_thing.under) then
			return itemstack
		end
		pointed_thing.under.y = pointed_thing.under.y + 0.5
		lava_boat = minetest.add_entity(pointed_thing.under, "molten_sailor_mcl:lava_boat")
		if lava_boat then
			if placer then
				lava_boat:set_yaw(placer:get_look_horizontal())
			end
			local player_name = placer and placer:get_player_name() or ""
			if not minetest.is_creative_enabled(placer:get_player_name()) then
				itemstack:take_item()
			end
		end
		return itemstack
	end,
})

local m = molten_sailor_mcl.main
local c = molten_sailor_mcl.coolant
local b = molten_sailor_mcl.boat
minetest.register_craft({
	output = "molten_sailor_mcl:lava_boat",
	recipe = {
		{"", b, ""},
		{m , c , m },
		{m , m , m },
	},
})
