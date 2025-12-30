local weight = require("weight")
--
weight.calc()
--
log(serpent.block(weight.lookup))

--
--
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
		if pack_equipment then
			if
				item.icon
				and item_name ~= "wooden-chest"
				and not string.find(item_name, "^cargo%-crate%")
				and not item.hidden
				and not item.hidden_in_factoriopedia
				and item.group ~= "other"
				and item.subgroup ~= "spawnables"
				and item.subgroup ~= "parameters"
				and item.order ~= nil
				and item.name ~= "pirateship-cannonball"
				and not has_flag(item.flags, "not-stackable")
				and not item.spoil_result
				and not item.spoil_ticks
				and not item.place_result
				and item.stack_size < 10000
			then
				local crate_weight = weight.lookup[item_name]
				local crate_name = "cargo-crate-" .. item_name
				table.insert(crates, {
					type = "item",
					name = crate_name,
					allow_quality = false,
					localised_name = {
						"item-name.cargo-crate",
						tostring(item.stack_size * 2),
						item.localised_name
							or (item.place_as_equipment_result and { "equipment-name." .. item.name })
							or {
								"item-name." .. item.name,
							},
					},
					icon_size = 64,
					weight = crate_weight * item.stack_size,
					default_import_location = item.default_import_location,
					icons = {
						{ icon = "__base__/graphics/icons/wooden-chest.png", icon_size = 64 },
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
				})

				table.insert(recipes, {
					type = "recipe",
					--category = "advanced-crafting",
					category = "cargo-crates",
					subgroup = "cargo-crates-items",
					name = crate_name,
					allow_quality = false,
					enabled = false,
					-- Pack recipe
					ingredients = {
						{ type = "item", name = "wooden-chest", amount = 1 },
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
					maximum_productivity = 0,
				})

				table.insert(recipes, {
					type = "recipe",
					--category = "advanced-crafting",
					category = "cargo-crates",
					subgroup = "cargo-crates-recipe",
					icons = {
						{ icon = "__base__/graphics/icons/wooden-chest.png", icon_size = 64, shift = { 0, 0 } },
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
					name = "unpack-" .. crate_name,
					localised_name = {
						"item-name.cargo-crate",
						tostring(item.stack_size * 2),
						item.localised_name
							or (item.place_as_equipment_result and { "equipment-name." .. item.name })
							or {
								"item-name." .. item.name,
							},
					},
					enabled = false,
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
					maximum_productivity = 0,
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

	data:extend(crates)
	data:extend(recipes)
end

generate_crates_from(data.raw.item)
if settings.startup["cargo-crates-pack-ammo"].value then
	generate_crates_from(data.raw.ammo)
end

if settings.startup["cargo-crates-can-use-regular-assembling-machines"].value then
	table.insert(data.raw["assembling-machine"]["assembling-machine-1"].crafting_categories, "cargo-crates")
	table.insert(data.raw["assembling-machine"]["assembling-machine-2"].crafting_categories, "cargo-crates")
	table.insert(data.raw["assembling-machine"]["assembling-machine-3"].crafting_categories, "cargo-crates")
end
