--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

-- Called when a player attempts to breach an entity.
function cwStorage:PlayerCanBreachEntity(player, entity)
	if (entity.cwInventory and entity.cwPassword) then
		return true
	end
end

-- Called when an entity attempts to be auto-removed.
function cwStorage:EntityCanAutoRemove(entity)
	if (self.storage[entity] or entity:GetNetworkedString("Name") != "") then
		return false
	end
end

-- Called when an entity's menu option should be handled.
function cwStorage:EntityHandleMenuOption(player, entity, option, arguments)
	local class = entity:GetClass()

	if (class == "cw_locker" and arguments == "cwContainerOpen") then
		self:OpenContainer(player, entity)
	elseif (arguments == "cwContainerOpen") then
		if (cw.entity:IsPhysicsEntity(entity)) then
			local model = string.lower(entity:GetModel())

			if (self.containerList[model]) then
				local containerWeight = self.containerList[model][1]

				if (!entity.cwPassword or entity.cwIsBreached) then
					self:OpenContainer(player, entity, containerWeight)
				else
					netstream.Start(player, "ContainerPassword", entity)
				end
			end
		end
	end
end

-- Called when an entity has been breached.
function cwStorage:EntityBreached(entity, activator)
	if (entity.cwInventory and entity.cwPassword) then
		entity.cwIsBreached = true

		timer.Create("ResetBreach"..entity:EntIndex(), 120, 1, function()
			if (IsValid(entity)) then
				entity.cwIsBreached = nil
			end
		end)
	end
end

-- Called when an entity is removed.
function cwStorage:EntityRemoved(entity)
	if (IsValid(entity) and !entity.cwIsBelongings) then
		cw.entity:DropItemsAndCash(entity.cwInventory, entity.cwCash, entity:GetPos(), entity)
		entity.cwInventory = nil
		entity.cwCash = nil
	end
end

-- Called when a player's prop cost info should be adjusted.
function cwStorage:PlayerAdjustPropCostInfo(player, entity, info)
	local model = string.lower(entity:GetModel())

	if (self.containerList[model]) then
		info.name = self.containerList[model][2]
	end
end
