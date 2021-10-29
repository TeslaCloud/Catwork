--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("PKModeOn")
COMMAND.tip = "#Command_Pkmodeon_Description"
COMMAND.text = "#Command_Pkmodeon_Syntax"
COMMAND.access = "o"
COMMAND.arguments = 1

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local minutes = tonumber(arguments[1])

	if (minutes and minutes > 0) then
		netvars.SetNetVar("PKMode", 1)
		timer.Create("pk_mode", minutes * 60, 1, function()
			netvars.SetNetVar("PKMode", 0)

			cw.player:NotifyAll("Perma-kill mode has been turned off, you are safe now.")
		end)

		cw.player:NotifyAll(player:Name().." has turned on perma-kill mode for "..minutes.." minute(s), try not to be killed.")
	else
		cw.player:Notify(player, "This is not a valid amount of minutes!")
	end
end

COMMAND:Register();
