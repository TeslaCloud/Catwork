--- Registers the `/NameSay` command, which makes the player introduce themselves by name in a full sentence in
-- character (as a unit for Combine) and, when the `apply_recognise_enable` config is on, makes players within talk
-- radius recognise them.

local COMMAND = cw.command:New('NameSay')
COMMAND.tip = '#Command_Namesay_Description'
COMMAND.flags = CMD_DEFAULT

--- Introduces the player by name in a full Russian sentence and makes nearby players recognise them.
--
-- Combine introduce themselves as a unit. Recognition only happens when `apply_recognise_enable`
-- is on, for players within `talk_radius`.
function COMMAND:OnRun(player)
  local name = player:Name()
  local radius = config.Get('talk_radius'):Get()

  if !player:IsCombine() then
    chatbox.AddText(nil, '"Меня зовут '..name..'."', {
      sender = player,
      isPlayerMessage = true,
      filter = 'ic',
      radius = radius,
      textColor = Color(255, 255, 200, 255)
    })
  else
    chatbox.AddText(nil, '"Я - юнит '..name..'."', {
      sender = player,
      isPlayerMessage = true,
      filter = 'ic',
      radius = radius,
      textColor = Color(255, 255, 200, 255)
    })
  end

  for k, v in ipairs(_player.GetAll()) do
    if v:GetPos():Distance(player:GetPos()) <= radius
    and config.Get('apply_recognise_enable'):Get()
    and IsValid(v) and v:HasInitialized() then
      cw.player:SetRecognises(v, player, RECOGNISE_TOTAL)
    end
  end
end

COMMAND:Register()
