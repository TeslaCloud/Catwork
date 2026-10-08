--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

--- Ends a player's emote and clears the stance net vars.
--
-- Unless `keepPosition` is set, a player moved by the emote (such as `AnimSitWall`) is put back at the
-- position they had before it. If another player stands within 32 units of that position, the player
-- is notified and stays in the stance.
-- @param player [Player The player to take out of the stance]
-- @param keepPosition=nil [Boolean Whether to leave the player where they are]
function cwEmoteAnims:MakePlayerExitStance(player, keepPosition)
  if player.cwPreviousPos and !keepPosition then
    for k, v in ipairs(_player.GetAll()) do
      if v != player and v:GetPos():Distance(player.cwPreviousPos) <= 32 then
        cw.player:Notify(player, L('EmoteAnims_PositionBlocked'))

        return
      end
    end

    cw.player:SetSafePosition(player, player.cwPreviousPos)
  end

  player:SetForcedAnimation(false)
  player.cwPreviousPos = nil
  player:SetNetVar('StancePos', Vector(0, 0, 0))
  player:SetNetVar('StanceAng', nil)
  player:SetNetVar('StanceIdle', false)
end
