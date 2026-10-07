COMMAND = cw.command:New("KarmaAdd")
COMMAND.tip = "#Command_Karmaadd_Description"
COMMAND.text = "#Command_Karmaadd_Syntax"
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
			cw.player:Notify(player, L("Karma_SetTo", target:Name(), target:GetCharacterData("karma")))
		else
			cw.player:Notify(player, L("Karma_InvalidLevel"))
		end
	else
		cw.player:Notify(player, L("NotValidPlayer", arguments[1]))
	end
end

COMMAND:Register()