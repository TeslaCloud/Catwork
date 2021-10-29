--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("MapRestart")
COMMAND.tip = "#Command_Maprestart_Description"
COMMAND.text = "#Command_Maprestart_Syntax"
COMMAND.access = "a"
COMMAND.optionalArguments = 1
COMMAND.alias = {"Restart"}

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local delay = tonumber(arguments[1]) or 10

	if (isnumber(arguments[1])) then
		delay = arguments[1]
	end

	cw.player:NotifyAll(player:Name().." is restarting the map in "..delay.." seconds!")

	timer.Simple(delay, function()
		hook.Run("PreSaveData")
			hook.Run("SaveData")
		hook.Run("PostSaveData")

		hook.Run("OnMapChange", game.GetMap())

		RunConsoleCommand("changelevel", game.GetMap())
	end)
end

COMMAND:Register();
