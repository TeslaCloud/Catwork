--- Defines the Minimal Tier Ration Packet item (`ration_minimal`), which is opened for 20 tokens and citizen
-- supplements and fires the `PlayerUseRation` hook.

ITEM.name = 'Minimal Tier Ration Packet'
ITEM.PrintName = '#ITEM_Minimal_Tier_Ration_Packet'
ITEM.uniqueID = 'ration_minimal'
ITEM.model = 'models/weapons/w_packati.mdl'
ITEM.weight = 1
ITEM.useText = 'Open'
ITEM.description = '#ITEM_Minimal_Tier_Ration_Packet_Desc'

--- Blocks quick-use pickup, with a notification, when the player cannot carry the ration.
function ITEM:CanPickup(player, quickUse, itemEntity)
  if quickUse then
    if !player:CanHoldWeight(self.weight) then
      cw.player:Notify(player, L('NoSpace'))

      return false
    end
  end
end

--- Pays the player 20 tokens and gives them citizen supplements.
--
-- Fires the `PlayerUseRation` hook.
function ITEM:OnUse(player, itemEntity)
  cw.player:GiveCash(player, 20, L('Item_Ration_CashReason'))

  player:GiveItem(item.CreateInstance('citizen_supplements'), true)

  hook.Run('PlayerUseRation', player)
end

--- Lets the item be dropped; nothing else happens.
function ITEM:OnDrop(player, position) end
