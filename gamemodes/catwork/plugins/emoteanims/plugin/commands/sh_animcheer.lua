--- Registers the `/AnimCheer` command, which plays a two second cheer on a human character, and adds it to the Emotes
-- category of the quick menu.

local COMMAND = cw.command:New('AnimCheer')
COMMAND.tip = '#Command_Animcheer_Description'
COMMAND.flags = CMD_DEFAULT

--- Plays a two second cheer on a human player who is not in a stance emote.
function COMMAND:OnRun(player, arguments)
  local curTime = CurTime()

  if !player.cwNextStance or curTime >= player.cwNextStance then
    player.cwNextStance = curTime + 2.5

    local modelClass = cw.animation:GetModelClass(player:GetModel())

    if modelClass == 'maleHuman' or modelClass == 'femaleHuman' then
      local forcedAnimation = player:GetForcedAnimation()

      if forcedAnimation and cwEmoteAnims.stanceList[forcedAnimation.animation] then
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
