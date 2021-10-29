local cwCTO = cwCTO

local COMMAND = cw.command:New("SetBiosignalStatus")
COMMAND.tip = "Turn your biosignal on or off. Will alert all other units."
COMMAND.text = "<bool Enabled>"
COMMAND.flags = CMD_DEFAULT
COMMAND.arguments = 1

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local bEnable = cw.core:ToBool(arguments[1])
	local result = cwCTO:SetPlayerBiosignal(player, bEnable)

	if (result == cwCTO.ERROR_NOT_COMBINE) then
		cw.player:Notify(player, "You are not the Combine!")
	elseif (result == cwCTO.ERROR_ALREADY_ENABLED) then
		cw.player:Notify(player, "Your biosignal is already enabled!")
	elseif (result == cwCTO.ERROR_ALREADY_DISABLED) then
		cw.player:Notify(player, "Your biosignal is already disabled!")
	end
end

COMMAND:Register()
