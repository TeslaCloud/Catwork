COMMAND = cw.command:New("CharGetDisease")
COMMAND.tip = "Get a players disease."
COMMAND.text = "<string Name>"
COMMAND.flags = CMD_DEFAULT
COMMAND.access = "a"
COMMAND.arguments = 1

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = _player.Find(arguments[1])
	
	if (target) then
		cw.player:Notify(player, target:GetCharacterData("diseases"))
	else
		cw.player:Notify(player, arguments[1].." is not a valid player!")
	end
end

COMMAND:Register()