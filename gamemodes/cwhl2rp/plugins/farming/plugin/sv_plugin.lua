--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

function PLUGIN:SavePlants()
	local plants = {}

	for k, v in pairs(ents.FindByClass("cw_plant")) do
		plants[#plants + 1] = {
			angles = v:GetAngles(),
			position = v:GetPos(),
			spawn = v:GetSpawnTime(),
			grow = v:GetGrowTime(),
			item = v:GetItem(),
		}
	end

	cw.core:SaveSchemaData("plugins/farming/"..game.GetMap(), plants)
end

function PLUGIN:LoadPlants()
	local plants = cw.core:RestoreSchemaData("plugins/combinedevices/monitors/"..game.GetMap())

	for k, v in pairs(plants) do
		local plant = ents.Create("cw_plant")

		if plant then
			local itemTable = item.FindByID(v.item)

			plant:SetPos(v.position)
			plant:SetAngles(v.angles)
			plant:SetItem(v.item)
			plant:SetGrowTime(v.grow)
			plant:SetSpawnTime(v.spawn)
			plant:Spawn()
			plant:SetModel(itemTable.PlantModel)			
		end
	end
end
