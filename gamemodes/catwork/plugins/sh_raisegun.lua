--[[
  Flux © 2016-2017 TeslaCloud Studios
  Do not share or re-distribute before
  the framework is publicly released.
--]]

PLUGIN.name = 'Raise Gun'
PLUGIN.description = 'Allows players to raise and lower their weapons.'
PLUGIN.author = 'Mr. Meow'
PLUGIN.compatibility = '1.2'

local playerMeta = FindMetaTable('Player')
local blockedWeapons = {
  'weapon_physgun',
  'gmod_tool',
  'gmod_camera',
  'weapon_physcannon',
  'cw_keys'
}

local rotationTranslate = {
  ['default'] = Angle(30, -30, -25),
  ['weapon_fists'] = Angle(30, -30, -50),
  ['cw_hands'] = Angle(30, -30, -50)
}

--- Raises or lowers the player's weapon.
--
-- Server only; does nothing on the client. Stores the state in the `BOOL_WEAPON_RAISED` data table
-- variable, which is networked to clients, and runs the `OnWeaponRaised` hook with the player, their
-- active weapon and the new state.
--
-- @param bIsRaised [Boolean True to raise the weapon, false to lower it]
-- @see Player:ToggleWeaponRaised
function playerMeta:SetWeaponRaised(bIsRaised)
  if SERVER then
    self:SetDTBool(BOOL_WEAPON_RAISED, bIsRaised)

    hook.Run('OnWeaponRaised', self, self:GetActiveWeapon(), bIsRaised)
  end
end

--- Returns whether the player's active weapon is raised.
--
-- Tools such as the physgun, toolgun, camera, gravity gun and keys always count as raised. A truthy
-- result from the `ShouldWeaponBeRaised` hook also counts as raised; otherwise the networked state set
-- by `Player:SetWeaponRaised` decides.
--
-- @return [Boolean Whether the weapon is raised; false when the player has no valid weapon]
function playerMeta:IsWeaponRaised()
  local weapon = self:GetActiveWeapon()

  if !IsValid(weapon) then
    return false
  end

  if table.HasValue(blockedWeapons, weapon:GetClass()) then
    return true
  end

  local shouldRaise = hook.Run('ShouldWeaponBeRaised', self, weapon)

  if shouldRaise then
    return shouldRaise
  end

  return self:GetDTBool(BOOL_WEAPON_RAISED)
end

--- Raises the player's weapon if it is lowered, or lowers it if it is raised.
--
-- Only acts when the `CanWeaponBeToggled` hook returns true for the active weapon.
--
-- @see Player:SetWeaponRaised
function playerMeta:ToggleWeaponRaised()
  if hook.Run('CanWeaponBeToggled', self, self:GetActiveWeapon()) then
    if self:IsWeaponRaised() then
      self:SetWeaponRaised(false)
    else
      self:SetWeaponRaised(true)
    end
  end
end

--- Called when a player raises or lowers a weapon; runs the `UpdateWeaponRaised` hook with the current time.
--
-- @param player [Player The player toggling the weapon]
-- @param weapon [Weapon The player's active weapon]
-- @param bIsRaised [Boolean Whether the weapon is now raised]
function PLUGIN:OnWeaponRaised(player, weapon, bIsRaised)
  if IsValid(weapon) then
    local curTime = CurTime()

    hook.Run('UpdateWeaponRaised', player, weapon, bIsRaised, curTime)
  end
end

--- Called after a weapon is raised or lowered; lets raised weapons fire and blocks lowered ones.
--
-- Raised weapons (and always-raised tools) can fire at once and get their `OnRaised` method called;
-- lowered weapons cannot fire for 60 seconds and get their `OnLowered` method called.
--
-- @param player [Player The weapon's owner]
-- @param weapon [Weapon The weapon that changed state]
-- @param bIsRaised [Boolean Whether the weapon is now raised]
-- @param curTime [Number The current time]
function PLUGIN:UpdateWeaponRaised(player, weapon, bIsRaised, curTime)
  if bIsRaised or table.HasValue(blockedWeapons, weapon:GetClass()) then
    weapon:SetNextPrimaryFire(curTime)
    weapon:SetNextSecondaryFire(curTime)

    if weapon.OnRaised then
      weapon:OnRaised(player, curTime)
    end
  else
    weapon:SetNextPrimaryFire(curTime + 60)
    weapon:SetNextSecondaryFire(curTime + 60)

    if weapon.OnLowered then
      weapon:OnLowered(player, curTime)
    end
  end
end

--- Called periodically for every player; keeps pushing back the next fire time of lowered weapons.
--
-- @param player [Player The player being updated]
-- @param curTime [Number The current time]
function PLUGIN:PlayerThink(player, curTime)
  local weapon = player:GetActiveWeapon()

  if IsValid(weapon) then
    if !player:IsWeaponRaised() then
      weapon:SetNextPrimaryFire(curTime + 60)
      weapon:SetNextSecondaryFire(curTime + 60)
    end
  end
end

--- Called when a player presses a key; holding reload for one second toggles their weapon.
--
-- @param player [Player The player pressing the key]
-- @param key [Number The `IN_*` key enum]
function PLUGIN:KeyPress(player, key)
  if key == IN_RELOAD then
    timer.Create('WeaponRaise'..player:SteamID(), 1, 1, function()
      player:ToggleWeaponRaised()
    end)
  end
end

--- Called when a player releases a key; releasing reload cancels the pending weapon toggle.
--
-- @param player [Player The player releasing the key]
-- @param key [Number The `IN_*` key enum]
function PLUGIN:KeyRelease(player, key)
  if key == IN_RELOAD then
    timer.Remove('WeaponRaise'..player:SteamID())
  end
end

--- Called to check whether a player's model should animate with a raised weapon.
--
-- @param player [Player The player being animated]
-- @param model [String The player's model]
-- @return [Boolean Whether the player's weapon is raised]
function PLUGIN:ModelWeaponRaised(player, model)
  return player:IsWeaponRaised()
end

--- Called when a player switches weapons; lowers the weapon if it was raised.
--
-- @param player [Player The player switching weapons]
-- @param oldWeapon [Weapon The previous weapon]
-- @param newWeapon [Weapon The new weapon]
function PLUGIN:PlayerSwitchWeapon(player, oldWeapon, newWeapon)
  if player:IsWeaponRaised() then
    player:SetWeaponRaised(false)
  end
end

--- Called when a player's data tables are set up; registers the `WeaponRaised` boolean.
--
-- @param player [Player The player whose data tables are set up]
function PLUGIN:PlayerSetupDataTables(player)
  player:DTVar('Bool', BOOL_WEAPON_RAISED, 'WeaponRaised')
end

if CLIENT then
  --- Called when the view model position is calculated; tilts the view model away while the weapon is lowered.
  --
  -- The tilt eases in and out and uses a per-weapon rotation (fists and hands differ from the default).
  -- The weapon's own `GetViewModelPosition` and `CalcViewModelView` methods are applied afterwards.
  --
  -- @param weapon [Weapon The local player's active weapon]
  -- @param viewModel [Entity The view model]
  -- @param oldEyePos [Vector The original eye position]
  -- @param oldEyeAngles [Angle The original eye angles]
  -- @param eyePos [Vector The current eye position]
  -- @param eyeAngles [Angle The current eye angles, rotated in place]
  -- @return [Vector The view model position, Angle The view model angles]
  function PLUGIN:CalcViewModelView(weapon, viewModel, oldEyePos, oldEyeAngles, eyePos, eyeAngles)
    if !IsValid(weapon) then
      return
    end

    local targetVal = 0

    if !cw.client:IsWeaponRaised() then
      targetVal = 100
    end

    local fraction = (cw.client.curRaisedFrac or 0) / 100
    local rotation = rotationTranslate[weapon:GetClass()] or rotationTranslate['default']

    eyeAngles:RotateAroundAxis(eyeAngles:Up(), rotation.p * fraction)
    eyeAngles:RotateAroundAxis(eyeAngles:Forward(), rotation.y * fraction)
    eyeAngles:RotateAroundAxis(eyeAngles:Right(), rotation.r * fraction)

    cw.client.curRaisedFrac = Lerp(FrameTime() * 2, cw.client.curRaisedFrac or 0, targetVal)

    viewModel:SetAngles(eyeAngles)

    if weapon.GetViewModelPosition then
      local position, angles = weapon:GetViewModelPosition(eyePos, eyeAngles)

      oldEyePos = position or oldEyePos
      eyeAngles = angles or eyeAngles
    end

    if weapon.CalcViewModelView then
      local position, angles = weapon:CalcViewModelView(viewModel, oldEyePos, oldEyeAngles, eyePos, eyeAngles)

      oldEyePos = position or oldEyePos
      eyeAngles = angles or eyeAngles
    end

    return oldEyePos, eyeAngles
  end
end
