--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

ITEM.name = 'Small Bag'
ITEM.PrintName = '#ITEM_Small_Bag'
ITEM.model = 'models/props_junk/garbage_bag001a.mdl'
ITEM.weight = 0.5
ITEM.category = 'Storage'
ITEM.isRareItem = false
ITEM.description = '#ITEM_Small_Bag_Desc'
ITEM.addInvSpace = 4

--- Drops the bag as a `boxed_bag` item entity.
-- @return [Entity The spawned item entity]
function ITEM:OnCreateDropEntity(player, position)
  return cw.entity:CreateItem(player, item.CreateInstance('boxed_bag'), position)
end

--- Blocks taking the bag from storage when its owner would be left over their weight limit
-- or the player already carries two small bags.
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

  if player:HasItemByID(self.uniqueID) and table.Count(player:GetItemsByID(self.uniqueID)) >= 2 then
    return false
  end
end

--- Always allows the bag to be picked up.
function ITEM:CanPickup(player, quickUse, itemEntity)
  return 'boxed_backpack'
end

--- Blocks dropping the bag, with a notification, when the player would be left over their weight limit.
function ITEM:OnDrop(player, position)
  if player:GetInventoryWeight() > (player:GetMaxWeight() - self.addInvSpace) then
    cw.player:Notify(player, L('Item_Bag_CantDropWithItems'))

    return false
  end
end
