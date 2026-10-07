local cwCTO = cwCTO

local COMMAND = cw.command:New("CharSetBiosignalStatus")
COMMAND.tip = "#Command_Charsetbiosignalstatus_Description"
COMMAND.text = "#Command_Charsetbiosignalstatus_Syntax"
COMMAND.access = "o"
COMMAND.flags = CMD_DEFAULT
COMMAND.arguments = 2

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local ply = _player.Find(arguments[1])
	local bEnable = cw.core:ToBool(arguments[2])
	local result = cwCTO:SetPlayerBiosignal(ply, bEnable)

	if (result == cwCTO.ERROR_NOT_COMBINE) then
		cw.player:Notify(player, L("CTO_CharNotCombine"))
	elseif (result == cwCTO.ERROR_ALREADY_ENABLED) then
		cw.player:Notify(player, L("CTO_CharBiosignalAlreadyOn"))
	elseif (result == cwCTO.ERROR_ALREADY_DISABLED) then
		cw.player:Notify(player, L("CTO_CharBiosignalAlreadyOff"))
	end
end

COMMAND:Register()
