--- Shared gamemode hooks and metatable overrides for player models and animation.
--
-- Overrides `Player:SetModel` so that it runs the `PlayerModelChanged` hook on both realms, adds `Entity:IsStuck`, and
-- defines `GM:CalcMainActivity`, `GM:TranslateActivity`, `GM:DoAnimationEvent`, `GM:MouthMoveAnimation` and
-- `GM:PlayerFootstep`. `GM:OnReloaded` handles AutoRefresh: it re-checks the SQLite tables on the server and rebuilds
-- the theme on the client.

do
  local playerMeta = FindMetaTable('Player')
  local entMeta = FindMetaTable('Entity')
  entMeta.oldSetModel = entMeta.oldSetModel or entMeta.SetModel

  --- Returns whether the entity is stuck inside something at its current position.
  --
  -- Traces the entity's own hull from its position to the same position, ignoring itself.
  -- @return [Boolean Whether the trace starts in a solid]
  function entMeta:IsStuck()
    return util.TraceEntity({
      start = self:GetPos(),
      endpos = self:GetPos(),
      filter = self
    }, self).StartSolid
  end

  --- Sets the player's model and announces the change.
  --
  -- Overrides `Entity:SetModel` for players: runs the `PlayerModelChanged` hook first and, on the
  -- server, sends a `PlayerModelChanged` Cable message to every client so they run the hook too.
  -- @param strPath [String Path of the new model]
  -- @return [Any Whatever the original `Entity:SetModel` returns]
  function playerMeta:SetModel(strPath)
    local oldModel = self:GetModel()

    hook.Run('PlayerModelChanged', self, strPath, oldModel)

    if SERVER then
      cable.send(nil, 'PlayerModelChanged', self:EntIndex(), strPath, oldModel)
    end

    return self:oldSetModel(strPath)
  end

  local animCache = {}

  --- Called after a player's model is changed with `Player:SetModel`, on both realms.
  --
  -- Catwork caches the model's animation table from `cw.animation:GetTable` and stores it as
  -- `player.cwAnimTable`, which `GM:TranslateActivity` uses. On the client it also disables IK.
  -- @param player [Player The player whose model changed]
  -- @param strNewModel [String Path of the new model]
  -- @param strOldModel [String Path of the previous model]
  function GM:PlayerModelChanged(player, strNewModel, strOldModel)
    if CLIENT then
      player:SetIK(false)
    end

    if !animCache[strNewModel] then
      animCache[strNewModel] = cw.animation:GetTable(strNewModel)
    end

    player.cwAnimTable = animCache[strNewModel]
  end

  local vectorAngle = FindMetaTable('Vector').Angle
  local normalizeAngle = math.NormalizeAngle

  --- Called to pick the main activity and sequence a player should be playing.
  --
  -- Runs the base gamemode's noclip, driving, vaulting, jumping, swimming and ducking handlers,
  -- otherwise chooses idle, walk (above 0.5 units/s) or run (above 150 units/s). A forced
  -- animation set with `Player:SetForcedAnimation` overrides the result and has its `OnAnimate`
  -- callback run once.
  -- @param player [Player The player being animated]
  -- @param velocity [Vector The player's current velocity]
  -- @return [Number The ideal activity (`ACT_*`), Number The sequence override, or -1 for none]
  function GM:CalcMainActivity(player, velocity)
    player:SetPoseParameter('move_yaw', normalizeAngle(vectorAngle(velocity)[2] - player:EyeAngles()[2]))

    player.CalcIdeal = ACT_MP_STAND_IDLE
    player.CalcSeqOverride = -1

    local baseClass = self.BaseClass
    local playerTable = player:GetTable()

    if baseClass:HandlePlayerNoClipping(player, velocity, playerTable) or
      baseClass:HandlePlayerDriving(player, playerTable) or
      baseClass:HandlePlayerVaulting(player, velocity, playerTable) or
      baseClass:HandlePlayerJumping(player, velocity, playerTable) or
      baseClass:HandlePlayerSwimming(player, velocity, playerTable) or
      baseClass:HandlePlayerDucking(player, velocity, playerTable) then
    else
      local len2D = velocity:Length2D()

      if len2D > 150 then
        player.CalcIdeal = ACT_MP_RUN
      elseif len2D > 0.5 then
        player.CalcIdeal = ACT_MP_WALK
      end
    end

    local forcedAnimation = player:GetForcedAnimation()

    if forcedAnimation then
      local sequence = forcedAnimation.animation

      if isstring(sequence) then
        sequence = player:LookupSequence(sequence)
      end

      if sequence != -1 then
        if forcedAnimation.OnAnimate then
          forcedAnimation.OnAnimate(player)
          forcedAnimation.OnAnimate = nil
        end

        return sequence or ACT_IDLE, sequence or -1
      end
    end

    player.m_bWasOnGround = player:IsOnGround()
    player.m_bWasNoclipping = (player:GetMoveType() == MOVETYPE_NOCLIP and !player:InVehicle())

    return player.CalcIdeal, player.CalcSeqOverride
  end
end

--- Called to translate a player activity into the one their model should play.
--
-- Uses the player's cached animation table (`player.cwAnimTable`) and the hold type from
-- `cw.animation:GetWeaponHoldType`, picking the lowered or raised variant depending on
-- `Player:IsWeaponRaised` (the `cw_keys` weapon is always lowered). In vehicles the `sitchair1`
-- sequence is used. Falls back to the base gamemode when the model has no animation table.
-- String animations are applied as a sequence override instead of being returned.
-- @param player [Player The player being animated]
-- @param act [Number The activity to translate (`ACT_*`)]
-- @return [Number The translated activity, or `nil` when a sequence override was set instead]
function GM:TranslateActivity(player, act)
  local animations = player.cwAnimTable

  if !animations then
    return self.BaseClass:TranslateActivity(player, act)
  end

  if player:InVehicle() then
    player.CalcSeqOverride = player:LookupSequence('sitchair1')

    return
  elseif player:OnGround() then
    local weapon = player:GetActiveWeapon()
    local holdType = 'normal'
    local alwaysLowered = false

    if IsValid(weapon) then
      holdType = cw.animation:GetWeaponHoldType(player, weapon)

      if weapon:GetClass() == 'cw_keys' then
        alwaysLowered = true
      end
    end

    if animations[holdType] and animations[holdType][act] then
      local animation = animations[holdType][act]

      if istable(animation) then
        if !alwaysLowered and player:IsWeaponRaised() then
          animation = animation[2]
        else
          animation = animation[1]
        end
      end

      if isstring(animation) then
        player.CalcSeqOverride = player:LookupSequence(animation)
      else
        return animation
      end
    end
  elseif animations['normal']['glide'] then
    return animations['normal']['glide']
  end
end

--- Called when an animation event such as an attack, reload or jump should be played.
--
-- Models under `/player/` use the base gamemode. Other models play the attack or reload
-- gesture that `cw.animation:GetForModel` gives for the weapon's hold type, falling back to the
-- SMG1 gestures. Jumps set the standard GMod jump variables. Nothing happens without a valid
-- active weapon. The approach is a hybrid of NutScript's and Clockwork's.
-- @param player [Player The player the event is for]
-- @param event [Number The event (`PLAYERANIMEVENT_*`)]
-- @param data [Number Extra event data]
-- @return [Number The activity to play, or `nil`]
function GM:DoAnimationEvent(player, event, data)
  local model = player:GetModel()

  if string.find(model, '/player/') then
    return self.BaseClass:DoAnimationEvent(player, event, data)
  end

  local weapon = player:GetActiveWeapon()

  if IsValid(weapon) then
    local weaponHoldType = cw.animation:GetWeaponHoldType(player, weapon)

    if event == PLAYERANIMEVENT_ATTACK_PRIMARY then
      local attackAnimation = cw.animation:GetForModel(model, weaponHoldType, 'attack', true)

      player:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, attackAnimation or ACT_GESTURE_RANGE_ATTACK_SMG1, true)

      return ACT_VM_PRIMARYATTACK
    elseif event == PLAYERANIMEVENT_ATTACK_SECONDARY then
      local attackAnimation = cw.animation:GetForModel(model, weaponHoldType, 'attack', true)

      player:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, attackAnimation or ACT_GESTURE_RANGE_ATTACK_SMG1, true)

      return ACT_VM_SECONDARYATTACK
    elseif event == PLAYERANIMEVENT_RELOAD then
      local reloadAnimation = cw.animation:GetForModel(model, weaponHoldType, 'reload', true)

      player:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, reloadAnimation or ACT_GESTURE_RELOAD_SMG1, true)

      return ACT_INVALID
    elseif event == PLAYERANIMEVENT_JUMP then
      -- manually set standard gmod vars.
      player.m_bJumping = true
      player.m_bFirstJumpFrame = true
      player.m_flJumpStartTime = CurTime()

      player:AnimRestartMainSequence()

      return ACT_INVALID
    elseif event == PLAYERANIMEVENT_CANCEL_RELOAD then
      player:AnimResetGestureSlot(GESTURE_SLOT_ATTACK_AND_RELOAD)

      return ACT_INVALID
    end
  end
end

--- Called to move a player's mouth while they speak.
--
-- Only uses the base gamemode's mouth movement when the `enable_mouth_move` config is enabled.
-- @param player [Player The player speaking]
function GM:MouthMoveAnimation(player)
  if config.GetVal('enable_mouth_move') then
    return self.BaseClass:MouthMoveAnimation(player)
  else
    return
  end
end

--- Called when a player's footstep sound should be played; returns `true` to suppress every footstep.
-- @param player [Player The player stepping]
-- @param position [Vector Where the footstep happens]
-- @param foot [Number 0 for the left foot, 1 for the right]
-- @param sound [String The footstep sound path]
-- @param volume [Number The footstep volume]
-- @param recipientFilter [CRecipientFilter Who would hear the sound]
-- @return [Boolean Always `true`, so the default sound is not played]
function GM:PlayerFootstep(player, position, foot, sound, volume, recipientFilter)
  return true
end

--- Called when the gamemode has been reloaded by AutoRefresh.
--
-- Sets `cw.Reloaded`. On the server it re-runs `cw.database:OnConnected` when SQLite is used (a
-- MySQL connection survives the reload). On the client it recreates the theme's fonts and skin
-- and re-initializes the theme.
function GM:OnReloaded()
  cw.Reloaded = true

  if SERVER then
    -- Only sqlite needs its tables re-checked; a MySQL connection survives the reload on its own.
    if cw.database.Module == 'sqlite' then
      cw.database:OnConnected()
    end

    print('[Catwork] OnReloaded hook called serverside!')
  else
    cw.theme:Get():CreateFonts()
      cw.theme:CopySkin()
    cw.theme:Get():Initialize()

    cw.core:PrintColoredText(
      cw.core:GetLogTypeColor(LOGTYPE_MINOR), 'Clockwork has AutoRefreshed clientside!'
    )
  end
end
