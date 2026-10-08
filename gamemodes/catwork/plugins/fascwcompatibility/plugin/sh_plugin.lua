--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

--- Called to check whether the weapon selection menu may open; blocks it while a FA:S 2, SXBase or CW 2.0
-- weapon is being customized.
--
-- @param player [Player The player switching weapons]
-- @param oldIndex [Number Previously selected slot index]
-- @param newIndex [Number Newly selected slot index]
-- @return [Boolean False to keep the menu closed, or nil to leave the decision to other hooks]
function PLUGIN:ShouldWeaponMenuOpen(player, oldIndex, newIndex)
  local weapon = player:GetActiveWeapon()

  if ((weapon.IsFAS2Weapon or weapon.IsSXBASEWeapon) and weapon.dt.Status == FAS_STAT_CUSTOMIZE)
  or (weapon.CW20Weapon and weapon.dt.State == CW_CUSTOMIZE) then
    return false
  end
end

--- Called when a player raises or lowers a weapon; toggles FA:S 2, CW 2.0 and SXBase weapons between the
-- `safe` fire mode and their second fire mode.
--
-- @param player [Player The player toggling the weapon]
-- @param weapon [Weapon The weapon being toggled]
-- @param bIsRaised [Boolean Whether the weapon is now raised]
function PLUGIN:OnWeaponRaised(player, weapon, bIsRaised)
  if IsValid(weapon) then
    if weapon.IsFAS2Weapon or weapon.CW20Weapon or weapon.IsSXBASEWeapon then
      if weapon.FireMode == 'safe' then
        weapon:SelectFiremode(weapon.FireModes[2])
      else
        weapon:SelectFiremode('safe')
      end
    end
  end
end

--- Called to check whether a weapon counts as raised; FA:S 2, CW 2.0 and SXBase weapons are raised unless
-- they are in the `safe` fire mode.
--
-- @param player [Player The weapon's owner]
-- @param weapon [Weapon The weapon to check]
-- @return [Boolean Whether the weapon is raised, or nil for weapons of other bases]
function PLUGIN:ShouldWeaponBeRaised(player, weapon)
  if weapon.IsFAS2Weapon or weapon.CW20Weapon or weapon.IsSXBASEWeapon then
    return weapon.FireMode != 'safe'
  end
end

--- Called to check whether a weapon can be raised or lowered; blocks it while a FA:S 2, SXBase or CW 2.0
-- weapon is busy (not idle).
--
-- @param player [Player The weapon's owner]
-- @param weapon [Weapon The weapon to toggle]
-- @return [Boolean False while the weapon is busy, true otherwise]
function PLUGIN:CanWeaponBeToggled(player, weapon)
  if ((weapon.IsFAS2Weapon or weapon.IsSXBASEWeapon) and weapon.dt.Status != FAS_STAT_IDLE)
  or (weapon.CW20Weapon and weapon.dt.State != CW_IDLE) then
    return false
  end

  return true
end
