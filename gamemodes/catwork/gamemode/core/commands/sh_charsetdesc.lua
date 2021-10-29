--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("CharSetDesc")
COMMAND.tip = "#Command_Charsetdesc_Description"
COMMAND.text = "#Command_Charsetdesc_Syntax"
COMMAND.access = "o"
COMMAND.arguments = 1
COMMAND.optionalArguments = 1
COMMAND.alias = {"SetDescription", "SetDesc"}

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = _player.Find(arguments[1])
	local minimumPhysDesc = config.GetVal("minimum_physdesc")
	local text = arguments[2]

	if (target) then
		if (text and text != "") then
			if (string.utf8len(text) < minimumPhysDesc) then
				cw.player:Notify(player, "The physical description must be at least "..minimumPhysDesc.." characters long!")
				return
			end

			local physDesc = cw.core:ModifyPhysDesc(text)

			target:SetCharacterData("PhysDesc", physDesc)

			cw.player:Notify(player, target:Name().."'s physical description has been changed to \'"..physDesc.."\'")
		else
			cw.dermaRequest:RequestString(player, "Physical Description Change", "What do you want to change the player's physical description to?", target:GetDTString(STRING_PHYSDESC), function(result)
				player:RunClockworkCmd(self.name, target:Name(), result)
			end)
		end
	else
		cw.player:Notify(player, L(player, "NotValidCharacter", arguments[1]))
	end
end

COMMAND:Register()
