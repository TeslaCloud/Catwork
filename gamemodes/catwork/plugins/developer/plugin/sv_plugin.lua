-- Developers are superadmins whose SteamID is in catDev.authorizedIDs (or, hashed, in catDev.authorizedHashes).
-- The lists alone never grant anything: the player has to be a superadmin already.
function catDev:IsDeveloper(player)
  if !IsValid(player) or !player:IsPlayer() or !player:IsSuperAdmin() then
    return false
  end

  local steamID = player:SteamID()

  return self.authorizedIDs[steamID] == true or self.authorizedHashes[util.MD5(steamID)] != nil
end
