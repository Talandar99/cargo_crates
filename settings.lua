data:extend({
	{
		type = "bool-setting",
		name = "cargo-crates-pack-ammo",
		setting_type = "startup",
		default_value = true,
		order = "cargo-crates-a",
	},
	{
		type = "bool-setting",
		name = "cargo-crates-pack-equipment",
		setting_type = "startup",
		default_value = true,
		order = "cargo-crates-b",
	},
	{
		type = "bool-setting",
		name = "cargo-crates-can-use-regular-assembling-machines",
		setting_type = "startup",
		default_value = true,
		order = "cargo-crates-c",
		hidden = true,
	},
})
