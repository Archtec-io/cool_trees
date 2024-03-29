--
-- Plumtree
--
local modname = "plumtree"
local modpath = minetest.get_modpath(modname)
local mg_name = minetest.get_mapgen_setting("mg_name")
local fruit_grow_time = 1200

-- internationalization boilerplate
local S = minetest.get_translator(minetest.get_current_modname())

-- Plum Fruit

minetest.register_node("plumtree:plum", {
	description = S("Plum"),
	drawtype = "plantlike",
	tiles = {"plumtree_plum.png"},
	inventory_image = "plumtree_plum.png",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	is_ground_content = false,
	selection_box = {
		type = "fixed",
		fixed = {-3 / 16, -7 / 16, -3 / 16, 3 / 16, 4 / 16, 3 / 16}
	},
	groups = {fleshy = 3, dig_immediate = 3, flammable = 2,
		leafdecay = 3, leafdecay_drop = 1},
	on_use = minetest.item_eat(2),
	sounds = default.node_sound_leaves_defaults(),

	after_place_node = function(pos, placer, itemstack)
		minetest.set_node(pos, {name = "plumtree:plum", param2 = 1})
	end,

	on_dig = function(pos, node, digger)
		if digger:is_player() then
			local inv = digger:get_inventory()
			if inv:room_for_item("main", "plumtree:plum") then
				inv:add_item("main", "plumtree:plum")
			end
		end
		minetest.remove_node(pos)
		pos.y = pos.y + 1
		local node_above = minetest.get_node_or_nil(pos)
		if node_above and node_above.param2 == 0 and node_above.name == "plumtree:leaves" then
			--20% of variation on time
			local twenty_percent = fruit_grow_time * 0.2
			local grow_time = math.random(fruit_grow_time - twenty_percent, fruit_grow_time + twenty_percent)
			minetest.get_node_timer(pos):start(grow_time)
		end
	end,
})

-- Plumtree

local function grow_new_plumtree_tree(pos)
	if not default.can_grow(pos) then
		-- try a bit later again
		minetest.get_node_timer(pos):start(math.random(240, 600))
		return
	end
	minetest.remove_node(pos)
	minetest.place_schematic({x = pos.x-4, y = pos.y-1, z = pos.z-4}, modpath.."/schematics/plumtree.mts", "0", nil, true)
end

--
-- Decoration
--

if mg_name ~= "singlenode" then
	local place_on, biomes, offset, scale

	if minetest.get_modpath("rainf") then
		place_on = "rainf:meadow"
		biomes = "rainf"
		offset = 0.0008
		scale = 0.00004
	else
		place_on = "default:dirt_with_grass"
		biomes = "grassland"
		offset = 0.00005
		scale = 0.00004
	end

	local decoration_definition = {
		name = "plumtree:plum_tree",
		deco_type = "schematic",
		place_on = {place_on},
		sidelen = 16,
		noise_params = {
			offset = offset,
			scale = scale,
			spread = {x = 250, y = 250, z = 250},
			seed = 23278,
			octaves = 3,
			persist = 0.66
		},
		y_min = 1,
		schematic = modpath.."/schematics/plumtree.mts",
		flags = "place_center_x, place_center_z, force_placement",
		rotation = "random"
	}

	if mg_name == "v6" then
		decoration_definition.y_max = 80

		minetest.register_decoration(decoration_definition)
	else
		decoration_definition.biomes = {biomes}
		decoration_definition.y_max = 5000

		minetest.register_decoration(decoration_definition)
	end
end

--
-- Nodes
--

minetest.register_node("plumtree:sapling", {
	description = S("Plum Tree Sapling"),
	drawtype = "plantlike",
	tiles = {"plumtree_sapling.png"},
	inventory_image = "plumtree_sapling.png",
	wield_image = "plumtree_sapling.png",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	on_timer = grow_new_plumtree_tree,
	selection_box = {
		type = "fixed",
		fixed = {-4 / 16, -0.5, -4 / 16, 4 / 16, 7 / 16, 4 / 16}
	},
	groups = {snappy = 2, dig_immediate = 3, flammable = 2,
		attached_node = 1, sapling = 1},
	sounds = default.node_sound_leaves_defaults(),

	on_construct = function(pos)
		minetest.get_node_timer(pos):start(math.random(2400,4800))
	end,

	on_place = function(itemstack, placer, pointed_thing)
		itemstack = default.sapling_on_place(itemstack, placer, pointed_thing,
			"plumtree:sapling",
			-- minp, maxp to be checked, relative to sapling pos
			-- minp_relative.y = 1 because sapling pos has been checked
			{x = -2, y = 1, z = -2},
			{x = 2, y = 6, z = 2},
			-- maximum interval of interior volume check
			4)

		return itemstack
	end,
})

minetest.register_node("plumtree:trunk", {
	description = S("Plum Tree Trunk"),
	tiles = {
		"plumtree_trunk_top.png",
		"plumtree_trunk_top.png",
		"plumtree_trunk.png"
	},
	groups = {tree = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 2},
	sounds = default.node_sound_wood_defaults(),
	paramtype2 = "facedir",
	is_ground_content = false,
	on_place = minetest.rotate_node,
})

-- plumtree wood
minetest.register_node("plumtree:wood", {
	description = S("Plum Tree Wood Planks"),
	tiles = {"plumtree_wood.png"},
	paramtype2 = "facedir",
	place_param2 = 0,
	is_ground_content = false,
	groups = {wood = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 3},
	sounds = default.node_sound_wood_defaults(),
})


-- plumtree tree leaves
minetest.register_node("plumtree:leaves", {
	description = S("Plum Tree Leaves"),
	drawtype = "allfaces_optional",
	tiles = {"plumtree_leaves.png"},
	paramtype = "light",
	walkable = true,
	waving = 1,
	groups = {snappy = 3, leafdecay = 3, leaves = 1, flammable = 2},
	drop = {
		max_items = 1,
		items = {
			{items = {"plumtree:sapling"}, rarity = 20},
			{items = {"plumtree:leaves"}}
		}
	},
	sounds = default.node_sound_leaves_defaults(),
	after_place_node = default.after_place_leaves,
})

--
-- Craftitems
--

--
-- Recipes
--

minetest.register_craft({
	output = "plumtree:wood 4",
	recipe = {{"plumtree:trunk"}}
})

minetest.register_craft({
	type = "fuel",
	recipe = "plumtree:trunk",
	burntime = 30,
})

minetest.register_craft({
	type = "fuel",
	recipe = "plumtree:wood",
	burntime = 7,
})

default.register_leafdecay({
	trunks = {"plumtree:trunk"},
	leaves = {"plumtree:leaves", "plumtree:plum"},
	radius = 3,
})

-- Fence
if minetest.settings:get_bool("cool_fences", true) then
	local fence = {
		description = S("Plum Tree Wood Fence"),
		texture =  "plumtree_wood.png",
		material = "plumtree:wood",
		groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
		sounds = default.node_sound_wood_defaults(),
	}
	default.register_fence("plumtree:fence", table.copy(fence))
	fence.description = S("Plum Tree Fence Rail")
	default.register_fence_rail("plumtree:fence_rail", table.copy(fence))

	if minetest.get_modpath("doors") ~= nil then
		fence.description = S("Plum Tree Fence Gate")
		doors.register_fencegate("plumtree:gate", table.copy(fence))
	end
end

-- Stairs
if minetest.get_modpath("moreblocks") then -- stairsplus/moreblocks
	stairsplus:register_all("plumtree", "wood", "plumtree:wood", {
		description = S("Plum Tree Wood"),
		tiles = {"plumtree_wood.png"},
		sunlight_propagates = true,
		groups = {choppy = 2, oddly_breakable_by_hand = 1, flammable = 3},
		sounds = default.node_sound_wood_defaults()
	})
	minetest.register_alias_force("stairs:stair_plumtree_wood", "plumtree:stair_wood")
	minetest.register_alias_force("stairs:stair_outer_plumtree_wood", "plumtree:stair_wood_outer")
	minetest.register_alias_force("stairs:stair_inner_plumtree_wood", "plumtree:stair_wood_inner")
	minetest.register_alias_force("stairs:slab_plumtree_wood", "plumtree:slab_wood")

	-- for compatibility
	minetest.register_alias_force("stairs:stair_plumtree_trunk", "plumtree:stair_wood")
	minetest.register_alias_force("stairs:stair_outer_plumtree_trunk", "plumtree:stair_wood_outer")
	minetest.register_alias_force("stairs:stair_inner_plumtree_trunk", "plumtree:stair_wood_inner")
	minetest.register_alias_force("stairs:slab_plumtree_trunk", "plumtree:slab_wood")
elseif minetest.get_modpath("stairs") then
	stairs.register_stair_and_slab(
		"plumtree_wood",
		"plumtree:wood",
		{choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
		{"plumtree_wood.png"},
		S("Plum Tree Wood Stair"),
		S("Plum Tree Wood Slab"),
		default.node_sound_wood_defaults()
	)
end

-- Support for bonemeal
if minetest.get_modpath("bonemeal") ~= nil then
	bonemeal:add_sapling({
		{"plumtree:sapling", grow_new_plumtree_tree, "soil"},
	})
end

-- Support for flowerpot
if minetest.global_exists("flowerpot") then
	flowerpot.register_node("plumtree:sapling")
end
