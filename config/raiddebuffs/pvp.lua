local UF, T, C, G, P, U, _ = unpack(select(2, ...))

-- PvP/World

UF["raiddebuffs"]["pvp"] = function()
	UF:AddRaidDebuff(true, 23335,  6, true) -- Silverwing Flag
	UF:AddRaidDebuff(true, 34976,  6, true) -- Netherstorm Flag

	UF:AddRaidDebuff(true, 118,    8) --Polymorph
	UF:AddRaidDebuff(true, 3355,   8) --Freezing Trap
	UF:AddRaidDebuff(true, 20066,  8) --Repentance
	UF:AddRaidDebuff(true, 5782,   8) --Fear
	UF:AddRaidDebuff(true, 6770,   8) --Sap
	UF:AddRaidDebuff(true, 2094,   8) --Blind
	UF:AddRaidDebuff(true, 51514,  8) --Hex
	UF:AddRaidDebuff(true, 853,    8) --Hammer of Justice
	UF:AddRaidDebuff(true, 44572,  7) --Deep Freeze
	UF:AddRaidDebuff(true, 30108,  10) --Unstable Affliction
	UF:AddRaidDebuff(true, 339,    8) --Entangling Roots
	UF:AddRaidDebuff(true, 122,    8) --Frost Nova
end
