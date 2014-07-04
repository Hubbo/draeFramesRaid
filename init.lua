--[[


--]]
local addon, ns = ...
local oUF = ns.oUF or draeUF

local draeUI = _G.draeUI

-- Saved Variables
local thisAddon = LibStub("AceAddon-3.0"):NewAddon(addon, "AceEvent-3.0")
thisAddon.VC= {}
thisAddon.VC["profile"] = {}
thisAddon.VC["global"] = {}
thisAddon.VC["class"] = {}

-- Define common elements for our namespace T, C, P
ns[1] = thisAddon
ns[2] = draeUI[1] -- Place T from draeUI into this namespace for ease of access
ns[3] = thisAddon.VC["profile"]
ns[4] = thisAddon.VC["global"]
ns[5] = thisAddon.VC["class"]

-- as per ns[]
local UF, T, C, G, P, U, _ = unpack(select(2, ...))

-- Local copies
local _G = _G
local UIParent, InCombatLockdown, GetNumGroupMembers, GetRaidRosterInfo = UIParent, InCombatLockdown, GetNumGroupMembers, GetRaidRosterInfo
local select, format, mmax = select, string.format, math.max

-- Contains the raid headers
UF.raidHeaders = {}
UF.relPoint = ""

-- Functions for instance specific raid debuffs
UF["raiddebuffs"] = {
	instances = {},
}

UF.dispellClasses = {
	["PRIEST"] = {
		["Magic"] = true
	},
	["SHAMAN"] = {
		["Curse"] = true
	},
	["PALADIN"] = {
		["Poison"] = true,
		["Disease"] = true
	},
	["MAGE"] = {
		["Curse"] = true
	},
	["DRUID"] = {
		["Curse"] = true,
		["Poison"] = true,
	},
	["MONK"] = {
		["Disease"] = true,
		["Poison"] = true
	}
}

local CheckSpec
do
	local healerClasses = {
		["DRUID"] = 4,
		["MONK"] = 2,
		["PALADIN"] = 1,
		["SHAMAN"] = 3,
	}

	CheckSpec = function()
		local spec = GetSpecialization()

		if (UF.playerSpec == spec) then return end

		if (healerClasses[T.playerClass] and healerClasses[T.playerClass] == spec) then
			UF.dispellClasses["SHAMAN"]["Disease"] = true
			UF.dispellClasses["PALADIN"]["Disease"] = true
			UF.dispellClasses["DRUID"]["Disease"] = true
			UF.dispellClasses["MONK"]["Disease"] = true

			UF.Print("Indicators enabled for healer spec dispells")
		elseif (T.playerClass == "PRIEST" and (spec == 1 or spec == 2)) then
			UF.dispellClasses["PRIEST"]["Disease"] = true

			UF.Print("Indicators enabled for healer spec dispells")
		else
			if (T.playerClass == "PRIEST") then
				UF.dispellClasses["PRIEST"]["Disease"] = nil
			else
				UF.dispellClasses["SHAMAN"]["Disease"] = nil
				UF.dispellClasses["PALADIN"]["Disease"] = nil
				UF.dispellClasses["DRUID"]["Disease"] = nil
				UF.dispellClasses["MONK"]["Disease"] = nil
			end

			UF.Print("Indicators disabled for healer spec dispells")
		end

		UF.playerSpec = spec
	end
end

--[[
		Load variables when addon loaded
--]]
UF.OnInitialize = function(self)
	-- Pull in database
	local db = T.dbObj:RegisterNamespace("draeFramesRaid", self.VC)

	self.db = db.profile
	self.dbClass = db.class[T.playerClass]
end

UF.OnEnable = function(self)
	CheckSpec()

	self:RegisterEvent("PLAYER_TALENT_UPDATE", CheckSpec)
end

--[[
		Local functions
--]]
local CreateRaidAnchor = function(header, n)
	local numRaidMembers = n and n or GetNumGroupMembers()

	local numSubGroups, maxInSubGroup, currentGroup = 1, 0, 0

	for i = 1, numRaidMembers do
		name, _, groupNum = GetRaidRosterInfo(i)

		-- If we have no one in group 1 but people in groups 2 and 3
		-- we _still_ treat it as a > 10 man group, so this works fine
		if (groupNum and numSubGroups < groupNum) then
			numSubGroups = groupNum
		end

		if (currentGroup == groupNum) then
			maxInSubGroup = maxInSubGroup + 1
		else
			maxInSubGroup = 1
		end

		currentGroup = groupNum
	end

	for i = numSubGroups, 1, -1 do
		if (UF.db["raidframes"].position[i]) then
			header:SetPoint(unpack(UF.db["raidframes"].position[i]))

			break
		end
	end
end

local getRelativePoint = function(point, horizontal)
	if (point == "TOPLEFT") then
		if (horizontal == "HORIZONTAL") then
			return "BOTTOMLEFT", 1, -1
		else
			return "TOPRIGHT", 1, -1
		end
	elseif (point == "TOPRIGHT") then
		if (horizontal == "HORIZONTAL") then
			return "BOTTOMRIGHT", -1, -1
		else
			return "TOPLEFT", -1, -1
		end
	elseif (point == "BOTTOMLEFT") then
		if (horizontal == "HORIZONTAL") then
			return  "TOPLEFT", 1, 1
		else
			return "BOTTOMRIGHT", 1, 1
		end
	elseif (point == "BOTTOMRIGHT") then
		if (horizontal == "HORIZONTAL") then
			return "TOPRIGHT", -1, 1
		else
			return "BOTTOMLEFT", -1, 1
		end
	end
end

local getColumnAnchorPoint = function(point, horizontal)
	if (horizontal ~= "HORIZONTAL") then
		if (point == "TOPLEFT" or point == "BOTTOMLEFT") then
			return "LEFT"
		elseif (point == "TOPRIGHT" or point == "BOTTOMRIGHT") then
			return "RIGHT"
		end
	else
		if (point == "TOPLEFT" or point == "TOPRIGHT") then
			return "TOP"
		elseif (point == "BOTTOMLEFT" or point == "BOTTOMRIGHT") then
			return "BOTTOM"
		end
	end

	return point
end

--[[
		Spawn the frames
--]]
UF.OnEnable = function(self)
	local initialConfigFunction = ([[
		local unit = ...

		self:SetWidth(%d)
		self:SetHeight(%d)
	]])

	local visibility = "raid,party,solo"

	-- Setup orientation and determine relative points and directions for groups
	local xOffset, yOffset, point

	if (UF.db["raidframes"].gridLayout == "HORIZONTAL") then
		if (UF.db["raidframes"].gridGroupsAnchor == "TOPLEFT" or UF.db["raidframes"].gridGroupsAnchor == "BOTTOMLEFT") then
			xOffset = 8
			yOffset = 0
			point = "LEFT"
		else
			xOffset = -8
			yOffset = 0
			point = "RIGHT"
		end
	else
		if (UF.db["raidframes"].gridGroupsAnchor == "TOPLEFT" or UF.db["raidframes"].gridGroupsAnchor == "TOPRIGHT") then
			xOffset = 0
			yOffset = -8
			point = "TOP"
		else
			xOffset = 0
			yOffset = 8
			point = "BOTTOM"
		end
	end

	local relPoint, xMult, yMult = getRelativePoint(UF.db["raidframes"].gridGroupsAnchor, UF.db["raidframes"].gridLayout)
	local colAnchor = getColumnAnchorPoint(UF.db["raidframes"].gridGroupsAnchor, UF.db["raidframes"].gridLayout)

	self.relPoint = relPoint

	oUF:SetActiveStyle("DraeRaid")

	-- Create raid headers
	for i = 1, NUM_RAID_GROUPS do
		local header = oUF:SpawnHeader("DraeRaid"..i, nil, visibility,
			"showPlayer", true,
			"showRaid", true,

			"oUF-initialConfigFunction", initialConfigFunction:format(48, 40),

			"groupBy", "GROUP",
			"groupFilter", tostring(i),
			"groupingOrder", "1,2,3,4,5,6,7,8",

			"initial-width", 48,
			"initial-height", 40,
			"xOffset", xOffset,
			"yOffset", yOffset,
			"point", point,  -- RIGHT for growing right to left, LEFT for growing left to right
			"sortMethod", "NAME",
			"sortDir", "ASC", -- DESC for left to right, ASC for right to left
			"unitsPerColumn", 5,
			"maxColumns", 8,
			"columnAnchorPoint", colAnchor
		)

		if (i == 1) then
			header:SetAttribute("showParty", true)

			CreateRaidAnchor(header)
		else
			if (UF.db["raidframes"].gridLayout == "HORIZONTAL") then
				xMult = 0
			else
				yMult = 0
			end

			header:SetPoint(UF.db["raidframes"].gridGroupsAnchor, self.raidHeaders[i - 1], relPoint, 10 * xMult, 10 * yMult)
		end

		header:SetScale(UF.db["raidframes"].scale)

		self.raidHeaders[i] = header
	end

	if (UF.db["raidframes"].showPets) then
		local headerPet = oUF:SpawnHeader("DraeRaidPet", "SecureGroupPetHeaderTemplate", visibility,
			"showPlayer", true,
			"showParty", true,
			"showRaid", true,

			"oUF-initialConfigFunction", initialConfigFunction:format(48, 25),

			"filterOnPet", true,

			"initial-width", 48,
			"initial-height", 30,
			"xOffset", xOffset, -- +ve for right, -ve for left
			"yOffset", yOffset,
			"point", point,  -- RIGHT for growing right to left, LEFT for growing left to right
			"unitsPerColumn", 5,
			"maxColumns", 8,
			"columnSpacing", 8,
			"columnAnchorPoint", colAnchor
		)
		headerPet:SetScale(UF.db["raidframes"].scale)

		self.raidHeaders["pet"] = headerPet
	end

	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("GROUP_ROSTER_UPDATE")
	self:RegisterEvent("UNIT_PET")

	-- Disable Blizz raid frames
	CompactRaidFrameManager.Show = CompactRaidFrameManager.Hide
	CompactRaidFrameManager:UnregisterAllEvents()
	CompactRaidFrameManager:Hide()

	CompactRaidFrameContainer.Show = CompactRaidFrameContainer.Hide
	CompactRaidFrameContainer:UnregisterAllEvents()
	CompactRaidFrameContainer:Hide()
end

--[[
		Dynamically change displayed group frames when in raid
		so pet frame is always above last displayed group
--]]
UF.UpdateRaidLayout = function(self)
	if (InCombatLockdown()) then
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
		return
	end
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")

	local lastGroup = 1
	local numRaidMembers = GetNumGroupMembers()

	if (numRaidMembers > 0) then
		-- loop through ALL raid members and find the last group (blargh)
		local playerGroup
		for member = 1, numRaidMembers do
			local _, _, playerGroup = GetRaidRosterInfo(member)
			lastGroup = mmax(lastGroup, playerGroup)
		end

		CreateRaidAnchor(self.raidHeaders[1], numRaidMembers)
	end

	if (UF.db["raidframes"].showPets) then
		self.raidHeaders["pet"]:SetPoint(UF.db["raidframes"].gridGroupsAnchor, self.raidHeaders[lastGroup], self.relPoint, 0, 15) -- Offset from the raid group
	end
end

UF.PLAYER_ENTERING_WORLD = function(self)
	self:UpdateRaidLayout()
end
UF.PLAYER_REGEN_ENABLED	= UF.PLAYER_ENTERING_WORLD
UF.GROUP_ROSTER_UPDATE = UF.PLAYER_ENTERING_WORLD
UF.UNIT_PET = UF.PLAYER_ENTERING_WORLD
