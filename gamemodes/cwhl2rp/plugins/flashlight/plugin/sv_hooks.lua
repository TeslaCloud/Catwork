--- Server-side hooks of the Flashlight plugin that stop players without a flashlight from switching theirs on and turn
-- it off once they no longer have one.

local PLUGIN = PLUGIN

--- Called when a player switches their flashlight on or off; blocks turning it on without a flashlight.
-- @param player [Player The player toggling the flashlight]
-- @param on [Boolean Whether the flashlight is being turned on]
-- @return [Boolean `false` to block turning the flashlight on, otherwise `nil`]
-- @see PLUGIN:PlayerHasFlashlight
function PLUGIN:PlayerSwitchFlashlight(player, on)
  if on and !self:PlayerHasFlashlight(player) then
    return false
  end
end

--- Called at an interval while a player is connected; turns the flashlight off once the player no longer has one.
-- @param player [Player The player being updated]
-- @param curTime [Number The current `CurTime()`]
-- @param infoTable [Map The player's info table for this think]
function PLUGIN:PlayerThink(player, curTime, infoTable)
  if player:FlashlightIsOn() then
    if !self:PlayerHasFlashlight(player) then
      player:Flashlight(false)
    end
  end
end
