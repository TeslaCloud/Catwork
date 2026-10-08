--- Registers the `/Name` command, which makes the player say their name in character (as a unit for Combine) and, when
-- the `apply_recognise_enable` config is on, makes players within talk radius recognise them.

local PLUGIN = PLUGIN

local COMMAND = cw.command:New('Name')
COMMAND.tip = '#Command_Name_Description'
COMMAND.flags = CMD_DEFAULT
COMMAND.cooldown = 2

--- Says the player's name in character (as a unit for Combine) and makes nearby players recognise them.
--
-- Recognition only happens when `apply_recognise_enable` is on, for players within `talk_radius`.
function COMMAND:OnRun(player)
  local radius = config.Get('talk_radius'):Get()
  local text = '"'..player:Name()..'."'

  if player:IsCombine() then
    text = '"Юнит '..player:Name()..'."'
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
