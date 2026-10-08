--- Defines the Boxed Backpack item, which is opened to give a `backpack` unless the player already carries one.

ITEM.name = 'Boxed Backpack'
ITEM.PrintName = '#ITEM_Boxed_Backpack'
ITEM.cost = 25
ITEM.model = 'models/props_junk/cardboard_box004a.mdl'
ITEM.weight = 1
ITEM.access = '1v'
ITEM.useText = 'Open'
ITEM.category = 'Storage'
ITEM.business = true
ITEM.description = '#ITEM_Boxed_Backpack_Desc'

--- Unpacks into a backpack, or keeps the box with a notification when the player already has one.
function ITEM:OnUse(player, itemEntity)
  if player:HasItemByID('backpack') and table.Count(player:GetItemsByID('backpack')) >= 1 then
    cw.player:Notify(player, L('Item_BoxedBackpack_Limit'))

    return false
  end

  player:GiveItem(item.CreateInstance('backpack'))
end

--- Lets the item be dropped; nothing else happens.
function ITEM:OnDrop(player, position) end
