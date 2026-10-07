--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local COMMAND = cw.command:New("NutVendorAdd")
COMMAND.tip = "#Command_Nutvendoradd_Description"
COMMAND.flags = CMD_DEFAULT
COMMAND.access = "a"

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local trace = player:GetEyeTraceNoCursor()
	--local entity = ents.Create("nut_vend")
	local entity = scripted_ents.Get("nut_vend"):SpawnFunction(player, trace)

	--entity:SetPos(trace.HitPos + Vector(0, 0, 48))
	--entity:SpawnFunction(player, trace)

	if (IsValid(entity)) then
		--entity:SetStock(math.random(10, 20), true)
		--entity:SetAngles(Angle(0, player:EyeAngles().yaw + 180, 0))

		cw.player:Notify(player, L("NutVend_Added"))
	end
end

COMMAND:Register();