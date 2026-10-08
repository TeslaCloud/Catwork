--- Registers the `/AnimSit` command, which makes a human character sit down on the ground or stand back up, and adds it
-- to the Emotes category of the quick menu.

local COMMAND = cw.command:New('AnimSit')
COMMAND.tip = '#Command_Animsit_Description'
COMMAND.flags = CMD_DEFAULT

--- Makes a human player sit down on the ground, or stand back up when already sitting.
function COMMAND:OnRun(player, arguments)
  local curTime = CurTime()

  if !player.cwNextStance or curTime >= player.cwNextStance then
    player.cwNextStance = curTime + 2

    local modelClass = cw.animation:GetModelClass(player:GetModel())
    local position = player:GetPos()

    if modelClass == 'maleHuman' or modelClass == 'femaleHuman' then
      local forcedAnimation = player:GetForcedAnimation()

      if forcedAnimation
      and (forcedAnimation.animation == 'sit_ground' or forcedAnimation.animation == 'idle_to_sit_ground'
      or forcedAnimation.animation == 'sit_ground_to_idle') then
        player:SetForcedAnimation(false)

        player:SetForcedAnimation('sit_ground_to_idle', 2, nil, function(player)
          cwEmoteAnims:MakePlayerExitStance(player)
        end)
      elseif !forcedAnimation or !cwEmoteAnims.stanceList[forcedAnimation.animation] then
        if player:Crouching() then
          cw.player:Notify(player, L('EmoteAnims_CannotWhileCrouching'))
        elseif player:IsOnGround() or IsValid(player:GetGroundEntity()) then
          player:SetNetVar('StancePos', player:GetPos())
          player:SetNetVar('StanceAng', player:GetAngles())
          player:SetNetVar('StanceIdle', true)
          player:SetForcedAnimation('idle_to_sit_ground', 2, nil, function(player)
            player:SetForcedAnimation('sit_ground', 0, nil, function()
              local forcedAnimation = player:GetForcedAnimation()

              if !forcedAnimation or forcedAnimation.animation != 'sit_ground_to_idle' then
                cwEmoteAnims:MakePlayerExitStance(player)
              end
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
  cw.quickmenu:AddCommand('#Emotes_animSit', '#Emotes', COMMAND.name)
end
