--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("VendorAdd")
COMMAND.tip = "#Command_Vendoradd_Description"
COMMAND.flags = CMD_DEFAULT
COMMAND.access = "a"

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local trace = player:GetEyeTraceNoCursor()
	local entity = ents.Create("cw_vendingmachine")

	entity:SetPos(trace.HitPos + Vector(0, 0, 48))
	entity:Spawn()

	if (IsValid(entity)) then
		entity:SetStock(math.random(10, 20), true)
		entity:SetAngles(Angle(0, player:EyeAngles().yaw + 180, 0))

		cw.player:Notify(player, "You have added a vending machine.")
	end
end

COMMAND:Register();
