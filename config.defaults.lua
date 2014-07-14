--[[


--]]
local UF, T, C, G, P, U, _ = unpack(select(2, ...))

-- Register with SharedMedia
local LSM = LibStub("LibSharedMedia-3.0")

--[[
		Configuration settings for basic unit frames
--]]

-- Media and font sizes
C["media"] = {
	texture = LSM:Fetch("statusbar", "Striped"),

	-- Fonts
	font = LSM:Fetch("font", "Diavlo"),
	fontOther = LSM:Fetch("font", "Liberation Sans"),

	fontsize1 = 13,
	fontsize2 = 12,
	fontsize3 = 10,
	fontsize4 = 9,

	-- Unitframe border colour
	color_rb = 0.40, -- default 0.40
	color_gb = 0.40, -- default 0.40
	color_bb = 0.40, -- default 0.40
	color_ab = 1.00, -- default 1.00
}

	-- The frames
C["raidframes"] = {
	-- General frame parameters
	gridLayout = "HORIZONTAL", -- groups are arranged horizontally - one above (or below) the other,
							   -- VERTICAL would have groups appear to the right (or left) of each other
	gridGroupsAnchor = "BOTTOMLEFT", -- This is the anchor point for each group - groups will grow from this point
	scale = 1.0,
	padding = 8, -- Distance between frames - the highlight border is 3px, so keep it >3
	showPets = true, -- Pets will be shown as seperate units, vehicles will appear as pets if enabled

	-- X, Y position of frames - the 1, 2, 3, etc. tables
	-- Equates to the total number of groups in the raid (not each group!). If you do not
	-- specify a position for a total number of groups the position of the last highest
	-- will be used
	position = {
		[1] = { "BOTTOMLEFT", UIParent, "CENTER", -136, -350 },
		[2] = { "BOTTOMLEFT", UIParent, "CENTER", -136, -370 },
		[3] = { "BOTTOMLEFT", UIParent, "CENTER", -136, -420 },
		[5] = { "BOTTOMLEFT", UIParent, "CENTER", -880, -150 },
	},

	-- Button parameters
	raidnamelength = 6,
	showRaidHealthPct = false, -- Show health as a "remaining percentage" rather than an "absolute deficit"
	colorSmooth = true, -- Smoothing of health changes, looks pretty
	colorPets = false, -- Colour pets by their class else colour them green

	showOnlyDispellable = false, -- true to only show dispellable unknown debuffs
}
