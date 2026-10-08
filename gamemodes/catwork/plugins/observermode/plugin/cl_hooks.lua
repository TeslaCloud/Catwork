--- Client-side hooks of the Observer Mode plugin that limit the admin ESP to noclipping players, add the observer label
-- to a noclipping player's status text and block the client-side prediction of noclip.

--- Called to check whether the local player can see the admin ESP; only allows it while noclipping.
--
-- @return [Boolean False when the player is not noclipping, otherwise nil]
function cwObserverMode:PlayerCanSeeAdminESP()
  if !cw.player:IsNoClipping(cw.client) then
    return false
  end
end

--- Called to collect a player's status text; adds the observer label to noclipping players.
--
-- @param player [Player The player whose status is shown]
-- @param text [List<String> Status lines to add to]
function cwObserverMode:GetStatusInfo(player, text)
  if cw.player:IsNoClipping(player) then
    table.insert(text, '#StatusInfo_Observer')
  end
end

--- Called when the local player tries to noclip; blocks the client-side prediction of it.
--
-- @param player [Player The player trying to noclip]
-- @return [Boolean Always false]
function cwObserverMode:PlayerNoClip(player)
  return false
end
