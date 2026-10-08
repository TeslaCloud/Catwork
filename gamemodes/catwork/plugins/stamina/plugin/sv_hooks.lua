--- Server-side hooks of the Stamina plugin that drain and regenerate the `Stamina` character data and slow the run
-- speed as it falls.
--
-- `PlayerThink` runs a drain timer per player while they run and a regeneration timer while they do not, at rates set
-- by the `stam_drain_scale` and `stam_regen_scale` configs, health and the endurance attribute. Jumping and punching
-- cost stamina too, and other plugins can stop either timer by returning `false` from the `PlayerShouldStaminaDrain`
-- and `PlayerShouldStaminaRegenerate` hooks.

--- Called when a player's character data is saved; rounds the `Stamina` value.
--
-- @param player [Player The player whose character is saved]
-- @param data [Map The character data about to be saved]
function cwStamina:PlayerSaveCharacterData(player, data)
  if data['Stamina'] then
    data['Stamina'] = math.Round(data['Stamina'])
  end
end

--- Called when a player's character data is restored; sets `Stamina` to 100 when it is missing.
--
-- @param player [Player The player whose character is restored]
-- @param data [Map The restored character data]
function cwStamina:PlayerRestoreCharacterData(player, data)
  if !data['Stamina'] then
    data['Stamina'] = 100
  end
end

--- Called after a player spawns; refills their stamina unless it is a light spawn or the first spawn.
--
-- @param player [Player The player who spawned]
-- @param lightSpawn [Boolean Whether this is a light spawn that keeps the player's state]
-- @param changeClass [Boolean Whether the spawn comes from a class change]
-- @param firstSpawn [Boolean Whether this is the character's first spawn]
function cwStamina:PostPlayerSpawn(player, lightSpawn, changeClass, firstSpawn)
  if !firstSpawn and !lightSpawn then
    player:SetCharacterData('Stamina', 100)
  end
end

--- Called when a player tries to throw a punch; blocks it at 10 stamina or less.
--
-- @param player [Player The player trying to punch]
-- @return [Boolean False when the player is too tired, otherwise nil]
function cwStamina:PlayerCanThrowPunch(player)
  if player:GetCharacterData('Stamina') <= 10 then
    return false
  end
end

--- Called when a player throws a punch; drains stamina (less with more endurance) and progresses melee.
--
-- @param player [Player The player who punched]
function cwStamina:PlayerPunchThrown(player)
  local attribute = cw.attributes:Fraction(player, ATB_ENDURANCE, 1.5, 0.25)
  local decrease = 5 / (1 + attribute)

  player:SetCharacterData('Stamina', math.Clamp(player:GetCharacterData('Stamina') - decrease, 0, 100))
  player:ProgressAttribute(ATB_MELEE, 1, true)
end

--- Called every second for each player; copies their stamina character data to the `Stamina` net var.
--
-- The value is only sent to the player themselves, and only when it has changed.
--
-- @param player [Player The player being updated]
-- @param curTime [Number The current time]
function cwStamina:OnePlayerSecond(player, curTime)
  local stamina = math.floor(player:GetCharacterData('Stamina'))

  if player:GetNetVar('Stamina') != stamina then
    player:SetLocalVar('Stamina', stamina)
  end
end

do
  local running = {}

  local function IsRunning(player)
    return running[player]
  end

  local function StartRunning(player, shouldDrain)
    local steamID = player:SteamID()
    local timerName = 'Stam::Run::'..steamID

    running[player] = true

    timer.Pause('Stam::Regen::'..steamID)

    if shouldDrain then
      if !timer.Exists(timerName) then
        timer.Create(timerName, 0.2, 0, function()
          if !IsValid(player) then
            timer.Remove(timerName)

            return
          end

          local drainScale = config.GetVal('stam_drain_scale')
          local attribute = cw.attributes:Fraction(player, ATB_ENDURANCE, 1, 0.25)
          local maxHealth = player:GetMaxHealth()
          local healthScale = (drainScale * (math.Clamp(player:Health(), maxHealth * 0.1, maxHealth) / maxHealth))
          local decrease = (drainScale + (drainScale - healthScale)) - ((drainScale * 0.5) * attribute)
          local newStamina = math.Clamp(player:GetCharacterData('Stamina') - decrease, 0, 100)

          player:SetCharacterData('Stamina', newStamina)

          if newStamina > 1 then
            player:ProgressAttribute(ATB_ENDURANCE, 0.025, true)
          end
        end)
      else
        timer.UnPause(timerName)
      end
    else
      timer.Pause(timerName)
    end
  end

  local function StopRunning(player, shouldRegen)
    local steamID = player:SteamID()
    local timerName = 'Stam::Regen::'..steamID

    running[player] = false

    timer.Pause('Stam::Run::'..steamID)

    if shouldRegen then
      if !timer.Exists(timerName) then
        timer.Create(timerName, 0.5, 0, function()
          if !IsValid(player) then
            timer.Remove(timerName)

            return
          end

          local attribute = cw.attributes:Fraction(player, ATB_ENDURANCE, 1, 0.25)
          local regeneration = config.GetVal('stam_regen_scale') + attribute

          if player:Crouching() then
            regeneration = regeneration * 2
          end

          player:SetCharacterData(
            'Stamina', math.Clamp(
              player:GetCharacterData('Stamina') + regeneration, 0, 100 - player:GetCharacterData('Fatigue', 0)
            )
          )
        end)
      else
        timer.UnPause(timerName)
      end
    else
      timer.Pause(timerName)
    end
  end

  --- Called periodically for every player; drains or regenerates stamina and scales the run speed.
  --
  -- Jumping costs 2.5 stamina. Starting to run on the ground starts a drain timer, stopping starts a
  -- regeneration timer (twice as fast while crouching, capped at 100 minus the `Fatigue` character data);
  -- the `PlayerShouldStaminaDrain` and `PlayerShouldStaminaRegenerate` hooks stop a timer from running by
  -- returning `false`. Nothing changes while noclipping. The run speed in `infoTable` is lowered towards the walk speed
  -- as stamina falls, and capped at the `run_speed` config.
  --
  -- @param player [Player The player being updated]
  -- @param curTime [Number The current time]
  -- @param infoTable [Map The player's movement info: `isJumping`, `isRunning`, `runSpeed` and `walkSpeed`;
  -- `runSpeed` is changed in place]
  function cwStamina:PlayerThink(player, curTime, infoTable)
    if !cw.player:IsNoClipping(player) then
      local isJumping = infoTable.isJumping
      local isRunning = infoTable.isRunning
      local isRunTimerActive = IsRunning(player)

      if isJumping then
        player:SetCharacterData(
          'Stamina', math.Clamp(player:GetCharacterData('Stamina') - 2.5, 0, 100)
        )

        player:ProgressAttribute(ATB_ENDURANCE, 0.02, true)
      else
        if !isRunTimerActive and (isRunning and player:IsOnGround()) then
          StartRunning(player, plugin.Call('PlayerShouldStaminaDrain', player) != false)
        elseif (isRunTimerActive) and !(isRunning) then
          StopRunning(player, plugin.Call('PlayerShouldStaminaRegenerate', player) != false)
        end
      end
    end

    local newRunSpeed = infoTable.runSpeed * 2
    local diffRunSpeed = newRunSpeed - infoTable.walkSpeed

    infoTable.runSpeed = math.Clamp(
      newRunSpeed - (diffRunSpeed - ((diffRunSpeed / 100) * player:GetCharacterData('Stamina'))),
      infoTable.walkSpeed,
      config.GetVal('run_speed')
    )
  end

  --- Called when a player disconnects; removes their stamina timers.
  --
  -- @param player [Player The player who disconnected]
  function cwStamina:PlayerDisconnected(player)
    local steamID = player:SteamID()

    timer.Remove('Stam::Run::'..steamID)
    timer.Remove('Stam::Regen::'..steamID)

    running[player] = nil
  end
end
