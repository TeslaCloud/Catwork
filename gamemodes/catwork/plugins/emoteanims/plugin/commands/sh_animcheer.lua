--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New('AnimCheer')
COMMAND.tip = '#Command_Animcheer_Description'
COMMAND.flags = CMD_DEFAULT

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
  local curTime = CurTime()

  if !player.cwNextStance or curTime >= player.cwNextStance then
    player.cwNextStance = curTime + 2.5

    local modelClass = cw.animation:GetModelClass(player:GetModel())

    if modelClass == 'maleHuman' or modelClass == 'femaleHuman' then
      local forcedAnimation = player:GetForcedAnimation()

      if forcedAnimation and cwEmoteAnimscwEmoteAnims[forcedAnimation.animation] then
        cw.player:Notify(player, L('CannotActionRightNow'))
      else
        if modelClass == 'femaleHuman' or math.random(1, 2) == 1 then
          player:SetForcedAnimation('cheer1', 2)
        else
          player:SetForcedAnimation('cheer2', 2)
        end

        player:SetNetVar('StancePos', player:GetPos())
        player:SetNetVar('StanceAng', player:GetAngles())
        player:SetNetVar('StanceIdle', false)
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
  cw.quickmenu:AddCommand('#Emotes_animCheer', '#Emotes', COMMAND.name)
end
