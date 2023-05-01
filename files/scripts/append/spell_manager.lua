function HasSettingFlag(name)
    return ModSettingGet(name) or false
end

-- Prevent disabled spells from spawning

-- Can't override GetRandomAction, GetRandomActionWithType
-- Guess I'll just have to remove the spawn chances.

for k, v in pairs(actions) do
    if (HasSettingFlag(v.id .. "_dasm_disabled")) then
        actions[k].description = "Disabled"
        actions[k].related_projectiles = {}
        actions[k].related_extra_entities = {}
        actions[k].type = 666
        actions[k].spawn_level = ""
        actions[k].spawn_probability = ""
        actions[k].spawn_requires_flag = "this_spell_is_disabled"
        actions[k].mana = 0
        actions[k].custom_xml_file = ""
		actions[k].action = function()
			draw_actions( 1, true )
		end
    end
end