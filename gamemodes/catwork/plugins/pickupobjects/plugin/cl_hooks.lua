--- Client-side hooks of the Pickup Objects plugin that show a notice while the local player's ragdoll is being dragged
-- and stop them from getting up.
--
-- Also extends the instructions of the `cw_hands` weapon with the pickup, throw and drop controls.

--- Called to get the full-screen text; shows a "being dragged" notice while the local player's ragdoll
-- is carried.
-- @return [Map Screen text info with `alpha` and `title`, or `nil` when the player is not dragged]
function cwPickupObjects:GetScreenTextInfo()
  local blackFadeAlpha = cw.core:GetBlackFadeAlpha()

  if cw.client:IsRagdolled() and cw.client:GetNetVar('IsDragged') then
    return {
      alpha = 255 - blackFadeAlpha,
      title = '#PickupObjects_BeingDragged'
    }
  end
end

--- Called when the local player attempts to get up; returns `false` while their ragdoll is dragged.
-- @return [Boolean `false` to stop the player getting up]
function cwPickupObjects:PlayerCanGetUp()
  local beingDragged = cw.client:GetNetVar('IsDragged') or false

  if beingDragged then
    return false
  end
end

timer.Simple(1, function()
  local SWEP = weapons.GetStored('cw_hands')

  if SWEP then
    SWEP.Instructions = L('#PickupObjects_HandsReload')..'\n'..SWEP.Instructions

    SWEP.Instructions = cw.core:Replace(SWEP.Instructions, 'Knock.', 'Knock/Pickup.')
    SWEP.Instructions = cw.core:Replace(SWEP.Instructions, 'Punch.', 'Punch/Throw.')
  end
end)
