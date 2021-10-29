--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

-- A function to load the cash.
function cwSaveCash:LoadCash()
	local cash = cw.core:RestoreSchemaData("plugins/cash/"..game.GetMap())

	for k, v in pairs(cash) do
		local entity = cw.entity:CreateCash({key = v.key, uniqueID = v.uniqueID}, v.amount, v.position, v.angles)

		if (IsValid(entity) and !v.isMoveable) then
			local physicsObject = entity:GetPhysicsObject()

			if (IsValid(physicsObject)) then
				physicsObject:EnableMotion(false)
			end
		end
	end
end

-- A function to save the cash.
function cwSaveCash:SaveCash()
	local cash = {}

	for k, v in pairs(ents.FindByClass("cw_cash")) do
		local physicsObject = v:GetPhysicsObject()
		local bMoveable = nil

		if (IsValid(physicsObject)) then
			bMoveable = physicsObject:IsMoveable()
		end

		cash[#cash + 1] = {
			key = cw.entity:QueryProperty(v, "key"),
			angles = v:GetAngles(),
			amount = v.cwAmount,
			uniqueID = cw.entity:QueryProperty(v, "uniqueID"),
			position = v:GetPos(),
			isMoveable = bMoveable
		}
	end

	cw.core:SaveSchemaData("plugins/cash/"..game.GetMap(), cash)
end
