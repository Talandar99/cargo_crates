data:extend({
	{
		type = "item-group",
		name = "cargo-crates",
		order = "z",
		inventory_order = "z",
		icon = "__base__/graphics/icons/wooden-chest.png",
		icon_size = 64,
	},
	{
		type = "item-subgroup",
		name = "cargo-crates-items",
		group = "cargo-crates",
		order = "a",
	},
	{
		type = "item-subgroup",
		name = "cargo-crates-recipe",
		group = "cargo-crates",
		order = "b",
	},
})

data:extend({
	{
		type = "recipe-category",
		name = "cargo-crates",
	},
})

data:extend({
	{
		type = "technology",
		name = "cargo-crates",
		icon = "__cargo_crates__/thumbnail.png",
		icon_size = 256,
		effects = {},
		prerequisites = { "logistic-science-pack" },
		unit = {
			count = 200,
			ingredients = {
				{ "automation-science-pack", 1 },
				{ "logistic-science-pack", 1 },
			},
			time = 30,
		},
		order = "c-a",
	},
})
