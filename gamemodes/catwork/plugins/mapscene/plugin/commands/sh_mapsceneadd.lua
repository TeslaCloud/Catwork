--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("MapSceneAdd")
COMMAND.tip = "Add a map scene at your current position."
COMMAND.text = "<bool ShouldSpin>"
COMMAND.flags = CMD_DEFAULT
COMMAND.access = "a"
COMMAND.optionalArguments = 1

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local data = {
		shouldSpin = cw.core:ToBool(arguments[1]),
		position = player:EyePos(),
		angles = player:EyeAngles()
	}

	cwMapScene.storedList[#cwMapScene.storedList + 1] = data
	cwMapScene:SaveMapScenes()

	cw.player:Notify(player, "You have added a map scene.")
end

COMMAND:Register();
