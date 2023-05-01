dofile("data/scripts/lib/mod_settings.lua")

local mod_id = "da_spell_manager"
mod_settings_version = 1
mod_settings = {
	{
		id = "sort_spells",
		ui_name = "Sort Spells by Name",
		value_default = false,
		scope = MOD_SETTING_SCOPE_RUNTIME
	},
	{
		ui_fn = mod_setting_vertical_spacing,
		not_setting = true,
	},
}


function ModSettingsUpdate( init_scope )
	local old_version = mod_settings_get_version( mod_id )
	mod_settings_update( mod_id, mod_settings, init_scope )
end

function ModSettingsGuiCount()
	return mod_settings_gui_count( mod_id, mod_settings )
end

function HasSettingFlag(name)
    return ModSettingGet(name) or false
end

function AddSettingFlag(name)
    ModSettingSet(name, true)
end

function RemoveSettingFlag(name)
    ModSettingRemove(name)
end

function SortSpells(a,b)
	return string.lower(GameTextGetTranslatedOrNot(a.name)) < string.lower(GameTextGetTranslatedOrNot(b.name))
end

local action_types = {
	"ACTION_TYPE_PROJECTILE",
	"ACTION_TYPE_STATIC_PROJECTILE",
	"ACTION_TYPE_MODIFIER",
	"ACTION_TYPE_DRAW_MANY",
	"ACTION_TYPE_MATERIAL",
	"ACTION_TYPE_OTHER",
	"ACTION_TYPE_UTILITY",
	"ACTION_TYPE_PASSIVE",
}

local action_type_names = {
	"$inventory_actiontype_projectile",
	"$inventory_actiontype_staticprojectile",
	"$inventory_actiontype_modifier",
	"$inventory_actiontype_drawmany",
	"$inventory_actiontype_material",
	"$inventory_actiontype_other",
	"$inventory_actiontype_utility",
	"$inventory_actiontype_passive",
	"$menuoptions_configurecontrols_keyname_unknown",
}

local action_backgrounds = {
	"item_bg_projectile",
	"item_bg_static_projectile",
	"item_bg_modifier",
	"item_bg_draw_many",
	"item_bg_material",
	"item_bg_other",
	"item_bg_utility",
	"item_bg_passive",
	"item_bg_purchase_2",
}

function ModSettingsGui( gui, in_main_menu )
	screen_width, screen_height = GuiGetScreenDimensions(gui)

	mod_settings_gui( mod_id, mod_settings, gui, in_main_menu )

	local id = 537845
	local function new_id() id = id + 1; return id end

	GuiOptionsAdd( gui, GUI_OPTION.NoPositionTween )

	if(in_main_menu)then
		GuiText( gui, 0, 0, "You must start the game to configure spells." )
	else
		spell_cache = dofile("mods/da_spell_manager/cache/spell_cache.lua")

		GuiLayoutBeginHorizontal( gui, 0, 0, false, 2, 2 )
		if GuiButton( gui, new_id(), 0, 0, "Enable All" )then
			for k, v in pairs(spell_cache) do
				RemoveSettingFlag(v.id .. "_dasm_disabled")
			end
		end
		GuiText( gui, 0, 0, " " )
		if GuiButton( gui, new_id(), 0, 0, "Disable All" )then
			for k, v in pairs(spell_cache) do
				AddSettingFlag(v.id .. "_dasm_disabled")
			end
		end
		GuiLayoutEnd(gui)

		GuiLayoutBeginHorizontal( gui, 0, 0, false, 2, 2 )
		GuiText( gui, 0, 0, "$menu_modsettings_changes_restart" )
		GuiLayoutEnd(gui)

		local list_of_spells = spell_cache
		if ModSettingGet("da_spell_manager.sort_spells") then
			table.sort(list_of_spells, SortSpells)
		end
		
		for i = 0, 8 do
			GuiText( gui, 0, 3, action_type_names[i+1])
			GuiLayoutBeginHorizontal( gui, 0, 0, false, 2, 2 )
			local j = 0
			for k, v in pairs(list_of_spells) do
				if (i == v.type or (i == 8 and (v.type == nil or v.type > 8 or v.type < 0))) then
					if (math.fmod(j,14) == 0) then
						GuiLayoutEnd(gui)
						GuiLayoutBeginHorizontal( gui, 0, 0, false, 2, 2 )
					end
					j = j + 1

					local alpha = 1;
					local name = GameTextGetTranslatedOrNot(v.name) .. "\n" .. GameTextGetTranslatedOrNot(v.description) .. "\n" .. "(" .. v.id .. ")"

					GuiOptionsAddForNextWidget(gui, GUI_OPTION.NonInteractive)
					if (v.spawn_requires_flag ~= nil and HasFlagPersistent(v.spawn_requires_flag) == false) then
						name = name .. "\nNot Unlocked"
						alpha = 0.5
					end
					if (HasSettingFlag(v.id .. "_dasm_disabled")) then
						name = name .. "\nDisabled"
						alpha = 0.25
					end

					GuiOptionsAddForNextWidget(gui, GUI_OPTION.NonInteractive)
					if ((v.spawn_requires_flag ~= nil and HasFlagPersistent(v.spawn_requires_flag) == false) or HasSettingFlag(v.id .. "_dasm_disabled")) then
						GuiImage( gui, new_id(), 2, -2, "data/ui_gfx/inventory/inventory_box_inactive_overlay.png", 1, 1, 0 )
					else
						GuiImage( gui, new_id(), 2, -2, "data/ui_gfx/inventory/full_inventory_box.png", 1, 1, 0 )
					end

					GuiZSetForNextWidget(gui, -99)
					GuiOptionsAddForNextWidget(gui, GUI_OPTION.NonInteractive)
					GuiImage( gui, new_id(), -22, -2, "data/ui_gfx/inventory/" .. action_backgrounds[i+1] .. ".png", alpha, 1, 0 )

					GuiZSetForNextWidget(gui, -100)
					GuiOptionsAddForNextWidget(gui, GUI_OPTION.NonInteractive)
					GuiImage( gui, new_id(), -20, 0, v.sprite, alpha, 1, 0 )

					if GuiImageButton( gui, new_id(), -18, 0, "", "mods/da_spell_manager/files/ui_gfx/blank.png" ) then
						if (HasSettingFlag(v.id .. "_dasm_disabled")) then
							RemoveSettingFlag(v.id .. "_dasm_disabled")
						else
							AddSettingFlag(v.id .. "_dasm_disabled")
						end
					end

					if (HasSettingFlag(v.id .. "_dasm_disabled")) then
						GuiTooltip( gui, name, "Click to enable" );
						GuiOptionsAddForNextWidget(gui, GUI_OPTION.NonInteractive)
						GuiZSetForNextWidget(gui, -101)
						GuiImage( gui, new_id(), -18, 0, "mods/da_spell_manager/files/ui_gfx/disabled.png", 1, 1, 0 )
					else
						GuiTooltip( gui, name, "Click to disable" );
					end
					if ((v.spawn_requires_flag ~= nil and HasFlagPersistent(v.spawn_requires_flag) == false) and not HasSettingFlag(v.id .. "_dasm_disabled")) then
						GuiZSetForNextWidget(gui, -101)
						GuiOptionsAddForNextWidget(gui, GUI_OPTION.NonInteractive)
						GuiImage( gui, new_id(), -22, 0, "data/ui_gfx/inventory/icon_no_cards.png", 1, 1, 0 )
					end
				end
			end
			GuiLayoutEnd(gui)
		end

		for i = 1, 5 do
			GuiText( gui, 0, 0, "" )
		end
	end
end