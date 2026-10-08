--- Registers the `/ApplySay` command, which makes the player state their name and citizen ID in a full sentence in
-- character and, when the `apply_recognise_enable` config is on, makes players within talk radius recognise them.

local COMMAND = cw.command:New('ApplySay')
COMMAND.tip = '#Command_Applysay_Description'
COMMAND.flags = CMD_DEFAULT

--- Says a full Russian sentence with the player's name and citizen ID and makes nearby players recognise them.
--
-- Combine are told they have no citizen ID instead. Recognition only happens when
-- `apply_recognise_enable` is on, for players within `talk_radius`.
function COMMAND:OnRun(player)
  local citizenID = player:GetNetVar('citizenID')
  local name = player:Name()
  local radius = config.Get('talk_radius'):Get()

  if !player:IsCombine() then
    chatbox.AddText(nil, '"Меня зовут '..name..', мой CID - #'..citizenID..'."', {
      sender = player,
      isPlayerMessage = true,
      filter = 'ic',
      radius = radius,
      textColor = Color(255, 255, 200, 255)
    })
  else
    cw.player:Notify(player, L('Apply_NoCIDSorry'))
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
