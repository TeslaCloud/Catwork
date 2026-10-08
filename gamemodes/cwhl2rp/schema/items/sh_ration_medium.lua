--- Defines the Loyalist Tier Ration Packet item (`ration_medium`), which is opened for 75 tokens, citizen supplements
-- and a special Breen's water and fires the `PlayerUseRation` hook.

ITEM.name = 'Loyalist Tier Ration Packet'
ITEM.PrintName = '#ITEM_Loyalist_Tier_Ration_Packet'
ITEM.uniqueID = 'ration_medium'
ITEM.model = 'models/weapons/w_packatl.mdl'
ITEM.weight = 1.44
ITEM.useText = 'Open'
ITEM.description = '#ITEM_Loyalist_Tier_Ration_Packet_Desc'

--- Blocks quick-use pickup, with a notification, when the player cannot carry the ration.
function ITEM:CanPickup(player, quickUse, itemEntity)
  if quickUse then
    if !player:CanHoldWeight(self.weight) then
      cw.player:Notify(player, L('NoSpace'))

      return false
    end
  end
end

--- Pays the player 75 tokens and gives them citizen supplements and a special Breen's water.
--
-- Fires the `PlayerUseRation` hook.
function ITEM:OnUse(player, itemEntity)
  cw.player:GiveCash(player, 75, L('Item_Ration_CashReason'))

  player:GiveItem(item.CreateInstance('citizen_supplements'), true)
  player:GiveItem(item.CreateInstance('special_breens_water'), true)

  hook.Run('PlayerUseRation', player)
end

--- Lets the item be dropped; nothing else happens.
function ITEM:OnDrop(player, position) end
