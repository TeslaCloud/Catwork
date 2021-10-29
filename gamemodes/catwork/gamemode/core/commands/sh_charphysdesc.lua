--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("CharPhysDesc")
COMMAND.tip = "#Command_Charphysdesc_Description"
COMMAND.text = "#Command_Charphysdesc_Syntax"
COMMAND.flags = CMD_DEFAULT
COMMAND.arguments = 0
COMMAND.alias = {"PhysDesc", "ChangeDesc", "ChangeDescription"}

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local minimumPhysDesc = config.GetVal("minimum_physdesc")

	if (arguments[1]) then
		local text = table.concat(arguments, " ")

		if (string.utf8len(text) < minimumPhysDesc) then
			cw.player:Notify(player, "The physical description must be at least "..minimumPhysDesc.." characters long!")
			return
		end

		player:SetCharacterData("PhysDesc", cw.core:ModifyPhysDesc(text))
	else
		cw.dermaRequest:RequestString(player, "Physical Description Change", "What do you want to change your physical description to?", player:GetDTString(STRING_PHYSDESC), function(result)
			player:RunClockworkCmd(self.name, result)
		end)
	end
end

COMMAND:Register();
