--- Defines the Boxed Bag item, which is opened to give a `small_bag` unless the player already carries two.

ITEM.name = 'Boxed Bag'
ITEM.PrintName = '#ITEM_Boxed_Bag'
ITEM.cost = 15
ITEM.model = 'models/props_junk/cardboard_box004a.mdl'
ITEM.weight = 0.5
ITEM.access = '1v'
ITEM.useText = 'Open'
ITEM.category = 'Storage'
ITEM.business = true
ITEM.description = '#ITEM_Boxed_Bag_Desc'

--- Unpacks into a small bag, or keeps the box with a notification when the player already has two.
function ITEM:OnUse(player, itemEntity)
  if player:HasItemByID('small_bag') and table.Count(player:GetItemsByID('small_bag')) >= 2 then
    cw.player:Notify(player, L('Item_BoxedBag_Limit'))

    return false
  end

  -- Forced: the box it replaces weighs the same and is only taken after this returns.
  player:GiveItem(item.CreateInstance('small_bag'), true)
end

--- Lets the item be dropped; nothing else happens.
function ITEM:OnDrop(player, position) end
