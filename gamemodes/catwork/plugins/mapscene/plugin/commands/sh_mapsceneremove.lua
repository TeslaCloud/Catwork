--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("MapSceneRemove")
COMMAND.tip = "Remove map scenes at your current position."
COMMAND.flags = CMD_DEFAULT
COMMAND.access = "a"

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	if (#cwMapScene.storedList > 0) then
		local position = player:EyePos()
		local removed = 0

		for k, v in pairs(cwMapScene.storedList) do
			if (v.position:Distance(position) <= 256) then
				cwMapScene.storedList[k] = nil

				removed = removed + 1
			end
		end

		if (removed > 0) then
			if (removed == 1) then
				cw.player:Notify(player, "You have removed "..removed.." map scene.")
			else
				cw.player:Notify(player, "You have removed "..removed.." map scenes.")
			end
		else
			cw.player:Notify(player, "There were no map scenes near this position.")
		end
	else
		cw.player:Notify(player, "There are no map scenes.")
	end
end

COMMAND:Register();
