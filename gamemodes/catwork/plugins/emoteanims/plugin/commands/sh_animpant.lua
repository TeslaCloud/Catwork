--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New('AnimPant')
COMMAND.tip = '#Command_Animpant_Description'
COMMAND.flags = CMD_DEFAULT

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
  local curTime = CurTime()

  if !player.cwNextStance or curTime >= player.cwNextStance then
    player.cwNextStance = curTime + 2

    local modelClass = cw.animation:GetModelClass(player:GetModel())
    local position = player:GetPos()

    if modelClass == 'maleHuman' or modelClass == 'femaleHuman' then
      local forcedAnimation = player:GetForcedAnimation()

      if forcedAnimation
      and (forcedAnimation.animation == 'd2_coast03_postbattle_idle02'
      or forcedAnimation.animation == 'd2_coast03_postbattle_idle02_entry') then
        cwEmoteAnims:MakePlayerExitStance(player)
      elseif !forcedAnimation or !cwEmoteAnimscwEmoteAnims[forcedAnimation.animation] then
        if player:Crouching() then
          cw.player:Notify(player, L('EmoteAnims_CannotWhileCrouching'))
        elseif player:IsOnGround() or IsValid(player:GetGroundEntity()) then
          player:SetNetVar('StancePos', player:GetPos())
          player:SetNetVar('StanceAng', player:GetAngles())
          player:SetNetVar('StanceIdle', false)
          player:SetForcedAnimation('d2_coast03_postbattle_idle02_entry', 1.5, nil, function(player)
            player:SetForcedAnimation('d2_coast03_postbattle_idle02', 0, nil, function()
              cwEmoteAnims:MakePlayerExitStance(player)
            end)
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
  cw.quickmenu:AddCommand('#Emotes_animPant', '#Emotes', COMMAND.name)
end
