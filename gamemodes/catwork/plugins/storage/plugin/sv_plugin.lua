--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

cwStorage.storage = cwStorage.storage or {}

netstream.Hook("ContainerPassword", function(player, data)
	local password = data[1]
	local entity = data[2]

	if (IsValid(entity) and cw.entity:IsPhysicsEntity(entity)) then
		local model = string.lower(entity:GetModel())

		if (cwStorage.containerList[model]) then
			local containerWeight = cwStorage.containerList[model][1]

			if (entity.cwPassword == password) then
				cwStorage:OpenContainer(player, entity, containerWeight)
			else
				cw.player:Notify(player, "Вы ввели неверный пароль!")
			end
		end
	end
end)

-- A function to get a random item.
function cwStorage:GetRandomItem(uniqueID)
	if (uniqueID) then
		uniqueID = string.lower(uniqueID)
	end

	if (#self.randomItems <= 0) then
		return
	end

	local randomItem = self.randomItems[
		math.random(1, #self.randomItems)
	]

	if (randomItem) then
		local itemTable = item.FindByID(randomItem[1])

		if (!uniqueID or string.find(string.lower(itemTable.category), uniqueID)) then
			return randomItem
		end
	end

	return self:GetRandomItem(uniqueID, runs)
end

function cwStorage:CategoryExists(uniqueID)
	if (uniqueID) then
		local uniqueID = string.lower(uniqueID)

		for i = 1, #self.randomItems do
			local itemTable = item.FindByID(self.randomItems[i][1])

			if (string.find(string.lower(itemTable.category), uniqueID)) then
				return true
			end
		end

		return false
	else
		return false
	end
end

-- Saving and loading are now handled by Static Entities plugin.
function cwStorage:SaveStorage() end
function cwStorage:LoadStorage() end

-- A function to open a container for a player.
function cwStorage:OpenContainer(player, entity, weight)
	local inventory
	local cash = 0
	local model = string.lower(entity:GetModel())
	local name = ""

	if (!entity.cwInventory) then
		self.storage[entity] = entity

		entity.cwInventory = {}
	end

	if (!entity.cwCash) then
		entity.cwCash = 0
	end

	if (self.containerList[model]) then
		name = self.containerList[model][2]
	else
		name = "Контейнер"
	end

	inventory = entity.cwInventory
	cash = entity.cwCash

	if (!weight) then
		weight = 8
	end

	if (entity:GetNetworkedString("Name") != "") then
		name = entity:GetNetworkedString("Name")
	end

	if (entity.cwMessage) then
		netstream.Start(player, "StorageMessage", {
			entity = entity, message = entity.cwMessage
		})
	end

	cw.storage:Open(player, {
		name = name,
		weight = weight,
		entity = entity,
		distance = 192,
		cash = cash,
		inventory = inventory,
		OnGiveCash = function(player, storageTable, cash)
			storageTable.entity.cwCash = storageTable.cash
		end,
		OnTakeCash = function(player, storageTable, cash)
			storageTable.entity.cwCash = storageTable.cash
		end
	})
end
