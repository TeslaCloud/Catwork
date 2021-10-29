--[[
	Catwork � 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("GarbageRemove")
COMMAND.tip = "Removes garbage spawn point at your view target."
COMMAND.flags = CMD_DEFAULT
COMMAND.access = "s"
COMMAND.alias = {"GarbagePointRemove", "GarbageSpawnRemove"}

function COMMAND:OnRun(player, arguments)
	local position = player:GetEyeTraceNoCursor().HitPos + Vector(0, 0, 32)
	local pointsCount = 0

	for k, v in pairs(cwGarbage.garbagePoints) do
		if (v.position:Distance(position) <= 50) then
			pointsCount = pointsCount + 1;	
			cwGarbage.garbagePoints[k] = nil
		end
	end

	if (pointsCount > 0) then
		if (pointsCount == 1) then
			cw.player:Notify(player, "You have removed "..pointsCount.." garbage spawn.")
		else
			cw.player:Notify(player, "You have removed "..pointsCount.." garbage spawns.")
		end
	else
		cw.player:Notify(player, "There were no garbage spawns near this position.")
	end

	cwGarbage:SaveGarbageSpawnPoints()
end

COMMAND:Register();
