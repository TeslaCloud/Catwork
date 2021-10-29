--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("MapChange")
COMMAND.tip = "#Command_Mapchange_Description"
COMMAND.text = "#Command_Mapchange_Syntax"
COMMAND.access = "a"
COMMAND.arguments = 1
COMMAND.optionalArguments = 1
COMMAND.alias = {"Changelevel"}

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local sNewMap = string.lower(arguments[1])

	if (file.Exists("maps/"..sNewMap..".bsp", "GAME")) then
		cw.player:NotifyAll(player:Name().." is changing the map to "..sNewMap.." in five seconds!")

		timer.Simple(tonumber(arguments[2]) or 5, function()
			hook.Run("PreSaveData")
				hook.Run("SaveData")
			hook.Run("PostSaveData")

			hook.Run("OnMapChange", sNewMap)

			RunConsoleCommand("changelevel", sNewMap)
		end)
	else
		cw.player:Notify(player, sNewMap.." is not a valid map!")
	end
end

COMMAND:Register();
