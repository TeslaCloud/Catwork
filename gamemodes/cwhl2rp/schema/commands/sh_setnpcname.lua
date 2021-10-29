--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("SetNPCName")
COMMAND.tip = "#Command_Setnpcname_Description"
COMMAND.text = "#Command_Setnpcname_Syntax"
COMMAND.flags = CMD_DEFAULT
COMMAND.access = "o"
COMMAND.arguments = 2

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local trace = player:GetEyeTraceNoCursor()
	local target = trace.Entity

	if (target and target:IsNPC()) then
		if (trace.HitPos:Distance(player:GetShootPos()) <= 192) then
			target:SetNWString("cw_Name", arguments[1])
			target:SetNWString("cw_Title", arguments[2])
		else
			cw.player:Notify(player, "This NPC is too far away!")
		end
	else
		cw.player:Notify(player, "You must look at an NPC!")
	end
end

COMMAND:Register();
