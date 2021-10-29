--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("CharPermaKill")
COMMAND.tip = "#Command_Charpermakill_Description"
COMMAND.text = "#Command_Charpermakill_Syntax"
COMMAND.access = "o"
COMMAND.arguments = 1

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = _player.Find(arguments[1])

	if (target) then
		if (!target:GetCharacterData("permakilled")) then
			Schema:PermaKillPlayer(target, target:GetRagdollEntity())
		else
			cw.player:Notify(player, "This character is already permanently killed!")

			return
		end

		cw.player:NotifyAll(player:Name().." permanently killed the character '"..target:Name().."'.")
	else
		cw.player:Notify(player, arguments[1].." is not a valid character!")
	end
end

COMMAND:Register();
