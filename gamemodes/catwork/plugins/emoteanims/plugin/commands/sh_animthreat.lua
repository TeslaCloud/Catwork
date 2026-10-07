--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New('AnimThreat')
COMMAND.tip = '#Command_Animthreat_Description'
COMMAND.text = '#Command_Animthreat_Syntax'
COMMAND.flags = CMD_DEFAULT
COMMAND.optionalArguments = 1

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
  local curTime = CurTime()

  if !player.cwNextStance or curTime >= player.cwNextStance then
    player.cwNextStance = curTime + 2

    local modelClass = cw.animation:GetModelClass(player:GetModel())
    local position = player:GetPos()

    if modelClass == 'civilProtection' then
      local forcedAnimation = player:GetForcedAnimation()
      local animation = 'plazathreat1'

      if cw.core:ToBool(arguments[1]) then
        animation = 'plazathreat2'
      end

      if forcedAnimation
      and (forcedAnimation.animation == 'plazathreat1' or forcedAnimation.animation == 'plazathreat2') then
        cwEmoteAnims:MakePlayerExitStance(player)
      elseif !forcedAnimation or !cwEmoteAnims.stanceList[forcedAnimation.animation] then
        if player:Crouching() then
          cw.player:Notify(player, L('EmoteAnims_CannotWhileCrouching'))
        elseif player:IsOnGround() or IsValid(player:GetGroundEntity()) then
          player:SetNetVar('StancePos', player:GetPos())
          player:SetNetVar('StanceAng', player:GetAngles())
          player:SetNetVar('StanceIdle', true)
          player:SetForcedAnimation(animation, 0, nil, function()
            cwEmoteAnims:MakePlayerExitStance(player)
          end)
        else
          cw.player:Notify(player, L('EmoteAnims_MustStandOnGround'))
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
  cw.quickmenu:AddCommand('#Emotes_animThreat', '#Emotes', COMMAND.name)
end
