local PLUGIN = PLUGIN

local COMMAND = cw.command:New("CharSetFatigue")
COMMAND.tip = "#Command_Charsetfatigue_Description"
COMMAND.text = "#Command_Charsetfatigue_Syntax"
COMMAND.flags = CMD_DEFAULT
COMMAND.access = "a"
COMMAND.arguments = 2
COMMAND.alias = { "SetFatigue", "SetSleep", "CharSetSleep" }

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = _player.Find(arguments[1])
	local amount = arguments[2]

	if (!amount) then
		amount = 100
	end

	if (target) then
		target:SetCharacterData("Fatigue", amount)

		if (player != target) then
			cw.player:Notify(target, L("Hunger_SleepSetBy", player:Name(), amount))
			cw.player:Notify(player, L("Hunger_SleepSet", target:Name(), amount))
		else
			cw.player:Notify(player, L("Hunger_SleepSetOwn", amount))
		end
	else
		cw.player:Notify(player, L("NotValidPlayer", arguments[1]))
	end
end

COMMAND:Register()
