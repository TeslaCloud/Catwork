--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

function cwGarbage:ClockworkInitPostEntity()
	self:LoadGarbageSpawnPoints()
end

function cwGarbage:OneSecond()
	local curTime = CurTime()

	for k, v in pairs(self.garbagePoints) do
		if (v and curTime > v.nextSpawn) then
			if (hook.Run("CanSpawnGarbage", v.position)) then
				self:SpawnGarbage(v)
				v.nextSpawn = curTime + math.Round(config.GetVal("garbage_respawn_delay"))
			end
		end
	end
end

function cwGarbage:CanSpawnGarbage(position)
	local entities = ents.FindInSphere(position, 50)

	if (entities) then
		for k, v in ipairs(entities) do
			if (IsValid(v) and v:GetClass() == "cw_garbage") then
				return false
			end
		end
	end

	return true
end

function cwGarbage:GetGarbageTime(player)
	return config.GetVal("garbage_pickup_time") - math.Round((cw.attributes:Get(player, ATB_SCAVENGER, nil, true) or 0) / 10)
end

function cwGarbage:PlayerTakeGarbage(player, entity)
	for k, v in ipairs(self.garbagePoints) do
		if (v.position:Distance(entity:GetPos()) <= 10) then
			v.nextSpawn = CurTime() + math.Round(config.GetVal("garbage_respawn_delay"))
		end
	end

	local chosenEnt = self.stored[math.random(1, #self.stored)]
	local chance = math.random(1, 100) - cw.attributes:Get(player, ATB_SCAVENGER, nil, true)

	local roll, roll2, roll3 = math.random(0, 100), math.random(0, 100), math.random(0, 100)

	if (roll == 1 and roll2 == 55 and roll3 == 78) then
		chosenEnt = {"weapon_rpg", 100}
	elseif (roll == 74 and roll2 == 22 and roll3 == 40) then
		chosenEnt = math.random(200, 1500)
	elseif (roll == 33 and roll2 == 78 and roll3 == 0 and math.random(0, 100) == 99) then
		for i = 1, 10 do
			local itemTable = item.CreateInstance("weapon_rpg")

			local success, value = player:GiveItem(itemTable, true)
		end

		cw.player:Notify(player, "Динь динь динь, джекпот! 10x РПГ!")

		return
	end

	if (isnumber(chosenEnt)) then
		cw.player:GiveCash(player, chosenEnt)
	elseif (chance <= config.GetVal("garbage_item_percentage")
	and math.random(0, 100) <= chosenEnt[2]) then
		local itemTable = item.CreateInstance(chosenEnt[1])

		local success, value = player:GiveItem(itemTable)

		if (success) then
			if (chosenEnt[1] == "weapon_rpg") then
				cw.player:Notify(player, "Вы нашли РПГ. Надо же что люди в мусор то кидают.")

				return
			end

			cw.player:Notify(player, "Вы нашли: "..itemTable.PrintName..".")
		else
			cw.player:Notify(player, value)
		end
	else
		cw.player:Notify(player, "Вы ничего не нашли.")
	end

	player:ProgressAttribute(ATB_SCAVENGER, 5, true)
end
