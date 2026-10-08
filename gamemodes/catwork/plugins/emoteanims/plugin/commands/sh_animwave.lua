--- Registers the `/AnimWave` command, which plays a two second wave on a human character, optionally the `Close`
-- variant, and adds it to the Emotes category of the quick menu.

local COMMAND = cw.command:New('AnimWave')
COMMAND.tip = '#Command_Animwave_Description'
COMMAND.text = '#Command_Animwave_Syntax'
COMMAND.flags = CMD_DEFAULT
COMMAND.optionalArguments = 1

--- Plays a two second wave on a human player; `Close` waves at someone nearby.
function COMMAND:OnRun(player, arguments)
  local curTime = CurTime()

  if !player.cwNextStance or curTime >= player.cwNextStance then
    player.cwNextStance = curTime + 2.5

    local modelClass = cw.animation:GetModelClass(player:GetModel())

    if modelClass == 'maleHuman' or modelClass == 'femaleHuman' then
      local forcedAnimation = player:GetForcedAnimation()
      local action = string.lower(arguments[1] or '')

      if forcedAnimation and cwEmoteAnims.stanceList[forcedAnimation.animation] then
        cw.player:Notify(player, L('CannotActionRightNow'))
      else
        if action == 'close' then
          player:SetForcedAnimation('wave_close', 2)
        else
          player:SetForcedAnimation('wave', 2)
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
  cw.quickmenu:AddCommand('#Emotes_animWave', '#Emotes', COMMAND.name, {
    '#Emotes_animWave_Close',
    '#Emotes_animWave_Normal'
  })
end
