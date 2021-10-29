COMMAND = cw.command:New("KarmaGet")
COMMAND.tip = "Get players karma."
COMMAND.text = "<string Name>"
COMMAND.flags = CMD_DEFAULT
COMMAND.access = "o"
COMMAND.arguments = 1
COMMAND.alias = {"CharGetKarma", "GetKarma"}

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = _player.Find(arguments[1])
	
	if (target) then
		cw.player:Notify(player, target:GetKarmaLevel().." ("..target:GetCharacterData("karma", 0)..")")
	else
		cw.player:Notify(player, arguments[1].." is not a valid player!")
	end
end

COMMAND:Register()