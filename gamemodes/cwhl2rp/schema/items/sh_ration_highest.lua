--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

ITEM.name = 'Highest Tier Ration Packet'
ITEM.PrintName = '#ITEM_Highest_Tier_Ration_Packet'
ITEM.uniqueID = 'ration_highest'
ITEM.model = 'models/weapons/w_packatp.mdl'
ITEM.weight = 1.95
ITEM.useText = 'Open'
ITEM.description = '#ITEM_Highest_Tier_Ration_Packet_Desc'

--- Blocks quick-use pickup, with a notification, when the player cannot carry the ration.
function ITEM:CanPickup(player, quickUse, itemEntity)
  if quickUse then
    if !player:CanHoldWeight(self.weight) then
      cw.player:Notify(player, L('NoSpace'))

      return false
    end
  end
end

--- Pays the player 150 tokens and gives them two premium supplements and two special Breen's waters.
--
-- Fires the `PlayerUseRation` hook.
function ITEM:OnUse(player, itemEntity)
  cw.player:GiveCash(player, 150, L('Item_Ration_CashReason'))

  player:GiveItem(item.CreateInstance('premium_supplements'), true)
  player:GiveItem(item.CreateInstance('premium_supplements'), true)
  player:GiveItem(item.CreateInstance('special_breens_water'), true)
  player:GiveItem(item.CreateInstance('special_breens_water'), true)

  hook.Run('PlayerUseRation', player)
end

--- Lets the item be dropped; nothing else happens.
function ITEM:OnDrop(player, position) end
