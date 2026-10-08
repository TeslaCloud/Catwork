--- Server-side hooks of the Hunger plugin that drain, refill and apply the effects of the `Hunger`, `Thirst` and
-- `Fatigue` character data.
--
-- `OnePlayerSecond` drains hunger and thirst over the `hunger_tick` and `thirst_tick` configs, raises fatigue, hurts
-- starving players, knocks out exhausted ones and networks the three values as net vars. `PlayerUseItem` feeds the
-- player from food and drink items, `PlayerThink` makes jumping and running in the air cost thirst and add fatigue,
-- and low hunger or thirst blocks health and stamina regeneration.

--- Called when character data is saved; rounds the hunger, thirst and fatigue values.
--
-- @param player [Player The player being saved]
-- @param data [Character The character data to save, modified in place]
function PLUGIN:PlayerSaveCharacterData(player, data)
  if data['Hunger'] then
    data['Hunger'] = math.Round(tonumber(data['Hunger']))
  end

  if data['Thirst'] then
    data['Thirst'] = math.Round(tonumber(data['Thirst']))
  end

  if data['Fatigue'] then
    data['Fatigue'] = math.Round(tonumber(data['Fatigue']))
  end
end

--- Called when character data is restored; defaults hunger and thirst to 100 and fatigue to 0.
--
-- @param player [Player The player whose character is loading]
-- @param data [Character The character data, modified in place]
function PLUGIN:PlayerRestoreCharacterData(player, data)
  data['Hunger'] = tonumber(data['Hunger']) or 100
  data['Thirst'] = tonumber(data['Thirst']) or 100
  data['Fatigue'] = tonumber(data['Fatigue']) or 0
end

--- Called after a player spawns; resets their needs on a respawn that is neither the first nor a light spawn.
--
-- @param player [Player The player that spawned]
-- @param lightSpawn [Boolean Whether this was a light spawn]
-- @param changeClass [Boolean Whether the player changed class]
-- @param firstSpawn [Boolean Whether this is the character's first spawn]
function PLUGIN:PostPlayerSpawn(player, lightSpawn, changeClass, firstSpawn)
  if !firstSpawn and !lightSpawn then
    player:SetCharacterData('Hunger', 100)
    player:SetCharacterData('Thirst', 100)
    player:SetCharacterData('Fatigue', 0)
  end
end

--- Called after a player uses an item; feeds them when it is food or drink.
--
-- Applies to items with a `hunger`, `thirst` or `fatigue` field and to items in a
-- consumables, alcohol, UU-branded or food category. Missing values default to the
-- `hunger_default_refill` config. Drinks (a `thirst` field or "water" in the name) refill
-- thirst and only 40% of the hunger value; a `fatigue` field reduces fatigue. Saves the
-- character afterwards.
--
-- @param player [Player The player who used the item]
-- @param itemTable [Item The item used]
function PLUGIN:PlayerUseItem(player, itemTable)
  local category = itemTable.category:utf8lower()

  if itemTable.hunger or itemTable.thirst or itemTable.fatigue or category:find('consumables')
  or category:find('alcohol') or category:find('uu-branded items') or category:find('food') then
    local hungerRefill = itemTable.hunger or config.GetVal('hunger_default_refill') or 25
    local thirstRefill = itemTable.thirst or config.GetVal('hunger_default_refill') or 25
    local fatigueRefill = itemTable.fatigue or config.GetVal('hunger_default_refill') or 25

    if itemTable.thirst or itemTable.name:utf8lower():find('water') then
      hungerRefill = math.Round(hungerRefill * 0.4)
      player:SetCharacterData('Thirst', math.Clamp(player:GetCharacterData('Thirst') + thirstRefill, 0, 100))
    end

    if itemTable.fatigue then
      player:SetCharacterData('Fatigue', math.Clamp(player:GetCharacterData('Fatigue') - fatigueRefill, 0, 100))
    end

    player:SetCharacterData(
      'Hunger',
      math.Clamp(player:GetCharacterData('Hunger') + math.Clamp(hungerRefill, 0, 100), 0, 100)
    )
    player:SaveCharacter()
  end
end

--- Called to check whether a player gets hungry; everyone but the Combine does.
--
-- @param player [Player The player to check]
-- @return [Boolean Whether the player gets hungry]
function PLUGIN:PlayerHasHunger(player)
  return !player:IsCombine()
end

--- Called every player think; jumping and running in the air tire a player with needs and drain thirst.
--
-- Thirst drains by the `thirst_drain_scale` config, in hundredths, per think.
--
-- @param player [Player The player thinking]
-- @param curTime [Number The current time]
-- @param infoTable [Map The player's info table for this think, with `isJumping` and `isRunning`]
function PLUGIN:PlayerThink(player, curTime, infoTable)
  if plugin.Call('PlayerHasNeeds', player) then
    local scale = config.GetVal('thirst_drain_scale') or 50
    local decrease = 1 * (scale / 100)
    local fatdecreace = 0.01

    if !player:IsNoClipping() then
      local playerVelocityLength = player:GetVelocity():Length()

      if infoTable.isJumping then
        player:SetCharacterData(
          'Fatigue', math.Clamp(
            player:GetCharacterData('Fatigue') + fatdecreace, 0, 100
          )
        )
      end

      if (infoTable.isRunning and !infoTable.isJumping and !player:IsOnGround()) and playerVelocityLength != 0 then
        player:SetCharacterData(
          'Fatigue', math.Clamp(
            player:GetCharacterData('Fatigue') + fatdecreace, 0, 100
          )
        )
      end

      if infoTable.isJumping then
        player:SetCharacterData(
          'Thirst', math.Clamp(
            player:GetCharacterData('Thirst') - decrease, 0, 100
          )
        )
      end

      if (infoTable.isRunning and !infoTable.isJumping and !player:IsOnGround()) and playerVelocityLength != 0 then
        player:SetCharacterData(
          'Thirst', math.Clamp(
            player:GetCharacterData('Thirst') - decrease, 0, 100
          )
        )
      end
    end
  end
end

--- Called to check whether a player's thirst drains; it does for non-Combine players and Civil Protection.
--
-- @param player [Player The player to check]
-- @return [Boolean Whether thirst drains]
function PLUGIN:PlayerShouldThirstDrain(player)
  return !(player:IsCombine()) or player:GetFaction() == FACTION_MPF
end

--- Called every second for each player; drains the needs of players with needs and applies their effects.
--
-- Hunger and thirst fall so that they empty over the `hunger_tick` and `thirst_tick` configs
-- in seconds, and hunger is never above thirst. Fatigue rises over 20000 seconds. Starving
-- players slowly lose health down to 50 (below 15 hunger) or 20 (below 5), and players above
-- 85 fatigue fall asleep for 30 seconds. The values are networked as the `Hunger`, `Thirst`
-- and `Fatigue` net vars.
--
-- @param player [Player The player]
-- @param curTime [Number The current time]
-- @param infoTable [Map The player's info table]
function PLUGIN:OnePlayerSecond(player, curTime, infoTable)
  if player:HasInitialized() and hook.Run('PlayerHasNeeds', player) then
    local thirst = tonumber(player:GetCharacterData('Thirst')) or 0
    local hunger = math.Clamp(tonumber(player:GetCharacterData('Hunger')) or 0, 0, thirst)
    local fatigue = tonumber(player:GetCharacterData('Fatigue')) or 0
    local stamina = tonumber(player:GetCharacterData('Stamina')) or 0
    local step = 100 / math.Round(tonumber(config.GetVal('hunger_tick')) or 3600)
    local thirstStep = 100 / math.Round(tonumber(config.GetVal('thirst_tick')) or 3600)
    local fatStep = 100 / 20000

    if thirst then
      player:SetCharacterData('Hunger', hunger)
    end

    player:SetCharacterData('Hunger', math.Clamp(hunger - step, 0, 100))
    player:SetCharacterData('Thirst', math.Clamp(thirst - thirstStep, 0, 100))
    player:SetCharacterData('Fatigue', math.Clamp(fatigue + fatStep, 0, 100))

    if hunger < 15 then
      if player:Health() > 50 then
        player:SetHealth(player:Health() - 0.1)
      end
    end

    if hunger < 5 then
      if player:Health() > 20 then
        player:SetHealth(player:Health() - 0.1)
      end
    end

    if fatigue > 85 then
      cw.player:SetRagdollState(player, RAGDOLL_KNOCKEDOUT, 30)
      player:SetCharacterData('Fatigue', 0)
    end

    player:SetNetVar('Hunger', math.Round(tonumber(player:GetCharacterData('Hunger')) or 100))
    player:SetNetVar('Thirst', math.Round(tonumber(player:GetCharacterData('Thirst')) or 100))
    player:SetNetVar('Fatigue', math.Round(tonumber(player:GetCharacterData('Fatigue')) or 100))
  end
end

--- Called to check whether a player's health regenerates; blocks it below 65 hunger.
--
-- @param player [Player The player to check]
-- @return [Boolean `false` to block regeneration, otherwise `nil`]
function PLUGIN:PlayerShouldHealthRegenerate(player)
  local thirst = tonumber(player:GetCharacterData('Thirst')) or 100
  local hunger = math.Clamp(tonumber(player:GetCharacterData('Hunger')) or 100, 0, thirst)

  if hunger < 65 then
    return false
  end
end

--- Called to check whether a player's stamina regenerates; blocks it below 30 thirst.
--
-- @param player [Player The player to check]
-- @return [Boolean `false` to block regeneration, otherwise `nil`]
function PLUGIN:PlayerShouldStaminaRegenerate(player)
  local thirst = tonumber(player:GetCharacterData('Thirst')) or 100

  if thirst < 30 then
    return false
  end
end
