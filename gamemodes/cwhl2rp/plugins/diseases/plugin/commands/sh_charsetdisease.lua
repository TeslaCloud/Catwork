COMMAND = cw.command:New("CharSetDisease")
COMMAND.tip = "Set a players disease."
COMMAND.text = "<string Name> <String Disease>"
COMMAND.flags = CMD_DEFAULT
COMMAND.access = "a"
COMMAND.arguments = 2

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = _player.Find(arguments[1])
	local disease = arguments[2]
	
	if (target) then
		if (player != target)	then
			cw.player:Notify(target, player:Name().." has set your disease to "..disease..".")
			cw.player:Notify(player, "You have set "..target:Name().."'s disease to "..disease..".")
		else
			cw.player:Notify(player, "You have set your own disease to "..disease..".")
		end

		target:SetCharacterData("diseases", disease)
	else
		cw.player:Notify(player, arguments[1].." is not a valid player!")
	end
end

COMMAND:Register()