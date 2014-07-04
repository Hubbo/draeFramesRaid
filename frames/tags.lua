--[[


--]]
local _, ns = ...
local oUF = ns.oUF or draeUF

--
local UF, T, C, G, P, U, _ = unpack(select(2, ...))

-- Localise a bunch of functions
local UnitName = UnitName

--[[
		Unit frame tags
--]]
oUF.Tags.Methods["draeraid:name"] =  function(u, r)
	local name = UnitName(r or u) or "Unknown"

	return T.UTF8(name, UF.db["raidframes"].raidnamelength or 4, false) .. "|r"
end
oUF.Tags.Events["draeraid:name"] =  "UNIT_NAME_UPDATE UNIT_ENTERED_VEHICLE UNIT_EXITED_VEHICLE UNIT_PET"
