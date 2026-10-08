--- Client-side hooks of the Emote Anims plugin that show the local player in third person while they emote and render
-- emoting players at their stance angles.
--
-- `CalcViewAdjustTable` puts the camera just in front of the head for idle stances and up to 128 units behind the
-- player for other emotes, using the `StanceAng` and `StanceIdle` net vars.

--- Called to decide whether the local player is drawn; draws them while they are in a stance.
-- @return [Boolean Whether the local player is in a stance]
function cwEmoteAnims:ShouldDrawLocalPlayer()
  return self:IsPlayerInStance(cw.client)
end

--- Called when a player's animation is updated; renders an emoting player at their stance angles.
-- @param player [Player The player being animated]
function cwEmoteAnims:UpdateAnimation(player)
  local stanceAng = player:GetNetVar('StanceAng')

  if stanceAng then
    player:SetRenderAngles(stanceAng)
  end
end

--- Called when the view table is adjusted; moves the camera out of the local player's head while they
-- emote.
--
-- Idle stances place the camera just in front of the head, other emotes up to 128 units behind it.
-- @param view [Map The view table; `origin` is changed in place]
function cwEmoteAnims:CalcViewAdjustTable(view)
  if self:IsPlayerInStance(cw.client) and cw.client:GetNetVar('StanceAng') then
    local defaultOrigin = view.origin
    local idleStance = cw.client:GetNetVar('StanceIdle')
    local traceLine = nil
    local headBone = 'ValveBiped.Bip01_Head1'
    local position = cw.client:EyePos()
    local angles = cw.client:GetNetVar('StanceAng'):Forward()

    if string.find(cw.client:GetModel(), 'vortigaunt') then
      headBone = 'ValveBiped.Head'
    end

    if idleStance then
      local bonePosition = cw.client:GetBonePosition(cw.client:LookupBone(headBone))

      if bonePosition then
        position = bonePosition + Vector(0, 0, 8)
      end
    end

    if defaultOrigin then
      if idleStance then
        traceLine = util.TraceLine({
          start = position,
          endpos = position + (angles * 16),
          filter = cw.client
        })
      else
        traceLine = util.TraceLine({
          start = position,
          endpos = position - (angles * 128),
          filter = cw.client
        })
      end

      if traceLine.Hit then
        view.origin = traceLine.HitPos + (angles * 4)

        if view.origin:Distance(position) <= 32 then
          view.origin = defaultOrigin
        end
      else
        view.origin = traceLine.HitPos
      end
    end
  end
end
