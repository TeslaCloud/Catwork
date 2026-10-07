--[[
  © 2016 TeslaCloud Studios.
  Feel free to use, edit or share the plugin, but
  do not re-distribute without the permission of it's author.
--]]

local COMMAND = cw.command:New('Overwatch')
COMMAND.tip = '#Command_Overwatch_Description'
COMMAND.text = '#Command_Overwatch_Syntax'
COMMAND.access = 's'
COMMAND.arguments = 1

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
  local message = tostring(table.concat(arguments, ' '))

  if isstring(message) and string.len(message) >= 6 then
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
