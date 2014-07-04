--[[
		Ressurect - using libRes
--]]
local _, ns = ...
local oUF = ns.oUF or draeUF

--
local UF, T, C, G, P, U, _ = unpack(select(2, ...))
local I = UF:NewModule("StatusRes")

local LibResInfo = LibStub("LibResInfo-1.0", true)

--
local UnitCastingInfo = UnitCastingInfo

--
local priority = 50
local color = {
	["CASTING"] = { r = 1.0, g = 0.8, b = 0   },
	["MASSRES"] = { r = 1.0, g = 0.8, b = 0   },
	["SELFRES"] = { r = 1.0, g = 0,   b = 0.4 },
	["PENDING"] = { r = 0,   g = 1.0, b = 0   }
}

--[[

--]]
local Update = function(self, event, unit)
	if (unit and self.unit ~= unit) then return end
	unit = unit or self.unit

	local status, expires, caster, _ = LibResInfo:UnitHasIncomingRes(unit)
	local start, duration

	if (status and UnitIsDeadOrGhost(unit)) then
		if (status == "CASTING" or status == "MASSRES") then
			if (caster) then
				 _, _, _, _, start = UnitCastingInfo(caster)

				if (start) then
					start = start / 1000
					duration = expires - start
				end
			end
		elseif (status == "SELFRES") then
			start = expires - 360
			duration = 360
		else
			start = expires - 60
			duration = 60
		end

		self:GainedStatus(unit, "status_res", priority, color[status], nil, nil, nil, nil, start, duration)
	else
		self:LostStatus(unit, "status_res")
	end
end

local Enable = function(self)
	if (self.statuscache) then
		return true
	end
end

local Disable = function(self)
end

oUF:AddElement("StatusRes", Update, Enable, Disable)

local Callback = function(event, unit, guid)
	if (strsub(event, 1, 18) == "LibResInfo_MassRes") then
		for guid, frame in pairs(oUF.frames) do
			if (frame) then
				Update(frame, event, frame.unit or nil)
			end
		end
	else
		local frame = guid and oUF.frames[guid] or nil

		if (frame) then
			Update(frame, event, frame.unit or nil)
		end
	end
end

LibResInfo.RegisterAllCallbacks("StatusRes", Callback, true)
