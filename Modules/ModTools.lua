-- Path of Building
--
-- Module: Mod Tools
-- Various functions for dealing with modifiers
--

local pairs = pairs
local t_insert = table.insert
local m_floor = math.floor
local m_abs = math.abs
local band = bit.band
local bor = bit.bor

modLib = { }

function modLib.createMod(modName, modType, modVal, ...)
	local flags = 0
	local keywordFlags = 0
	local tagStart = 1
	local source
	if select('#', ...) >= 1 and type(select(1, ...)) == "string" then
		source = select(1, ...)
		tagStart = 2
	end
	if select('#', ...) >= 2 and type(select(2, ...)) == "number" then
		flags = select(2, ...)
		tagStart = 3
	end
	if select('#', ...) >= 3 and type(select(3, ...)) == "number" then
		keywordFlags = select(3, ...)
		tagStart = 4
	end
	return {
		name = modName,
		type = modType,
		value = modVal,
		flags = flags,
		keywordFlags = keywordFlags,
		source = source,
		tagList = { select(tagStart, ...) }
	}
end

modLib.parseMod = LoadModule("Modules/ModParser")

function modLib.formatFlags(flags, src)
	local flagNames = { }
	for name, val in pairs(src) do
		if band(flags, val) == val then
			t_insert(flagNames, name)
		end
	end
	table.sort(flagNames)
	local ret
	for i, name in ipairs(flagNames) do
		ret = (ret and ret.."," or "") .. name
	end
	return ret or "-"
end

function modLib.formatTags(tagList)
	local ret
	for _, tag in ipairs(tagList) do
		local paramNames = { }
		local haveType
		for name, val in pairs(tag) do
			if name == "type" then
				haveType = true
			else
				t_insert(paramNames, name)
			end
		end
		table.sort(paramNames)
		if haveType then
			t_insert(paramNames, 1, "type")
		end
		local str = ""
		for i, paramName in ipairs(paramNames) do
			if i > 1 then
				str = str .. "/"
			end
			str = str .. string.format("%s=%s", paramName, tostring(tag[paramName]))
		end
		ret = (ret and ret.."," or "") .. str
	end
	return ret or "-"
end

function modLib.formatValue(value)
	if type(value) ~= "table" then
		return tostring(value)
	end
	local paramNames = { }
	local haveType
	for name, val in pairs(value) do
		if name == "type" then
			haveType = true
		else
			t_insert(paramNames, name)
		end
	end
	table.sort(paramNames)
	if haveType then
		t_insert(paramNames, 1, "type")
	end
	local ret = ""
	for i, paramName in ipairs(paramNames) do
		if i > 1 then
			ret = ret .. "/"
		end
		ret = ret .. string.format("%s=%s", paramName, tostring(value[paramName]))
	end
	return "{"..ret.."}"
end

function modLib.formatMod(mod)
	return string.format("%s = %s|%s|%s|%s|%s", modLib.formatValue(mod.value), mod.name, mod.type, modLib.formatFlags(mod.flags, ModFlag), modLib.formatFlags(mod.keywordFlags, KeywordFlag), modLib.formatTags(mod.tagList))
end
