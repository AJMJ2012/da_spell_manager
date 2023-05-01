function OnModPostInit() -- Called after mod content is added
    dofile("mods/da_spell_manager/files/scripts/spell_cache.lua")
	ModLuaFileAppend("data/scripts/gun/gun_actions.lua", "mods/da_spell_manager/files/scripts/append/spell_manager.lua")
end