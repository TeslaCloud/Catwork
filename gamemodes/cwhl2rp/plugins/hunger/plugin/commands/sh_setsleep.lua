local PLUGIN = PLUGIN

local COMMAND = cw.command:New("CharSetFatigue")
COMMAND.tip = "Set a player's Sleep Level."
COMMAND.text = "<string Name> <number Amount>"
COMMAND.flags = CMD_DEFAULT
COMMAND.access = "a"
COMMAND.arguments = 2
COMMAND.alias = {"SetFatigue", "SetSleep", "CharSetSleep"}

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = _player.Find(arguments[1])
	local amount = arguments[2]

	if (!amount) then
		amount = 100
	end

		if (target) then
			target:SetCharacterData("Fatigue", amount)

			if (player != target)	then
				cw.player:Notify(target, player:Name().." has set your sleep to "..amount..".")
				cw.player:Notify(player, "You have set "..target:Name().."'s sleep to "..amount..".")
			else
				cw.player:Notify(player, "You have set your own sleep to "..amount..".")
			end
		else
			cw.player:Notify(player, arguments[1].." is not a valid player!")
		end
end

COMMAND:Register();