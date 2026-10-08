--- Registers the `/NameSay` command, which makes the player introduce themselves by name in a full sentence in
-- character (as a unit for Combine) and, when the `apply_recognise_enable` config is on, makes players within talk
-- radius recognise them.

local PLUGIN = PLUGIN

local COMMAND = cw.command:New('NameSay')
COMMAND.tip = '#Command_Namesay_Description'
COMMAND.flags = CMD_DEFAULT
COMMAND.cooldown = 2

--- Introduces the player by name in a full Russian sentence and makes nearby players recognise them.
--
-- Combine introduce themselves as a unit. Recognition only happens when `apply_recognise_enable`
-- is on, for players within `talk_radius`.
function COMMAND:OnRun(player)
  local radius = config.Get('talk_radius'):Get()
  local text = '"Меня зовут '..player:Name()..'."'

  if player:IsCombine() then
    text = '"Я - юнит '..player:Name()..'."'
  end

  chatbox.AddText(nil, text, {
    sender = player,
    isPlayerMessage = true,
    filter = 'ic',
    radius = radius,
    textColor = Color(255, 255, 200, 255)
  })

  PLUGIN:RecogniseNearby(player, radius)
end

COMMAND:Register()
