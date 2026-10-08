--- Registers the superadmin command `/Overwatch` of the Extra Commands plugin, which sends a green Overwatch message to
-- every Combine player.

local COMMAND = cw.command:New('Overwatch')
COMMAND.tip = '#Command_Overwatch_Description'
COMMAND.text = '#Command_Overwatch_Syntax'
COMMAND.access = 's'
COMMAND.arguments = 1

--- Sends a green Overwatch message to every Combine player.
--
-- Messages shorter than 6 characters are rejected.
function COMMAND:OnRun(player, arguments)
  local message = table.concat(arguments, ' ')

  if string.utf8len(message) >= 6 then
    local listeners = {}

    for k, v in ipairs(_player.GetAll()) do
      if Schema:PlayerIsCombine(v) then
        table.insert(listeners, v)
      end
    end

    chatbox.AddText(listeners, message, {
      suffix = '#ExtraCommands_OverwatchSays: ',
      playerName = '',
      sender = player,
      isPlayerMessage = true,
      filter = 'ic',
      radius = 0,
      textColor = Color(10, 200, 10, 255),
      forceName = true,
      data = { overwatch = true }
    })
  else
    cw.player:Notify(player, L('ExtraCommands_MessageTooShort'))
  end
end

COMMAND:Register()
