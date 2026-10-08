--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

ITEM.name = 'Breach'
ITEM.PrintName = '#ITEM_Breach'
ITEM.cost = 10
ITEM.model = 'models/props_wasteland/prison_padlock001a.mdl'
ITEM.plural = 'Breaches'
ITEM.weight = 0.5
ITEM.access = 'V'
ITEM.useText = 'Place'
ITEM.business = true
ITEM.blacklist = { CLASS_MPR }
ITEM.description = '#ITEM_Breach_Desc'

--- Attaches a `cw_breach` charge to the entity the player is looking at within 192 units.
--
-- Keeps the item, with a notification, when there is no valid entity, it is too far, it already has a
-- breach or the `PlayerCanBreachEntity` hook does not allow it.
function ITEM:OnUse(player, itemEntity)
  local trace = player:GetEyeTraceNoCursor()
  local entity = trace.Entity

  if IsValid(entity) then
    if entity:GetPos():Distance(player:GetShootPos()) <= 192 then
      if !IsValid(entity.breach) then
        if hook.Run('PlayerCanBreachEntity', player, entity) then
          local breach = ents.Create('cw_breach') breach:Spawn()

          breach:SetBreachEntity(entity, trace)
        else
          cw.player:Notify(player, L('Item_Breach_CantBreach'))

          return false
        end
      else
        cw.player:Notify(player, L('Item_Breach_AlreadyBreached'))

        return false
      end
    else
      cw.player:Notify(player, L('Item_Breach_NotCloseEnough'))

      return false
    end
  else
    cw.player:Notify(player, L('Item_Breach_NotValidEntity'))

    return false
  end
end

--- Lets the item be dropped; nothing else happens.
function ITEM:OnDrop(player, position) end
