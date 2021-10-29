--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

library.New("storage", cw)

-- A function to get whether storage is open.
function cw.storage:IsStorageOpen()
	local panel = self:GetPanel()

	if (IsValid(panel) and panel:IsVisible()) then
		return true
	end
end

-- A function to get whether the local player can give to storage.
function cw.storage:CanGiveTo(itemTable)
	local entity = cw.storage:GetEntity()
	local isPlayer = (entity and entity:IsPlayer())

	if (itemTable) then
		local bAllowPlayerStorage = (!isPlayer or itemTable.allowPlayerStorage != false)
		local bAllowEntityStorage = (isPlayer or itemTable.allowEntityStorage != false)
		local bAllowPlayerGive = (!isPlayer or itemTable.allowPlayerGive != false)
		local bAllowEntityGive = (isPlayer or itemTable.allowEntityGive != false)
		local bAllowStorage = (itemTable.allowStorage != false)
		local bIsShipment = (entity and entity:GetClass() == "cw_shipment")
		local bAllowGive = (itemTable.allowGive != false)

		if (bIsShipment or (bAllowPlayerStorage and bAllowPlayerGive
		and bAllowEntityStorage and bAllowStorage and bAllowGive
		and bAllowEntityGive)) then
			return true
		end
	end
end

-- A function to get whether the local player can take from storage.
function cw.storage:CanTakeFrom(itemTable)
	local entity = cw.storage:GetEntity()
	local isPlayer = (entity and entity:IsPlayer())

	if (itemTable) then
		local bAllowPlayerStorage = (!isPlayer or itemTable.allowPlayerStorage != false)
		local bAllowEntityStorage = (isPlayer or itemTable.allowEntityStorage != false)
		local bAllowPlayerTake = (!isPlayer or itemTable.allowPlayerTake != false)
		local bAllowEntityTake = (isPlayer or itemTable.allowEntityTake != false)
		local bAllowStorage = (itemTable.allowStorage != false)
		local bIsShipment = (entity and entity:GetClass() == "cw_shipment")
		local bAllowTake = (itemTable.allowTake != false)

		if (bIsShipment or (bAllowPlayerStorage and bAllowPlayerTake
		and bAllowEntityStorage and bAllowStorage and bAllowTake
		and bAllowEntityTake)) then
			return true
		end
	end
end

-- A function to get whether there is no cash weight.
function cw.storage:GetNoCashWeight()
	return self.noCashWeight
end

-- A function to get whether there is no cash space.
function cw.storage:GetNoCashSpace()
	return self.noCashSpace
end

-- A function to get whether the storage is one sided.
function cw.storage:GetIsOneSided()
	return self.isOneSided
end

-- A function to get the storage inventory.
function cw.storage:GetInventory()
	return self.inventory
end

-- A function to get the storage cash.
function cw.storage:GetCash()
	if (config.GetVal("cash_enabled")) then
		return self.cash
	else
		return 0
	end
end

-- A function to get the storage panel.
function cw.storage:GetPanel()
	return self.panel
end

-- A function to get the storage weight.
function cw.storage:GetWeight()
	return self.weight
end

-- A function to get the storage space.
function cw.storage:GetSpace()
	return self.space
end

-- A function to get the storage entity.
function cw.storage:GetEntity()
	return self.entity
end

-- A function to get the storage name.
function cw.storage:GetName()
	return self.name
end
