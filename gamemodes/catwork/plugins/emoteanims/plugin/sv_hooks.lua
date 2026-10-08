--- Server-side hooks of the Emote Anims plugin that end a player's emote when they move, spawn or are ragdolled.
--
-- `PlayerThink` clears the stance once the player presses a movement key, strays more than 16 units from the stance
-- position or leaves the ground. Other hooks block firing, noclip and ragdolling while in a stance.

--- Called just after a player spawns; ends the player's emote in place unless it was a light spawn.
-- @param player [Player The player who spawned]
-- @param lightSpawn [Boolean Whether this was a light spawn]
-- @param changeClass [Boolean Whether the player spawned because they changed class]
-- @param firstSpawn [Boolean Whether this is the player's first spawn]
function cwEmoteAnims:PostPlayerSpawn(player, lightSpawn, changeClass, firstSpawn)
  if !lightSpawn then
    self:MakePlayerExitStance(player, true)
  end
end

--- Called after a player spawns lightly; ends the player's emote and moves them back to where they
-- stood before it, if the emote moved them.
-- @param player [Player The player who spawned]
-- @param weapons [Any The weapons argument passed to `cw.player:LightSpawn`]
-- @param ammo [Any The ammo argument passed to `cw.player:LightSpawn`]
-- @param special [Boolean Whether this was a special light spawn]
function cwEmoteAnims:PostPlayerLightSpawn(player, weapons, ammo, special)
  self:MakePlayerExitStance(player)
end

--- Called when a player has been ragdolled; ends the player's emote in place.
-- @param player [Player The ragdolled player]
-- @param state [Number The new ragdoll state, one of the `RAGDOLL_*` enums]
-- @param ragdoll [Map The player's ragdoll info table]
function cwEmoteAnims:PlayerRagdolled(player, state, ragdoll)
  self:MakePlayerExitStance(player, true)
end

--- Called when a player attempts to fire a weapon; returns `false` while the player is in a stance.
-- @param player [Player The player firing]
-- @param bIsRaised [Boolean Whether the weapon is raised]
-- @param weapon [Weapon The weapon being fired]
-- @param bIsSecondary [Boolean Whether this is a secondary attack]
-- @return [Boolean `false` to block firing]
function cwEmoteAnims:PlayerCanFireWeapon(player, bIsRaised, weapon, bIsSecondary)
  if self:IsPlayerInStance(player) then
    return false
  end
end

--- Called at an interval while a player is connected; ends a stance emote once the player moves.
--
-- The emote stops when the player strays more than 16 units from the stance position, leaves the
-- ground, presses a movement key or stands on anything other than the world or a prop. When the
-- player is still marked as in a stance but no stance animation plays (a short emote that ended, for
-- example), the stance net vars are cleared a second later.
-- @param player [Player The player being processed]
-- @param curTime [Number The current time]
-- @param infoTable [Map The player's think info]
function cwEmoteAnims:PlayerThink(player, curTime, infoTable)
  local forcedAnimation = player:GetForcedAnimation()
  local isMoving = false
  local uniqueID = player:SteamID64()

  if player:KeyDown(IN_FORWARD) or player:KeyDown(IN_BACK) or player:KeyDown(IN_MOVELEFT)
  or player:KeyDown(IN_MOVERIGHT) then
    isMoving = true
  end

  if forcedAnimation and self.stanceList[forcedAnimation.animation] then
    local plyPos = player:GetPos()

    local tr = util.TraceLine({
      start = plyPos - Vector(0, 0, 4),
      endpos = plyPos - Vector(0, 0, 24)
    })

    if player:GetNetVar('StancePos') then
      if tr.Entity != NULL then
        if player:GetPos():Distance(player:GetNetVar('StancePos')) > 16 or !player:IsOnGround() or isMoving
        or (tr.Entity:GetClass() != 'prop_physics' and tr.Entity:GetClass() != 'prop_static'
        and tr.Entity:GetClass() != 'worldspawn') then
          player:SetForcedAnimation(false)
          player.cwPreviousPos = nil
          player:SetNetVar('StancePos', Vector(0, 0, 0))
          player:SetNetVar('StanceAng', nil)
          player:SetNetVar('StanceIdle', false)
        end
      else
        player:SetForcedAnimation(false)
        player.cwPreviousPos = nil
        player:SetNetVar('StancePos', Vector(0, 0, 0))
        player:SetNetVar('StanceAng', nil)
        player:SetNetVar('StanceIdle', false)
      end
    end
  elseif self:IsPlayerInStance(player) then
    if !timer.Exists('ExitStance'..uniqueID) then
      timer.Create('ExitStance'..uniqueID, 1, 1, function()
        if IsValid(player) then
          player:SetNetVar('StancePos', Vector(0, 0, 0))
          player:SetNetVar('StanceAng', nil)
        end
      end)
    end
  end
end

--- Called when a player is about to be ragdolled; returns `false` for a living player in a stance emote.
-- @param player [Player The player to be ragdolled]
-- @param state [Number The requested ragdoll state, one of the `RAGDOLL_*` enums]
-- @param delay [Number Seconds before the player gets up]
-- @param decay [Number Seconds before the ragdoll is removed]
-- @param ragdoll=nil [Map The player's current ragdoll info table, when they are already ragdolled]
-- @return [Boolean `false` to block the ragdoll]
function cwEmoteAnims:PlayerCanRagdoll(player, state, delay, decay, ragdoll)
  local forcedAnimation = player:GetForcedAnimation()

  if forcedAnimation and self.stanceList[forcedAnimation.animation] then
    if player:Alive() then
      return false
    end
  end
end

--- Called when a player attempts to noclip; returns `false` while the player is in a stance emote.
-- @param player [Player The player toggling noclip]
-- @return [Boolean `false` to block noclip]
function cwEmoteAnims:PlayerNoClip(player)
  local forcedAnimation = player:GetForcedAnimation()

  if forcedAnimation and self.stanceList[forcedAnimation.animation] then
    return false
  end
end
