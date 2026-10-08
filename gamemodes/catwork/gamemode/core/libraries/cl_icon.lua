--- Defines the client-side `cw.icon` library, the chat icons shown next to player names.
--
-- An icon is a material path and a callback that says which players it applies to; `cw.icon:PlayerSet` and
-- `cw.icon:GroupSet` register one for a Steam ID or a user group. `cw.player:GetChatIcon` picks the icon, preferring
-- player icons.

library.New('icon', cw)

cw.icon.stored = cw.icon.stored or {}

--- Registers a chat icon shown next to the names of the players it applies to.
--
-- `cw.player:GetChatIcon` uses the first icon whose callback returns `true`, and
-- player icons take precedence over the others. Prints an error and does
-- nothing when an argument is missing.
--
-- ```
-- cw.icon:Add('Donator', 'icon16/heart.png', function(player)
--   return player:IsUserGroup('donator') or player:IsUserGroup('vip')
-- end)
-- ```
--
-- @param uniqueID [String Unique ID of the icon]
-- @param path [String Path of the icon material, such as `'icon16/star.png'`]
-- @param callback [Function Called with a player; returns `true` if the icon applies to them]
-- @param bIsPlayer=nil [Boolean Whether this is an icon for a specific player, which wins over group icons]
-- @see cw.icon:PlayerSet
-- @see cw.icon:GroupSet
function cw.icon:Add(uniqueID, path, callback, bIsPlayer)
  if uniqueID then
    if path then
      if callback then
        self.stored[uniqueID] = {
          path = path,
          callback = callback,
          isPlayer = bIsPlayer
        }
      else
        MsgC(Color(255, 100, 0, 255), '[CW:Icon] Error: Attempting to add icon without providing a callback.\n')
      end
    else
      MsgC(Color(255, 100, 0, 255), '[CW:Icon] Error: Attempting to add icon without providing a path..\n')
    end
  else
    MsgC(Color(255, 100, 0, 255), '[CW:Icon] Error: Attempting to add an icon without providing a uniqueID.\n')
  end
end

--- Removes a chat icon.
--
-- Prints an error when `uniqueID` is missing.
-- @param uniqueID [String Unique ID of the icon]
function cw.icon:Remove(uniqueID)
  if uniqueID then
    self.stored[uniqueID] = nil
  else
    MsgC(Color(255, 100, 0, 255), '[CW:Icon] Error: Attempting to remove an icon without providing a uniqueID.\n')
  end
end

--- Registers a chat icon for a single player.
-- @param steamID [String Steam ID of the player, as returned by `Player:SteamID`]
-- @param uniqueID [String Unique ID of the icon]
-- @param path [String Path of the icon material]
function cw.icon:PlayerSet(steamID, uniqueID, path)
  cw.icon:Add(uniqueID, path, function(player)
    if steamID == player:SteamID() then
      return true
    end
  end, true)
end

--- Registers a chat icon for every member of a user group.
-- @param group [String Name of the user group, such as `'admin'`]
-- @param uniqueID [String Unique ID of the icon]
-- @param path [String Path of the icon material]
function cw.icon:GroupSet(group, uniqueID, path)
  cw.icon:Add(uniqueID, path, function(player)
    if player:IsUserGroup(group) then
      return true
    end
  end)
end

--- Returns every registered chat icon.
-- @return [Map<Map> Icon tables (`path`, `callback`, `isPlayer`) keyed by unique ID]
function cw.icon:GetAll()
  return cw.icon.stored
end

cw.icon:GroupSet('superadmin', 'SuperAdminShield', 'icon16/shield.png')
cw.icon:GroupSet('admin', 'AdminStar', 'icon16/star.png')
cw.icon:GroupSet('operator', 'OperatorSmile', 'icon16/emoticon_smile.png')
