COMMAND = cw.command:New("KarmaSet")
COMMAND.tip = "Set players karma."
COMMAND.text = "<string Name> <number Value>"
COMMAND.flags = CMD_DEFAULT
COMMAND.access = "o"
COMMAND.arguments = 2
COMMAND.alias = {"CharSetKarma", "SetKarma"}

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = _player.Find(arguments[1])
	local karma = tonumber(arguments[2])

	if (target) then
		if (karma and karma <= 100 and karma >= -100) then
			target:SetKarma(karma)
			cw.player:Notify(player, "Вы установили карму "..target:Name().." на "..karma..".")
		else
			cw.player:Notify(player, "Вы указали неверный уровень кармы.")
		end
	else
		cw.player:Notify(player, arguments[1].." is not a valid player!")
	end
end

COMMAND:Register()