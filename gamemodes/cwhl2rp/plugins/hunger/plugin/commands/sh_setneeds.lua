local PLUGIN = PLUGIN

local COMMAND = cw.command:New("CharResetNeeds")
COMMAND.tip = "Set a player's Needs level to 100."
COMMAND.text = "<string Name>"
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
				cw.player:Notify(target, player:Name().." has set your needs to full.")
				cw.player:Notify(player, "You have set "..target:Name().."'s needs to full.")
			else
				cw.player:Notify(player, "You have set your own needs to full.")
			end
		else
			cw.player:Notify(player, "Player a combine!")
		end
	else
		cw.player:Notify(player, arguments[1].." is not a valid player!")
	end
end

COMMAND:Register();
