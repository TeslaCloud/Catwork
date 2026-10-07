COMMAND = cw.command:New("CharGetDisease")
COMMAND.tip = "#Command_Chargetdisease_Description"
COMMAND.text = "#Command_Chargetdisease_Syntax"
COMMAND.flags = CMD_DEFAULT
COMMAND.access = "a"
COMMAND.arguments = 1

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = _player.Find(arguments[1])

	if (target) then
		cw.player:Notify(player, target:GetCharacterData("diseases"))
	else
		cw.player:Notify(player, L("NotValidPlayer", arguments[1]))
	end
end

COMMAND:Register()
