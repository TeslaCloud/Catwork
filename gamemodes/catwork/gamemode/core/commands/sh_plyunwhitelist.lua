--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("PlyUnwhitelist")
COMMAND.tip = "#Command_Plyunwhitelist_Description"
COMMAND.text = "#Command_Plyunwhitelist_Syntax"
COMMAND.access = "sW"
COMMAND.arguments = 2
COMMAND.alias = {"UnWhitelist", "DeWhitelist"}

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = _player.Find(arguments[1])

	if (target) then
		local factionTable = faction.FindByID(table.concat(arguments, " ", 2))

		if (factionTable) then
			if (factionTable.whitelist) then
				if (cw.player:IsWhitelisted(target, factionTable.name)) then
					cw.player:SetWhitelisted(target, factionTable.name, false)
					cw.player:SaveCharacter(target)

					cw.player:NotifyAll(player:Name().." has removed "..target:Name().." from the "..factionTable.name.." whitelist.")
				else
					cw.player:Notify(player, target:Name().." is not on the "..factionTable.name.." whitelist!")
				end
			else
				cw.player:Notify(player, factionTable.name.." does not have a whitelist!")
			end
		else
			cw.player:Notify(player, factionTable.name.." is not a valid faction!")
		end
	else
		cw.player:Notify(player, arguments[1].." is not a valid player!")
	end
end

COMMAND:Register();
