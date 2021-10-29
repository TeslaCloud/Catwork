--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("WoodRemove")
COMMAND.tip = "Удалить точку появления деревянной мебели."
COMMAND.flags = CMD_DEFAULT
COMMAND.access = "s"

function COMMAND:OnRun(player, arguments)
	local position = player:GetEyeTraceNoCursor().HitPos + Vector(0, 0, 32)
	local pointsCount = 0

	for k, v in pairs(cwGather.nodePoints) do
		if (v.position:Distance(position) <= 50000000) then
			pointsCount = pointsCount + 1;	
			cwGather.nodePoints[k] = nil
		end
	end

	if (pointsCount > 0) then
		if (pointsCount == 1) then
			cw.player:Notify(player, "Вы удалили "..pointsCount.." точку появления мебели.")
		else
			cw.player:Notify(player,"Вы удалили "..pointsCount.." точек появления мебели.")
		end
	else
		cw.player:Notify(player, "Точки появления не найдены.")
	end

	cwGather:SaveNodesSpawnPoints()
end

COMMAND:Register();
