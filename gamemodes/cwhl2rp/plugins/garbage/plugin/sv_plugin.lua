--[[
	Catwork � 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

config.Add("garbage_respawn_delay", 400)
config.Add("garbage_pickup_time", 20, true)
config.Add("garbage_item_percentage", 30)

function cwGarbage:SaveGarbageSpawnPoints()
	cw.core:SaveSchemaData("plugins/garbage/"..game.GetMap(), self.garbagePoints)
end

function cwGarbage:LoadGarbageSpawnPoints()
	self.garbagePoints = cw.core:RestoreSchemaData("plugins/garbage/"..game.GetMap())

	if (!self.garbagePoints) then
		self.garbagePoints = {}
	end

	for k, v in pairs(self.garbagePoints) do
		v.nextSpawn = 0
	end
end

function cwGarbage:SpawnGarbage(pointTable)
	local entity = ents.Create("cw_garbage")

	entity:SetPos(pointTable.position)
	entity:Spawn()

	if (IsValid(entity)) then
		entity:SetAngles(pointTable.angles)
	end
end

function cwGarbage:AddItem(id, chance)
	table.insert(self.stored, {id, chance})
end

do
	cwGarbage:AddItem("bleach", 100)
	cwGarbage:AddItem("flashlight", 50)
	cwGarbage:AddItem("chinese_takeout", 75)
	cwGarbage:AddItem("breens_water", 80)
	cwGarbage:AddItem("broken_shotgun", 2)
	cwGarbage:AddItem("zip_tie", 10)
	cwGarbage:AddItem("broken_pistol", 2)
	cwGarbage:AddItem("broken_mp7", 1)
	cwGarbage:AddItem("broken_357", 1)
	cwGarbage:AddItem("broken_m1911", 1)
	cwGarbage:AddItem("broken_mp5k", 1)
	cwGarbage:AddItem("broken_ak74", 1)
	cwGarbage:AddItem("broken_m9", 2)
	cwGarbage:AddItem("box_of_bolts", 45)
	cwGarbage:AddItem("box_of_screws", 45)
	cwGarbage:AddItem("bullet_casings", 20)
	cwGarbage:AddItem("cables", 60)
	cwGarbage:AddItem("car_battery", 20)
	cwGarbage:AddItem("empty_carton", 200)
	cwGarbage:AddItem("empty_soda_can", 200)
	cwGarbage:AddItem("empty_tin_can", 200)
	cwGarbage:AddItem("empty_plastic_bottle", 200)
	cwGarbage:AddItem("empty_jug", 200)
	cwGarbage:AddItem("empty_glass_bottle", 200)
	cwGarbage:AddItem("empty_cup", 200)
	cwGarbage:AddItem("empty_takeout_carton", 200)
	cwGarbage:AddItem("seed_banana", 90)
	cwGarbage:AddItem("seed_corn", 90)
	cwGarbage:AddItem("seed_melon", 90)
	cwGarbage:AddItem("seed_orange", 90)
	cwGarbage:AddItem("seed_potato", 90)
	cwGarbage:AddItem("seed_tomato", 90)
	cwGarbage:AddItem("seed_weed", 90)
	cwGarbage:AddItem("plastic", 80)
	cwGarbage:AddItem("cloth", 80)
	cwGarbage:AddItem("sulphur", 80)
	cwGarbage:AddItem("selitra", 80)
	cwGarbage:AddItem("wooden_parts", 80)
	cwGarbage:AddItem("gunpowder", 20)
	cwGarbage:AddItem("scrap_electronics", 90)
	cwGarbage:AddItem("scrap_metal", 35)
	cwGarbage:AddItem("reclaimed_metal", 20)
	cwGarbage:AddItem("refined_metal", 15)
end
