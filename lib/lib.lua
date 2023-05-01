dofile("data/scripts/lib/utilities.lua")

function GetTableIndex(table, id)
	for index, value in pairs(table) do
		if value.id == id then
			return index
		end
	end
	return nil
end

function SerializeTable(val, name, skipnewlines, depth)
    skipnewlines = skipnewlines or false
    depth = depth or 0

    local tmp = string.rep(" ", depth)

    if name then tmp = tmp .. name .. " = " end

    if type(val) == "table" then
        tmp = tmp .. "{" .. (not skipnewlines and "\n" or "")

        for k, v in pairs(val) do
			_k = k
			if type(k) == "number" then _k = nil end
            tmp =  tmp .. SerializeTable(v, _k, skipnewlines, depth + 1) .. "," .. (not skipnewlines and "\n" or "")
        end

        tmp = tmp .. string.rep(" ", depth) .. "}"
    elseif type(val) == "number" then
        tmp = tmp .. tostring(val)
    elseif type(val) == "string" then
        tmp = tmp .. string.format("%q", val)
    elseif type(val) == "boolean" then
        tmp = tmp .. (val and "true" or "false")
    else
        tmp = tmp .. "\"[inserializeable datatype:" .. type(val) .. "]\""
    end

    return tmp
end

function dump(o, d)
    if type(o) == 'table' then
         d = tonumber(d) or 0
         local s = '{ ' .. "\n"
         for k,v in pairs(o) do
                if type(k) ~= 'number' then k = '"'..k..'"' end
                for i=0,d,1 do s = s .. "    " end
                s = s .. '['..k..'] = ' .. dump(v, d+1) .. ',' .. "\n"
         end
         for i=1,d,1 do s = s .. "    " end
         return s .. '}'
    else
         return tostring(o)
    end
end