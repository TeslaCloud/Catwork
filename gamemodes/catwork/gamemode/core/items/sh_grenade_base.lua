--- Defines the `grenade_base` base item for throwable grenades, built on `weapon_base`.
--
-- Equipping gives one round of `grenade` spawn ammo, which holstering or dropping takes back. Once the grenade has
-- been thrown and no ammo is left, trying to holster or drop it strips the weapon instead.

ITEM.isBaseItem = true
ITEM.baseItem = 'weapon_base'
ITEM.name = 'Grenade Base'
ITEM.isThrowableWeapon = true

--- Gives the player one grenade of spawn ammo when the grenade is equipped.
function ITEM:OnEquip(player)
  cw.player:GiveSpawnAmmo(player, 'grenade', 1)
end

--- Allows dropping while the player has grenade ammo; without ammo it strips the weapon and takes the item.
-- @return [Boolean Whether the weapon may be dropped]
function ITEM:CanDropWeapon(player, attacker, bNoMsg)
  if player:GetAmmoCount('grenade') == 0 then
    player:StripWeapon(self:GetWeaponClass())
    player:TakeItem(self, true)

    return false
  else
    return true
  end
end

--- Allows holstering while the player has grenade ammo; without ammo it strips the weapon.
-- @return [Boolean Whether the weapon may be holstered]
function ITEM:CanHolsterWeapon(player, forceHolster, bNoMsg)
  if player:GetAmmoCount('grenade') == 0 then
    player:StripWeapon(self:GetWeaponClass())

    return false
  else
    return true
  end
end

--- Holsters the grenade back into the inventory, or drops it where the player looks when `extraData` is `'drop'`.
--
-- Runs `PlayerCanHolsterWeapon`/`PlayerHolsterWeapon` or `PlayerCanDropWeapon`/`PlayerDropWeapon`, and takes
-- the grenade's spawn ammo away in both cases.
function ITEM:OnPlayerUnequipped(player, extraData)
  local weapon = player:GetWeapon(self:GetWeaponClass())
  if !IsValid(weapon) then return end

  local itemTable = item.GetByWeapon(weapon)

  if itemTable:IsTheSameAs(self) then
    local class = weapon:GetClass()

    if extraData != 'drop' then
      if hook.Run('PlayerCanHolsterWeapon', player, self, weapon) then
        if player:GiveItem(self) then
          hook.Run('PlayerHolsterWeapon', player, self, weapon)
          cw.player:TakeSpawnAmmo(player, 'grenade', 1)
          player:StripWeapon(class)
          player:SelectWeapon('cw_hands')
        end
      end
    elseif hook.Run('PlayerCanDropWeapon', player, self, weapon) then
      local trace = player:GetEyeTraceNoCursor()

      if player:GetShootPos():Distance(trace.HitPos) <= 192 then
        local entity = cw.entity:CreateItem(player, self, trace.HitPos)

        if IsValid(entity) then
          cw.entity:MakeFlushToGround(entity, trace.HitPos, trace.HitNormal)
          hook.Run('PlayerDropWeapon', player, self, entity, weapon)

          player:TakeItem(self, true)
          cw.player:TakeSpawnAmmo(player, 'grenade', 1)
          player:StripWeapon(class)
          player:SelectWeapon('cw_hands')
        end
      else
        cw.player:Notify(player, '#CantDropFar')
      end
    end
  end
end
