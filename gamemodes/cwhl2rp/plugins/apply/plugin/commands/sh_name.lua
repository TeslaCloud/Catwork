--- Registers the `/Name` command, which makes the player say their name in character (as a unit for Combine) and, when
-- the `apply_recognise_enable` config is on, makes players within talk radius recognise them.

local COMMAND = cw.command:New('Name')
COMMAND.tip = '#Command_Name_Description'
COMMAND.flags = CMD_DEFAULT

--- Says the player's name in character (as a unit for Combine) and makes nearby players recognise them.
--
-- Recognition only happens when `apply_recognise_enable` is on, for players within `talk_radius`.
function COMMAND:OnRun(player)
  local name = player:Name()
  local radius = config.Get('talk_radius'):Get()

  if !player:IsCombine() then
    chatbox.AddText(nil, '"'..name..'."', {
      sender = player,
      isPlayerMessage = true,
      filter = 'ic',
      radius = radius,
      textColor = Color(255, 255, 200, 255)
    })
  else
    chatbox.AddText(nil, '"Юнит '..name..'."', {
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
