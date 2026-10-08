--[[
  Author: Arbiter
  Clockwork Version: 0.88a.

  Credits:	A small part of this code comes from kurozael's DoorCommands Plugin.
        Heavily based off the works of Cervidae Kosmonaut in Faction Doors.
--]]

--- Server-side hooks of the Personal Doors plugin, which restore the personal doors once the map entities are loaded
-- and grant a door's personal owners basic access to it.
--
-- `PlayerDoesHaveDoorAccess` matches the player's character name, ignoring case, against the door's `_OwningPersons`
-- table.

local PLUGIN = PLUGIN

--- Called after Catwork has loaded all map entities; restores the personal door owners.
function PLUGIN:ClockworkInitPostEntity()
  self:LoadDoorData()
end

--- Called when a player's access to a door is checked; grants basic access to the door's personal owners.
--
-- Owners are matched by character name, ignoring case.
-- @param player [Player The player whose access is checked]
-- @param door [Entity The door]
-- @param access [Number The `DOOR_ACCESS_*` level being checked; only `DOOR_ACCESS_BASIC` is granted]
-- @param isAccurate [Boolean Whether the exact access level must match]
-- @return [Boolean `true` for a personal owner, otherwise `nil` to let other hooks decide]
function PLUGIN:PlayerDoesHaveDoorAccess(player, door, access, isAccurate)
  if door._OwningPersons and access == DOOR_ACCESS_BASIC then
    local owningPerson = player:Name()

    if owningPerson and door._OwningPersons[string.lower(owningPerson)] then
      return true
    end
  end
end
