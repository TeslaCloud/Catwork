--- Registers the admin command `/MapRestart` (alias `/Restart`), which saves data and reloads the current map after a
-- delay of ten seconds by default.

local COMMAND = cw.command:New('MapRestart')
COMMAND.tip = '#Command_Maprestart_Description'
COMMAND.text = '#Command_Maprestart_Syntax'
COMMAND.access = 'a'
COMMAND.optionalArguments = 1
COMMAND.alias = { 'Restart' }

--- Saves data and reloads the current map after a delay; the optional argument is the delay in seconds.
--
-- The delay defaults to ten seconds.
function COMMAND:OnRun(player, arguments)
  local delay = tonumber(arguments[1]) or 10

  if isnumber(arguments[1]) then
    delay = arguments[1]
  end

  cw.player:NotifyAll(L('Command_Maprestart_Restarting', player:Name(), delay))

  timer.Simple(delay, function()
    hook.Run('PreSaveData')
      hook.Run('SaveData')
    hook.Run('PostSaveData')

    hook.Run('OnMapChange', game.GetMap())

    RunConsoleCommand('changelevel', game.GetMap())
  end)
end

COMMAND:Register()
