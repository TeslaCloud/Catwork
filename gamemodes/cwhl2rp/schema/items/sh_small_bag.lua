--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

ITEM.name = "Small Bag"
ITEM.PrintName = "#ITEM_Small_Bag"
ITEM.model = "models/props_junk/garbage_bag001a.mdl"
ITEM.weight = 0.5
ITEM.category = "Storage"
ITEM.isRareItem = false
ITEM.description = "#ITEM_Small_Bag_Desc"
ITEM.addInvSpace = 4

-- Called when the item's drop entity should be created.
function ITEM:OnCreateDropEntity(player, position)
	return cw.entity:CreateItem(player, item.CreateInstance("boxed_bag"), position)
end

-- Called when a player attempts to take the item from storage.
function ITEM:CanTakeStorage(player, storageTable)
	local target = cw.entity:GetPlayer(storageTable.entity)

	if (target) then
		local inventoryWeight = cw.inventory:CalculateWeight(
			target:GetInventory()
		)

		if (inventoryWeight > (target:GetMaxWeight() - self.addInvSpace)) then
			return false
		end
	end

	if (player:HasItemByID(self.uniqueID) and table.Count(player:GetItemsByID(self.uniqueID)) >= 2) then
		return false
	end
end

-- Called when a player attempts to pick up the item.
function ITEM:CanPickup(player, quickUse, itemEntity)
	return "boxed_backpack"
end

-- Called when a player drops the item.
function ITEM:OnDrop(player, position)
	if (player:GetInventoryWeight() > (player:GetMaxWeight() - self.addInvSpace)) then
		cw.player:Notify(player, "You cannot drop this while you are carrying items in it!")

		return false
	end
end
