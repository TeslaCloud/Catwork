--- Registers the `/ApplySay` command, which makes the player state their name and citizen ID in a full sentence in
-- character and, when the `apply_recognise_enable` config is on, makes players within talk radius recognise them.

local PLUGIN = PLUGIN

local COMMAND = cw.command:New('ApplySay')
COMMAND.tip = '#Command_Applysay_Description'
COMMAND.flags = CMD_DEFAULT
COMMAND.cooldown = 2

--- Says a full Russian sentence with the player's name and citizen ID and makes nearby players recognise them.
--
-- Combine and characters without a citizen ID are told they have none instead. Recognition only happens
-- when `apply_recognise_enable` is on, for players within `talk_radius`.
function COMMAND:OnRun(player)
  local citizenID = player:GetNetVar('citizenID')

  if player:IsCombine() or !citizenID or citizenID == '' then
    return cw.player:Notify(player, L('Apply_NoCIDSorry'))
  end

  local radius = config.Get('talk_radius'):Get()

  chatbox.AddText(nil, '"Меня зовут '..player:Name()..', мой CID - #'..citizenID..'."', {
    sender = player,
    isPlayerMessage = true,
    filter = 'ic',
    radius = radius,
    textColor = Color(255, 255, 200, 255)
  })

  PLUGIN:RecogniseNearby(player, radius)
end

COMMAND:Register()
