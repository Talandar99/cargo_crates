local weight = require("weight")
--
weight.calc()
--log(serpent.block(weight.lookup))

local function has_flag(flags, flag)
	if not flags then
		return false
	end
	for _, f in pairs(flags) do
		if f == flag then
			return true
		end
	end
	return false
end

local spoiled_crate_by_key = {}
local spoiled_crates = {}
local spoiled_recipes = {}

-- icon_size=64 if icon size does not exist to make sure atlas won't explode
for _, type_tbl in pairs(data.raw) do
	for _, proto in pairs(type_tbl) do
		if proto and proto.icon and not proto.icon_size and not proto.icons then
			proto.icon_size = 64
		end
	end
end

local empty_crate_item_name = "wooden-chest"
local crate_icon_path = "__base__/graphics/icons/wooden-chest.png"
if mods["TFMG"] then
	empty_crate_item_name = "steel-chest"
	crate_icon_path = "__base__/graphics/icons/steel-chest.png"
end

local function generate_crates_from(prototypes)
	local crates = {}
	local recipes = {}
	for item_name, item in pairs(prototypes) do
		local pack_equipment
		if settings.startup["cargo-crates-pack-equipment"].value then
			pack_equipment = true
		else
			pack_equipment = not item.place_as_equipment_result
		end

		local pack_spoilables
		if settings.startup["cargo-crates-pack-spoilables"].value then
			pack_spoilables = true
		else
			pack_spoilables = not item.spoil_result and not item.spoil_ticks
		end
		if pack_equipment then
			if pack_spoilables then
				if true then
					if
						item.icon
						and item_name ~= empty_crate_item_name
						and not string.find(item_name, "^cargo%-crate%")
						and not item.hidden
						and not item.hidden_in_factoriopedia
						and item.group ~= "other"
						and item.subgroup ~= "spawnables"
						and item.subgroup ~= "parameters"
						and item.order ~= nil
						and item.name ~= "pirateship-cannonball"
						and not has_flag(item.flags, "not-stackable")
						and not item.place_result
						and not item.spoil_to_trigger_result
						and item.stack_size < 10000
					then
						local crate_weight = weight.lookup[item_name]
						local crate_name = "cargo-crate-" .. item_name

						local crate = {
							type = "item",
							name = crate_name,
							allow_quality = false,
							localised_name = {
								"item-name.cargo-crate",
								tostring(item.stack_size * 2),
								item.localised_name or (item.place_as_equipment_result and {
									"equipment-name." .. item.name,
								}) or {
									"item-name." .. item.name,
								},
							},
							icon_size = 64,
							weight = crate_weight * item.stack_size,
							default_import_location = item.default_import_location,
							icons = {
								{ icon = crate_icon_path, icon_size = 64 },
								{
									icon = item.icon,
									icon_size = item.icon_size,
									scale = 0.2 * (64 / (item.icon_size or 64)),
									shift = { 0, -6 },
								},
							},
							stack_size = 1,
							subgroup = "cargo-crates-items",
							order = "a[" .. item_name .. "]",
						}

						-- ===== spoilage + spoiled crates =====
						if item.spoil_ticks and item.spoil_result then
							crate.spoil_ticks = item.spoil_ticks

							-- spoil_result
							local spoil_name = nil
							if type(item.spoil_result) == "string" then
								spoil_name = item.spoil_result
							elseif type(item.spoil_result) == "table" and item.spoil_result.name then
								spoil_name = item.spoil_result.name
							end
							local s_item = data.raw.item[spoil_name]
								or data.raw.capsule[spoil_name]
								or data.raw.ammo[spoil_name]
								or data.raw.tool[spoil_name]

							if spoil_name then
								-- REUSE --
								local p = prototypes[spoil_name]

								if
									s_item
									and p
									and p.icon
									and p.name ~= empty_crate_item_name
									and not string.find(spoil_name, "^cargo%-crate%")
									and not p.hidden
									and not p.hidden_in_factoriopedia
									and p.group ~= "other"
									and p.subgroup ~= "spawnables"
									and p.subgroup ~= "parameters"
									and p.order ~= nil
									and p.name ~= "pirateship-cannonball"
									and not has_flag(p.flags, "not-stackable")
									and not p.place_result
									and not p.spoil_to_trigger_result
									and p.stack_size < 10000
									and ((p.stack_size or 1) * 2) == (item.stack_size * 2)
								then
									crate.spoil_result = "cargo-crate-" .. spoil_name
								else
									-- new item --
									local key = spoil_name .. "|" .. tostring(item.stack_size * 2)
									local spoiled_crate_name = spoiled_crate_by_key[key]

									if not spoiled_crate_name then
										spoiled_crate_name = "cargo-crate-spoiled-"
											.. spoil_name
											.. "-x"
											.. tostring(item.stack_size * 2)
										spoiled_crate_by_key[key] = spoiled_crate_name

										table.insert(spoiled_crates, {
											type = "item",
											name = spoiled_crate_name,
											weight = crate_weight * item.stack_size,
											allow_quality = false,
											localised_name = {
												"item-name.cargo-crate",
												tostring(item.stack_size * 2),
												(s_item and s_item.localised_name) or { "item-name." .. spoil_name },
											},
											icon_size = 64,
											icons = {
												{ icon = crate_icon_path, icon_size = 64 },
												{
													icon = (s_item and s_item.icon) or item.icon,
													icon_size = (s_item and s_item.icon_size) or item.icon_size or 64,
													scale = 0.2
														* (64 / ((s_item and s_item.icon_size) or item.icon_size or 64)),
													shift = { 0, -6 },
												},
											},
											stack_size = 1,
											subgroup = "cargo-crates-items",
											order = "a[" .. spoil_name .. "]-[" .. tostring(item.stack_size * 2) .. "]",
										})

										table.insert(spoiled_recipes, {
											type = "recipe",
											category = "cargo-crates",
											subgroup = "cargo-crates-recipe",
											name = "unpack-" .. spoiled_crate_name,
											reset_freshness_on_craft = false,
											result_is_always_fresh = false,
											hide_from_signal_gui = false,
											allow_quality = false,
											auto_recycle = false,
											enabled = false,
											maximum_productivity = 0,

											icons = {
												{
													icon = crate_icon_path,
													icon_size = 64,
													shift = { 0, 0 },
												},
												{
													icon = (s_item and s_item.icon) or item.icon,
													icon_size = (s_item and s_item.icon_size) or item.icon_size or 64,
													scale = 0.3
														* (64 / ((s_item and s_item.icon_size) or item.icon_size or 64)),
													shift = { 5, 5 },
												},
												{
													icon = "__base__/graphics/icons/arrows/down-right-arrow.png",
													icon_size = 64,
													shift = { -5, -5 },
													scale = 0.3,
												},
											},

											localised_name = {
												"recipe-name.cargo-crate-unpack",
												tostring(item.stack_size * 2),
												(s_item and s_item.localised_name) or { "item-name." .. spoil_name },
											},

											ingredients = {
												{ type = "item", name = spoiled_crate_name, amount = 1 },
											},
											results = {
												{ type = "item", name = spoil_name, amount = item.stack_size * 2 },
											},
										})

										table.insert(data.raw.technology["cargo-crates"].effects, {
											type = "unlock-recipe",
											recipe = "unpack-" .. spoiled_crate_name,
										})
									end

									crate.spoil_result = spoiled_crate_name
								end
							end
						end
						-- end --
						table.insert(crates, crate)
						-- packing recipe
						table.insert(recipes, {
							type = "recipe",
							--category = "advanced-crafting",
							category = "cargo-crates",
							subgroup = "cargo-crates-items",
							name = crate_name,
							allow_quality = false,
							enabled = false,
							result_is_always_fresh = false,
							reset_freshness_on_craft = false,
							maximum_productivity = 0,
							-- Pack recipe
							ingredients = {
								{ type = "item", name = empty_crate_item_name, amount = 1 },
								{
									type = "item",
									name = item_name,
									amount = (item.stack_size or 1) * 2,
								},
							},
							results = {
								{
									type = "item",
									name = crate_name,
									amount = 1,
								},
							},
						})
						-- unpacking ---

						table.insert(recipes, {
							type = "recipe",
							--category = "advanced-crafting",
							category = "cargo-crates",
							subgroup = "cargo-crates-recipe",
							name = "unpack-" .. crate_name,
							reset_freshness_on_craft = false,
							result_is_always_fresh = false,
							hide_from_signal_gui = false,
							auto_recycle = false,
							enabled = false,
							maximum_productivity = 0,
							icons = {
								{ icon = crate_icon_path, icon_size = 64, shift = { 0, 0 } },
								{
									icon = item.icon,
									icon_size = item.icon_size,
									scale = 0.3 * (64 / (item.icon_size or 64)),
									shift = { 5, 5 },
								},
								{
									icon = "__base__/graphics/icons/arrows/down-right-arrow.png",
									icon_size = 64,
									shift = { -5, -5 },
									scale = 0.3,
								},
							},
							localised_name = {
								"recipe-name.cargo-crate-unpack",
								tostring(item.stack_size * 2),
								item.localised_name or (item.place_as_equipment_result and {
									"equipment-name." .. item.name,
								}) or {
									"item-name." .. item.name,
								},
							},
							ingredients = {
								{
									type = "item",
									name = crate_name,
									amount = 1,
								},
							},
							results = {
								{
									type = "item",
									name = item_name,
									amount = (item.stack_size or 1) * 2,
								},
							},
						})
						table.insert(data.raw.technology["cargo-crates"].effects, {
							type = "unlock-recipe",
							recipe = "unpack-" .. crate_name,
						})
						table.insert(data.raw.technology["cargo-crates"].effects, {
							type = "unlock-recipe",
							recipe = crate_name,
						})
					end
				end
			end
		end
	end

	if next(crates) ~= nil then
		data:extend(crates)
	end
	if next(recipes) ~= nil then
		data:extend(recipes)
	end
end

generate_crates_from(data.raw.item)

if settings.startup["cargo-crates-pack-ammo"].value then
	generate_crates_from(data.raw.ammo)
end
if settings.startup["cargo-crates-pack-capsules"].value then
	generate_crates_from(data.raw.capsule)
end

if settings.startup["cargo-crates-pack-spoilables"].value then
	if next(spoiled_crates) ~= nil then
		data:extend(spoiled_crates)
	end
	if next(spoiled_recipes) ~= nil then
		data:extend(spoiled_recipes)
	end
end

if settings.startup["cargo-crates-can-use-regular-assembling-machines"].value then
	table.insert(data.raw["assembling-machine"]["assembling-machine-1"].crafting_categories, "cargo-crates")
	table.insert(data.raw["assembling-machine"]["assembling-machine-2"].crafting_categories, "cargo-crates")
	table.insert(data.raw["assembling-machine"]["assembling-machine-3"].crafting_categories, "cargo-crates")
	if mods["TFMG"] then
		table.insert(data.raw["assembling-machine"]["assembling-machine"].crafting_categories, "cargo-crates")
		table.insert(data.raw["assembling-machine"]["micro-assembler"].crafting_categories, "cargo-crates")
	end
end
