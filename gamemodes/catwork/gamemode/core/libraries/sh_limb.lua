--- Defines the `cw.limb` library, the per-limb damage system switched on by the `limb_damage_system` config.
--
-- The server adds and heals damage per hit group and networks it. The client keeps the local player's limb damage and
-- supplies the names, textures and colors for the limb display.

library.New('limb', cw)

cw.limb.bones = {
  ['ValveBiped.Bip01_R_UpperArm'] = HITGROUP_RIGHTARM,
  ['ValveBiped.Bip01_R_Forearm'] = HITGROUP_RIGHTARM,
  ['ValveBiped.Bip01_L_UpperArm'] = HITGROUP_LEFTARM,
  ['ValveBiped.Bip01_L_Forearm'] = HITGROUP_LEFTARM,
  ['ValveBiped.Bip01_R_Thigh'] = HITGROUP_RIGHTLEG,
  ['ValveBiped.Bip01_R_Calf'] = HITGROUP_RIGHTLEG,
  ['ValveBiped.Bip01_R_Foot'] = HITGROUP_RIGHTLEG,
  ['ValveBiped.Bip01_R_Hand'] = HITGROUP_RIGHTARM,
  ['ValveBiped.Bip01_L_Thigh'] = HITGROUP_LEFTLEG,
  ['ValveBiped.Bip01_L_Calf'] = HITGROUP_LEFTLEG,
  ['ValveBiped.Bip01_L_Foot'] = HITGROUP_LEFTLEG,
  ['ValveBiped.Bip01_L_Hand'] = HITGROUP_LEFTARM,
  ['ValveBiped.Bip01_Pelvis'] = HITGROUP_STOMACH,
  ['ValveBiped.Bip01_Spine2'] = HITGROUP_CHEST,
  ['ValveBiped.Bip01_Spine1'] = HITGROUP_CHEST,
  ['ValveBiped.Bip01_Head1'] = HITGROUP_HEAD,
  ['ValveBiped.Bip01_Neck1'] = HITGROUP_HEAD
}

--- Returns the hit group a bone belongs to.
--
-- @param bone [String Bone name, such as `'ValveBiped.Bip01_Head1'`]
-- @return [Number The `HITGROUP_*` value; `HITGROUP_CHEST` for bones not in `cw.limb.bones`]
function cw.limb:BoneToHitGroup(bone)
  return self.bones[bone] or HITGROUP_CHEST
end

--- Returns whether the limb damage system is enabled.
--
-- Reads the `limb_damage_system` config.
--
-- @return [Boolean Whether limb damage is enabled]
function cw.limb:IsActive()
  return config.Get('limb_damage_system'):Get()
end

if SERVER then
  --- Adds damage to one of a player's limbs.
  --
  -- Damage is rounded up and the limb's total is capped at 100. The damage is stored in the
  -- `LimbData` character data, sent to the player and the `PlayerLimbTakeDamage` hook is run (via
  -- `hook.Run`). Does nothing if the character has no limb data.
  --
  -- @param player [Player The injured player]
  -- @param hitGroup [Number The `HITGROUP_*` of the limb]
  -- @param damage [Number Damage to add]
  function cw.limb:TakeDamage(player, hitGroup, damage)
    local newDamage = math.ceil(damage)
    local limbData = player:GetCharacterData('LimbData')

    if limbData then
      limbData[hitGroup] = math.min((limbData[hitGroup] or 0) + newDamage, 100)

      netstream.Start(player, 'TakeLimbDamage', {
        hitGroup = hitGroup, damage = newDamage
      })

      hook.Run('PlayerLimbTakeDamage', player, hitGroup, newDamage)
    end
  end

  --- Heals every damaged limb of a player by the same amount.
  --
  -- @param player [Player The player to heal]
  -- @param amount [Number Damage to remove from each limb]
  -- @see cw.limb:HealDamage
  function cw.limb:HealBody(player, amount)
    local limbData = player:GetCharacterData('LimbData')

    if limbData then
      for k, v in pairs(limbData) do
        self:HealDamage(player, k, amount)
      end
    end
  end

  --- Removes damage from one of a player's limbs.
  --
  -- The amount is rounded up. A fully healed limb is removed from the `LimbData` character data.
  -- The change is sent to the player and the `PlayerLimbDamageHealed` hook is run (via
  -- `hook.Run`). Does nothing if the limb is not damaged.
  --
  -- @param player [Player The player to heal]
  -- @param hitGroup [Number The `HITGROUP_*` of the limb]
  -- @param amount [Number Damage to remove]
  function cw.limb:HealDamage(player, hitGroup, amount)
    local newAmount = math.ceil(amount)
    local limbData = player:GetCharacterData('LimbData')

    if limbData and limbData[hitGroup] then
      limbData[hitGroup] = math.max(limbData[hitGroup] - newAmount, 0)

      if limbData[hitGroup] == 0 then
        limbData[hitGroup] = nil
      end

      netstream.Start(player, 'HealLimbDamage', {
        hitGroup = hitGroup, amount = newAmount
      })

      hook.Run('PlayerLimbDamageHealed', player, hitGroup, newAmount)
    end
  end

  --- Heals all of a player's limbs at once.
  --
  -- Clears the `LimbData` character data, tells the player and runs the `PlayerLimbDamageReset`
  -- hook (via `hook.Run`).
  --
  -- @param player [Player The player to heal]
  function cw.limb:ResetDamage(player)
    player:SetCharacterData('LimbData', {})

    netstream.Start(player, 'ResetLimbDamage', true)

    hook.Run('PlayerLimbDamageReset', player)
  end

  --- Returns whether any of a player's limbs are damaged.
  --
  -- @param player [Player The player to check]
  -- @return [Boolean Whether any limb has damage]
  function cw.limb:IsAnyDamaged(player)
    local limbData = player:GetCharacterData('LimbData')

    if limbData and table.Count(limbData) > 0 then
      return true
    else
      return false
    end
  end

  --- Returns the health of one of a player's limbs, 100 minus its damage.
  --
  -- With `asFraction`, the damage fraction is subtracted from 100, so the result stays between 99
  -- and 100 instead of becoming a fraction.
  --
  -- @param player [Player The player to check]
  -- @param hitGroup [Number The `HITGROUP_*` of the limb]
  -- @param asFraction=nil [Boolean Subtract the damage as a fraction of 100]
  -- @return [Number The limb's health]
  -- @see cw.limb:GetDamage
  function cw.limb:GetHealth(player, hitGroup, asFraction)
    return 100 - self:GetDamage(player, hitGroup, asFraction)
  end

  --- Returns the damage of one of a player's limbs.
  --
  -- @param player [Player The player to check]
  -- @param hitGroup [Number The `HITGROUP_*` of the limb]
  -- @param asFraction=nil [Boolean Return the damage as a fraction from 0 to 1]
  -- @return [Number The limb's damage from 0 to 100 (or 0 to 1); 0 when limb damage is disabled]
  function cw.limb:GetDamage(player, hitGroup, asFraction)
    if !config.Get('limb_damage_system'):Get() then
      return 0
    end

    local limbData = player:GetCharacterData('LimbData')

    if type(limbData) == 'table' then
      if limbData and limbData[hitGroup] then
        if asFraction then
          return limbData[hitGroup] / 100
        else
          return limbData[hitGroup]
        end
      end
    end

    return 0
  end
else
  cw.limb.bodyTexture = Material('clockwork/limbs/body.png')
  cw.limb.stored = cw.limb.stored or {}
  cw.limb.hitGroups = {
    [HITGROUP_RIGHTARM] = Material('clockwork/limbs/rarm.png'),
    [HITGROUP_RIGHTLEG] = Material('clockwork/limbs/rleg.png'),
    [HITGROUP_LEFTARM] = Material('clockwork/limbs/larm.png'),
    [HITGROUP_LEFTLEG] = Material('clockwork/limbs/lleg.png'),
    [HITGROUP_STOMACH] = Material('clockwork/limbs/stomach.png'),
    [HITGROUP_CHEST] = Material('clockwork/limbs/chest.png'),
    [HITGROUP_HEAD] = Material('clockwork/limbs/head.png')
  }
  cw.limb.names = {
    [HITGROUP_RIGHTARM] = 'Right Arm',
    [HITGROUP_RIGHTLEG] = 'Right Leg',
    [HITGROUP_LEFTARM] = 'Left Arm',
    [HITGROUP_LEFTLEG] = 'Left Leg',
    [HITGROUP_STOMACH] = 'Stomach',
    [HITGROUP_CHEST] = 'Chest',
    [HITGROUP_HEAD] = 'Head'
  }

  --- Returns the material used to draw a limb on the limb status display.
  --
  -- @param hitGroup [Any The `HITGROUP_*` of the limb, or `'body'` for the whole body outline]
  -- @return [IMaterial The limb's material, or `nil` for unknown hit groups]
  function cw.limb:GetTexture(hitGroup)
    if hitGroup == 'body' then
      return self.bodyTexture
    else
      return self.hitGroups[hitGroup]
    end
  end

  --- Returns the display name of a limb.
  --
  -- @param hitGroup [Number The `HITGROUP_*` of the limb]
  -- @return [String The limb's name, such as `'Right Arm'`; `'Generic'` for unknown hit groups]
  function cw.limb:GetName(hitGroup)
    return self.names[hitGroup] or 'Generic'
  end

  --- Returns the color a limb is drawn in for its health.
  --
  -- Green above 75, yellow above 50, orange above 25 and red otherwise.
  --
  -- @param health [Number Limb health from 0 to 100]
  -- @return [Color The limb's color]
  function cw.limb:GetColor(health)
    if health > 75 then
      return Color(166, 243, 76, 255)
    elseif health > 50 then
      return Color(233, 225, 94, 255)
    elseif health > 25 then
      return Color(233, 173, 94, 255)
    else
      return Color(222, 57, 57, 255)
    end
  end

  --- Returns the health of one of the local player's limbs, 100 minus its damage.
  --
  -- Client version of the server's `cw.limb:GetHealth`. With `asFraction`, the damage fraction is
  -- subtracted from 100, so the result stays between 99 and 100.
  --
  -- @param hitGroup [Number The `HITGROUP_*` of the limb]
  -- @param asFraction=nil [Boolean Subtract the damage as a fraction of 100]
  -- @return [Number The limb's health]
  function cw.limb:GetHealth(hitGroup, asFraction)
    return 100 - self:GetDamage(hitGroup, asFraction)
  end

  --- Returns the damage of one of the local player's limbs, as networked by the server.
  --
  -- @param hitGroup [Number The `HITGROUP_*` of the limb]
  -- @param asFraction=nil [Boolean Return the damage as a fraction from 0 to 1]
  -- @return [Number The limb's damage from 0 to 100 (or 0 to 1); 0 when limb damage is disabled]
  function cw.limb:GetDamage(hitGroup, asFraction)
    if !config.Get('limb_damage_system'):Get() then
      return 0
    end

    if type(self.stored) == 'table' then
      if self.stored[hitGroup] then
        if asFraction then
          return self.stored[hitGroup] / 100
        else
          return self.stored[hitGroup]
        end
      end
    end

    return 0
  end

  --- Returns whether any of the local player's limbs are damaged.
  --
  -- @return [Boolean Whether any limb has damage]
  function cw.limb:IsAnyDamaged()
    return table.Count(self.stored) > 0
  end

  netstream.Hook('ReceiveLimbDamage', function(data)
    cw.limb.stored = data
    hook.Run('PlayerLimbDamageReceived')
  end)

  netstream.Hook('ResetLimbDamage', function(data)
    cw.limb.stored = {}
    hook.Run('PlayerLimbDamageReset')
  end)

  netstream.Hook('TakeLimbDamage', function(data)
    local hitGroup = data.hitGroup
    local damage = data.damage

    cw.limb.stored[hitGroup] = math.min((cw.limb.stored[hitGroup] or 0) + damage, 100)
    hook.Run('PlayerLimbTakeDamage', hitGroup, damage)
  end)

  netstream.Hook('HealLimbDamage', function(data)
    local hitGroup = data.hitGroup
    local amount = data.amount

    if cw.limb.stored[hitGroup] then
      cw.limb.stored[hitGroup] = math.max(cw.limb.stored[hitGroup] - amount, 0)

      if cw.limb.stored[hitGroup] == 100 then
        cw.limb.stored[hitGroup] = nil
      end

      hook.Run('PlayerLimbDamageHealed', hitGroup, amount)
    end
  end)
end
