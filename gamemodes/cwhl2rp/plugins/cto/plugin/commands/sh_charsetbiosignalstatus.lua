local cwCTO = cwCTO

local COMMAND = cw.command:New("CharSetBiosignalStatus")
COMMAND.tip = "Turn a character's biosignal on or off."
COMMAND.text = "<string Name> <bool Enabled>"
COMMAND.access = "o"
COMMAND.flags = CMD_DEFAULT
COMMAND.arguments = 2

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local ply = _player.Find(arguments[1])
	local bEnable = cw.core:ToBool(arguments[2])
	local result = cwCTO:SetPlayerBiosignal(ply, bEnable)

	if (result == cwCTO.ERROR_NOT_COMBINE) then
		cw.player:Notify(player, "That character is not the Combine!")
	elseif (result == cwCTO.ERROR_ALREADY_ENABLED) then
		cw.player:Notify(player, "That character's biosignal is already enabled!")
	elseif (result == cwCTO.ERROR_ALREADY_DISABLED) then
		cw.player:Notify(player, "That character's biosignal is already disabled!")
	end
end

COMMAND:Register()
