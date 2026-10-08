--- Defines the Backpack storage item, which adds 8 to its carrier's inventory weight limit, is limited to one per
-- player and drops as a `boxed_backpack`.

ITEM.name = 'Backpack'
ITEM.PrintName = '#ITEM_Backpack'
ITEM.model = 'models/props_junk/garbage_bag001a.mdl'
ITEM.weight = 1
ITEM.category = 'Storage'
ITEM.isRareItem = true
ITEM.description = '#ITEM_Backpack_Desc'
ITEM.addInvSpace = 8

--- Drops the backpack as a `boxed_backpack` item entity.
-- @return [Entity The spawned item entity]
function ITEM:OnCreateDropEntity(player, position)
  return cw.entity:CreateItem(player, item.CreateInstance('boxed_backpack'), position)
end

--- Blocks taking the backpack from storage when its owner would be left over their weight limit
-- or the player already carries a backpack.
function ITEM:CanTakeStorage(player, storageTable)
  local target = cw.entity:GetPlayer(storageTable.entity)

  if target then
    local inventoryWeight = cw.inventory:CalculateWeight(
      target:GetInventory()
    )

    if inventoryWeight > (target:GetMaxWeight() - self.addInvSpace) then
      return false
    end
  end

  if player:HasItemByID(self.uniqueID) and table.Count(player:GetItemsByID(self.uniqueID)) >= 1 then
    return false
  end
end

--- Always allows the backpack to be picked up.
function ITEM:CanPickup(player, quickUse, itemEntity)
  return 'boxed_backpack'
end

--- Blocks dropping the backpack, with a notification, when the player would be left over their weight limit.
function ITEM:OnDrop(player, position)
  if player:GetInventoryWeight() > (player:GetMaxWeight() - self.addInvSpace) then
    cw.player:Notify(player, L('Item_Bag_CantDropWithItems'))

    return false
  end
end
