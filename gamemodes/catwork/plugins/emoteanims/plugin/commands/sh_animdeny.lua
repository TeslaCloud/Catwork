--- Registers the `/AnimDeny` command, which makes a Civil Protection character hold a hand out to deny access, and adds
-- it to the Emotes category of the quick menu.

local COMMAND = cw.command:New('AnimDeny')
COMMAND.tip = '#Command_Animdeny_Description'
COMMAND.flags = CMD_DEFAULT

--- Plays the Civil Protection harass gesture (`harassfront2`) on a player who is not in a stance emote.
function COMMAND:OnRun(player, arguments)
  local curTime = CurTime()

  if !player.cwNextStance or curTime >= player.cwNextStance then
    player.cwNextStance = curTime + 2

    local modelClass = cw.animation:GetModelClass(player:GetModel())

    if modelClass == 'civilProtection' then
      local forcedAnimation = player:GetForcedAnimation()

      if forcedAnimation and cwEmoteAnims.stanceList[forcedAnimation.animation] then
        cw.player:Notify(player, L('CannotActionRightNow'))
      else
        player:SetForcedAnimation('harassfront2', 1.5)
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
  cw.quickmenu:AddCommand('#Emotes_animDeny', '#Emotes', COMMAND.name)
end
