COMMAND = cw.command:New("CharSetDisease")
COMMAND.tip = "#Command_Charsetdisease_Description"
COMMAND.text = "#Command_Charsetdisease_Syntax"
COMMAND.flags = CMD_DEFAULT
COMMAND.access = "a"
COMMAND.arguments = 2

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = _player.Find(arguments[1])
	local disease = arguments[2]
	
	if (target) then
		if (player != target)	then
			cw.player:Notify(target, L("Diseases_SetByOther", player:Name(), disease))
			cw.player:Notify(player, L("Diseases_SetOther", target:Name(), disease))
		else
			cw.player:Notify(player, L("Diseases_SetSelf", disease))
		end

		target:SetCharacterData("diseases", disease)
	else
		cw.player:Notify(player, L("NotValidPlayer", arguments[1]))
	end
end

COMMAND:Register()