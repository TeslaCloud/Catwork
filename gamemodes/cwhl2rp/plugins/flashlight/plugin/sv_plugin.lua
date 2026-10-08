--- Defines `PLUGIN:PlayerHasFlashlight`, the server-side check of the Flashlight plugin for whether a player may use a
-- flashlight.
--
-- Combine always may; other players need the `cw_flashlight` item, or must hold the `cw_flashlight` weapon or a weapon
-- whose item has `hasFlashlight` set.

local PLUGIN = PLUGIN

--- Returns whether a player may use a flashlight.
--
-- Combine always may; other players need the `cw_flashlight` item, or must hold the flashlight
-- weapon or a weapon whose item has `hasFlashlight` set.
-- @param player [Player The player to check]
-- @return [Boolean `true` when the player has a flashlight, otherwise `nil`]
function PLUGIN:PlayerHasFlashlight(player)
  if player:IsCombine() then
    return true
  end

  if player:HasItemByID('cw_flashlight') then return true end

  local weapon = player:GetActiveWeapon()

  if IsValid(weapon) then
    local itemTable = item.GetByWeapon(weapon)

    if weapon:GetClass() == 'cw_flashlight' or (itemTable and itemTable.hasFlashlight) then
      return true
    end
  end
end
