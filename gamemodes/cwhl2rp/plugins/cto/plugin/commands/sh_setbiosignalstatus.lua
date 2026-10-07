local cwCTO = cwCTO

local COMMAND = cw.command:New("SetBiosignalStatus")
COMMAND.tip = "#Command_Setbiosignalstatus_Description"
COMMAND.text = "#Command_Setbiosignalstatus_Syntax"
COMMAND.flags = CMD_DEFAULT
COMMAND.arguments = 1

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local bEnable = cw.core:ToBool(arguments[1])
	local result = cwCTO:SetPlayerBiosignal(player, bEnable)

	if (result == cwCTO.ERROR_NOT_COMBINE) then
		cw.player:Notify(player, L("CTO_NotCombine"))
	elseif (result == cwCTO.ERROR_ALREADY_ENABLED) then
		cw.player:Notify(player, L("CTO_BiosignalAlreadyOn"))
	elseif (result == cwCTO.ERROR_ALREADY_DISABLED) then
		cw.player:Notify(player, L("CTO_BiosignalAlreadyOff"))
	end
end

COMMAND:Register()
