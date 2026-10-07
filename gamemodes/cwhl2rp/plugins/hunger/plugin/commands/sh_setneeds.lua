local PLUGIN = PLUGIN

local COMMAND = cw.command:New("CharResetNeeds")
COMMAND.tip = "#Command_Charresetneeds_Description"
COMMAND.text = "#Command_Charresetneeds_Syntax"
COMMAND.flags = CMD_DEFAULT
COMMAND.access = "a"
COMMAND.arguments = 1
COMMAND.alias = {"ResetNeeds"}

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = _player.Find(arguments[1])
	
	if (target) then
		if (!Schema:PlayerIsCombine(target)) then
			target:SetCharacterData("Hunger", 100)
			target:SetCharacterData("Thirst", 100)
			target:SetCharacterData("Fatigue", 0)
			target:SetCharacterData("Stamina", 100)
			
			if (player != target)	then
				cw.player:Notify(target, L("Hunger_NeedsSetBy", player:Name()))
				cw.player:Notify(player, L("Hunger_NeedsSet", target:Name()))
			else
				cw.player:Notify(player, L("Hunger_NeedsSetOwn"))
			end
		else
			cw.player:Notify(player, L("Hunger_PlayerIsCombine"))
		end
	else
		cw.player:Notify(player, L("NotValidPlayer", arguments[1]))
	end
end

COMMAND:Register();
