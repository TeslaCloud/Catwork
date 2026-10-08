--- Server-side hooks of the Observer Mode plugin that turn a noclip attempt into the `/Observer` command and keep
-- observers hidden.
--
-- `PlayerThink` makes noclipping players invisible and non-solid, and takes players who no longer qualify out of
-- observer mode.

--- Called when a player tries to noclip; runs the `Observer` command for them instead.
--
-- @param player [Player The player trying to noclip]
-- @return [Boolean Always false, so the engine noclip never happens]
function cwObserverMode:PlayerNoClip(player)
  cw.player:RunClockworkCommand(player, 'Observer')
  return false
end

--- Called periodically for every player; keeps observers invisible and takes others out of observer mode.
--
-- A noclipping player who is alive, not in a vehicle, not ragdolled and not held is hidden and made
-- non-solid. Players who are still flagged as observers but no longer qualify are taken out with
-- `cwObserverMode:MakePlayerExitObserverMode`.
--
-- @param player [Player The player being updated]
-- @param curTime [Number The current time]
-- @param infoTable [Map The player's info table for this think]
function cwObserverMode:PlayerThink(player, curTime, infoTable)
  if !player:InVehicle() and !player:IsRagdolled() and !player:IsBeingHeld()
  and player:Alive() and player:GetMoveType() == MOVETYPE_NOCLIP then
    local color = player:GetColor()
      player:DrawWorldModel(false)
      player:DrawShadow(false)
      player:SetNoDraw(true)
      player:SetNotSolid(true)
    player:SetColor(Color(color.r, color.g, color.b, 0))
  elseif player.cwObserverMode then
    if !player.cwObserverReset then
      cwObserverMode:MakePlayerExitObserverMode(player)
    end
  end
end
