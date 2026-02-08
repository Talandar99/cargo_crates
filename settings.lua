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
		name = "cargo-crates-pack-spoilables",
		setting_type = "startup",
		default_value = true,
		order = "cargo-crates-c",
	},
	{
		type = "bool-setting",
		name = "cargo-crates-pack-capsules",
		setting_type = "startup",
		default_value = true,
		order = "cargo-crates-d",
	},
	{
		type = "bool-setting",
		name = "cargo-crates-can-use-regular-assembling-machines",
		setting_type = "startup",
		default_value = true,
		order = "cargo-crates-e",
		hidden = true,
	},
})

local function force_setting(setting_type, setting_name, value)
	local setting = data.raw[setting_type .. "-setting"][setting_name]
	if setting then
		if setting_type == "bool" then
			setting.forced_value = value
		else
			setting.allowed_values = { value }
		end
		setting.default_value = value
		setting.hidden = true
	end
end
force_setting("bool", "cargo-crates-can-use-regular-assembling-machines", true)
