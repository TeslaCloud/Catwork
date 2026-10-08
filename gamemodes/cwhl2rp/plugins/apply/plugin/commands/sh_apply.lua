--- Registers the `/Apply` command, which makes the player say their name and citizen ID in character and, when the
-- `apply_recognise_enable` config is on, makes players within talk radius recognise them.

local PLUGIN = PLUGIN

local COMMAND = cw.command:New('Apply')
COMMAND.tip = '#Command_Apply_Description'
COMMAND.flags = CMD_DEFAULT
COMMAND.cooldown = 2

--- Says the player's name and citizen ID in character and makes nearby players recognise them.
--
-- Combine and characters without a citizen ID are told they have none instead. Recognition only happens
-- when `apply_recognise_enable` is on, for players within `talk_radius`.
function COMMAND:OnRun(player)
  local citizenID = player:GetNetVar('citizenID')

  if player:IsCombine() or !citizenID or citizenID == '' then
    return cw.player:Notify(player, L('Apply_NoCID'))
  end

  local radius = config.Get('talk_radius'):Get()

  chatbox.AddText(nil, '"'..player:Name()..', #'..citizenID..'."', {
    sender = player,
    isPlayerMessage = true,
    filter = 'ic',
    radius = radius,
    textColor = Color(255, 255, 200, 255)
  })

  PLUGIN:RecogniseNearby(player, radius)
end

COMMAND:Register()
