--[[
  © 2013 CloudSixteen.com do not share, re-distribute or modify
  without permission of its author (kurozael@gmail.com).
--]]

ITEM.name = 'Combine Lock'
ITEM.PrintName = '#Item_CombineLock2_PrintName'
ITEM.overrideColor = Color(210, 110, 255)
ITEM.uniqueID = 'combine_lock_2'
ITEM.cost = 0
ITEM.model = 'models/props_combine/combine_lock01.mdl'
ITEM.weight = 4
ITEM.classes = { CLASS_EMP, CLASS_EOW }
ITEM.useText = '#Item_CombineLock_UseText'
ITEM.business = true
ITEM.description = '#Item_CombineLock2_Description'
ITEM.accessLevel = 2
ITEM.category = '#Item_Category_CardsAndLocks'

--- Fits a level 2 Combine lock to the unownable door the player looks at, within 192 units.
--
-- Destroys a breaching charge already on the door. Fails, keeping the item, when the door
-- already has a lock or cannot have one.
--
-- @return [Boolean `false` when the lock could not be fitted]
function ITEM:OnUse(player, itemEntity)
  local trace = player:GetEyeTraceNoCursor()
  local entity = trace.Entity

  if IsValid(entity) then
    if entity:GetPos():Distance(player:GetPos()) <= 192 then
      if !IsValid(entity.combineLock) then
        if cw.entity:IsDoorUnownable(entity) then
          local angles = trace.HitNormal:Angle() + Angle(0, 270, 0)
          local position

          if string.lower(entity:GetClass()) == 'prop_door_rotating' then
            position = trace
          else
            position = trace.HitPos + (trace.HitNormal * 4)
          end

          if !IsValid(Schema:ApplyCombineLock(entity, position, angles, self.accessLevel, nil, self.overrideColor)) then
            return false
          elseif IsValid(entity.breach) then
            entity.breach:CreateDummyBreach()
            entity.breach:Explode()
            entity.breach:Remove()
          end
        else
          cw.player:Notify(player, L('CombineLock_DoorCannotHave'))

          return false
        end
      else
        cw.player:Notify(player, L('CombineLock_AlreadyHas'))

        return false
      end
    else
      cw.player:Notify(player, L('CombineLock_NotCloseEnough'))

      return false
    end
  else
    cw.player:Notify(player, L('CombineLock_NotValidEntity'))

    return false
  end
end

--- Called when the lock is dropped; does nothing, so it can be dropped freely.
function ITEM:OnDrop(player, position) end
