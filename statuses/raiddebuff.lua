--[[
		Inspired by Grid, Aptcheka and others
--]]
local _, ns = ...
local oUF = ns.oUF or draeUF

--
local UF, T, C, G, P, U, _ = unpack(select(2, ...))
local I = UF:NewModule("StatusRaidDebuffs", "AceEvent-3.0")

--
local UnitAura, UnitIsVisible, UnitIsDeadOrGhost, GetSpellInfo = UnitAura, UnitIsVisible, UnitIsDeadOrGhost, GetSpellInfo
local twipe = table.wipe

--
local loadedDebuffZone
local debuff_list = {}

local priority = 99
local debuffTypeColor = {
	["Magic"] 	= { r = 0.2, g = 0.6, b = 1.0 },
	["Disease"] = { r = 0.6, g = 0.4, b = 0   },
	["Poison"] 	= { r = 0,   g = 0.6, b = 1.0 },
	["Curse"] 	= { r = 0.6, g = 0,   b = 1.0 }
}

--[[

--]]
UF.AddRaidDebuff = function(self, enable, spellid, pr, icon2, nocolour, noicon)
	local name = GetSpellInfo(spellid)

	if (not name) then
		T.Print("[ DEBUG ] Cannot find spell for raid debuff with id: ", spellid)
		return
	end

	if (not debuff_list[spellid]) then
		debuff_list[spellid] = {
			enable = enable,
			name = name,
			priority = pr,
			icon2 = icon2,
			nocolour = nocolour,
			noicon = noicon,
			detected = false
		}
	end
end

local LoadZoneDebuffs = function()
	local zoneName, _ = GetInstanceInfo()

	if (loadedDebuffZone ~= zoneName) then
		-- Always load pvp
		UF["raiddebuffs"].pvp()

		local add = UF["raiddebuffs"].instances[zoneName] or nil

		if (add) then
			twipe(debuff_list)

			add()
			loadedDebuffZone = zoneName

			T.Print("Debuff indicators loaded for |cff00dd00" .. zoneName .. "|r")
		end
	end
end

--[[

--]]
local Update
do
	local name, icon, count, dtype, duration, expires

	Update = function(self, event, unit)
		if (unit and self.unit ~= unit) then return end
		unit = unit or self.unit

		if (loadedDebuffZone and not UnitIsDeadOrGhost(unit)) then -- and UnitIsVisible(unit)
			local d_name, d_icon, d_color, d_start, d_duration, d_count
			local d_name2, d_icon2, d_color2, d_start2, d_duration2, d_count2

			local d_priority = 0
			local d_priority2 = 0

			local index = 1

			while (true) do
				name, _, icon, count, dtype, duration, expires, _, _, _, spellid = UnitAura(unit, index, "HARMFUL")

				if (not name) then
					break
				end

				if (debuff_list[spellid]) then
					local data = debuff_list[spellid]

					if (data.enable) then
						if (not data.icon2 and d_priority < data.priority) then
--						print("FOUND 1 ", name, " ON ", UnitName(unit), " [", (expires - duration), count, "] ")
							d_priority = data.priority
							d_name = name
							d_icon = not data.noicon and icon
							d_start = expires - duration
							d_duration = duration
							d_count = count
							d_color = dtype and debuffTypeColor[dtype] or nil
						end

						if (data.icon2 and d_priority2 < data.priority) then
--						print("FOUND 2 ", name, " ON ", UnitName(unit), " [", (expires - duration), count, "] ")
							d_priority2 = data.priority
							d_name2 = name
							d_icon2 = not data.noicon and icon
							d_start2 = expires - duration
							d_duration2 = duration
							d_count2 = count
							d_color2 = dtype and debuffTypeColor[dtype] or nil
						end
					end
				end

				index = index + 1
			end

			if (d_name) then
				self:GainedStatus(unit, "status_raiddebuff", priority, d_color, d_icon, nil, nil, nil, d_start, d_duration, d_count)
			else
				self:LostStatus(unit, "status_raiddebuff")
			end

			if (d_name2) then
				self:GainedStatus(unit, "status_raiddebuff2", priority, d_color2, d_icon2, nil, nil, nil, d_start2, d_duration2, d_count2)
			else
				self:LostStatus(unit, "status_raiddebuff2")
			end
		else
			self:LostStatus(unit, "status_raiddebuff")
			self:LostStatus(unit, "status_raiddebuff2")
		end
	end
end

local Enable = function(self)
	if (self.statuscache) then
		self:RegisterEvent("UNIT_AURA", Update)
		return true
	end
end

local Disable = function(self)
	if (self.statuscache) then
		self:UnregisterEvent("UNIT_AURA", Update)
	end
end

oUF:AddElement("StatusRaidDebuffs", Update, Enable, Disable)

--[[

--]]
I.OnEnable = function(self)
	self:RegisterEvent("PLAYER_ENTERING_WORLD", LoadZoneDebuffs)
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA", LoadZoneDebuffs)
end
