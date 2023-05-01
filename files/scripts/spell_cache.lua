dofile("data/scripts/lib/utilities.lua")
dofile("mods/da_spell_manager/lib/lib.lua")
dofile("data/scripts/gun/gun_enums.lua")
dofile("data/scripts/gun/gun_actions.lua")

-- Quick and dirty cache
spell_cache = {}
-- Remove duplicates
for k, v in pairs(actions) do
    if (not GetTableIndex(spell_cache, v.id)) then
        table.insert(spell_cache, v)
    end
end
ModTextFileSetContent("mods/da_spell_manager/cache/spell_cache.lua", "return " .. SerializeTable(spell_cache))
