--- Registers the `/AnimSitWall` command, which toggles a human character sitting against the wall behind them, and adds
-- it to the Emotes category of the quick menu.

local COMMAND = cw.command:New('AnimSitWall')
COMMAND.tip = '#Command_Animsitwall_Description'
COMMAND.flags = CMD_DEFAULT

--- Toggles sitting against the wall behind a human player, moving them slightly forward.
function COMMAND:OnRun(player, arguments)
  local curTime = CurTime()

  if !player.cwNextStance or curTime >= player.cwNextStance then
    player.cwNextStance = curTime + 2

    local modelClass = cw.animation:GetModelClass(player:GetModel())
    local position = player:GetPos() + Vector(0, 0, 16)
    local angles = player:GetAngles():Forward()

    if modelClass == 'maleHuman' or modelClass == 'femaleHuman' then
      local forcedAnimation = player:GetForcedAnimation()

      if forcedAnimation and forcedAnimation.animation == 'plazaidle4' then
        cwEmoteAnims:MakePlayerExitStance(player)
      elseif !forcedAnimation or !cwEmoteAnims.stanceList[forcedAnimation.animation] then
        if player:Crouching() then
          cw.player:Notify(player, L('EmoteAnims_CannotWhileCrouching'))
        else
          local traceLine = util.TraceLine({
            start = position,
            endpos = position + (angles * -20),
            filter = player
          })

          if traceLine.Hit then
            player.cwPreviousPos = player:GetPos()

            player:SetPos(player:GetPos() + (angles * 4))
            player:SetEyeAngles(traceLine.HitNormal:Angle())
            player:SetForcedAnimation('plazaidle4', 0, nil, function()
              cwEmoteAnims:MakePlayerExitStance(player)
            end)

            player:SetNetVar('StancePos', player:GetPos())
            player:SetNetVar('StanceAng', player:GetAngles())
            player:SetNetVar('StanceIdle', true)
          else
            cw.player:Notify(player, L('EmoteAnims_MustFaceAwayFromWall'))
          end
        end
      end
    else
      cw.player:Notify(player, L('EmoteAnims_ModelCannotPerform'))
    end
  else
    cw.player:Notify(player, L('EmoteAnims_CannotDoAnotherYet'))
  end
end

COMMAND:Register()

if CLIENT then
  cw.quickmenu:AddCommand('#Emotes_animSitWall', '#Emotes', COMMAND.name)
end
