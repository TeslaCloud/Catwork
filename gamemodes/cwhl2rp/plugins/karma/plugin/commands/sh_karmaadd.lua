COMMAND = cw.command:New("KarmaAdd")
COMMAND.tip = "Add players karma."
COMMAND.text = "<string Name> <number Value>"
COMMAND.flags = CMD_DEFAULT
COMMAND.access = "o"
COMMAND.arguments = 2
COMMAND.alias = {"CharAddKarma", "AddKarma"}

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = _player.Find(arguments[1])
	local karma = tonumber(arguments[2])

	if (target) then
		if (karma and karma <= 100 and karma > 0) then
			target:SetKarma(target:GetCharacterData("karma") + karma)
			cw.player:Notify(player, "Вы установили карму "..target:Name().." на "..target:GetCharacterData("karma")..".")
		else
			cw.player:Notify(player, "Вы указали неверный уровень кармы.")
		end
	else
		cw.player:Notify(player, arguments[1].." is not a valid player!")
	end
end

COMMAND:Register()