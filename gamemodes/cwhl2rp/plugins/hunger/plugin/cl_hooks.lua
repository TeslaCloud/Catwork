--[[
	© 2016 TeslaCloud Studios.
	Please do not use anywhere else.
--]]

local PLUGIN = PLUGIN

function PLUGIN:GetBars(bars)
	local hunger = cw.client:GetNetVar("Hunger") or 100
	local thirst = cw.client:GetNetVar("Thirst") or 100

	if (hunger < 90 and cw.client:Alive() and self:PlayerHasNeeds(cw.client)) then
		bars:Add("#Bars_Hunger", Color(100, 175, 175, 255), "", hunger, 100, hunger < 10, nil, thirst, "#Bars_Thirst")
	end
end
