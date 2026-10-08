--- Server-side part of the Catwork Dev Plugin, which defines `catDev:IsDeveloper` to check whether a player is a
-- Catwork developer.
--
-- A developer is a superadmin whose Steam ID is in `catDev.authorizedIDs` or whose hashed Steam ID is in
-- `catDev.authorizedHashes`; being listed never grants anything to a player who is not a superadmin already. The
-- `/SetCharData` command uses it.

--- Returns whether a player is a Catwork developer.
--
-- Developers are superadmins whose Steam ID is in `catDev.authorizedIDs`, or whose hashed Steam ID is in
-- `catDev.authorizedHashes`. The lists alone never grant anything: the player has to be a superadmin
-- already.
--
-- @param player [Player The player to check; anything that is not a valid player returns false]
-- @return [Boolean Whether the player is a developer]
function catDev:IsDeveloper(player)
  if !IsValid(player) or !player:IsPlayer() or !player:IsSuperAdmin() then
    return false
  end

  local steamID = player:SteamID()

  return self.authorizedIDs[steamID] == true or self.authorizedHashes[util.MD5(steamID)] != nil
end
