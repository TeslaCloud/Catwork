--- Registers the admin command `/MapChange` (alias `/Changelevel`), which saves data and changes to the given map after
-- a delay of five seconds by default.

local COMMAND = cw.command:New('MapChange')
COMMAND.tip = '#Command_Mapchange_Description'
COMMAND.text = '#Command_Mapchange_Syntax'
COMMAND.access = 'a'
COMMAND.arguments = 1
COMMAND.optionalArguments = 1
COMMAND.alias = { 'Changelevel' }

--- Saves data and changes the map after a delay; arguments are the map name and optional delay in seconds.
--
-- The delay defaults to five seconds.
function COMMAND:OnRun(player, arguments)
  local sNewMap = string.lower(arguments[1])

  if file.Exists('maps/'..sNewMap..'.bsp', 'GAME') then
    cw.player:NotifyAll(L('Command_Mapchange_Changing', player:Name(), sNewMap, tonumber(arguments[2]) or 5))

    timer.Simple(tonumber(arguments[2]) or 5, function()
      hook.Run('PreSaveData')
        hook.Run('SaveData')
      hook.Run('PostSaveData')

      hook.Run('OnMapChange', sNewMap)

      RunConsoleCommand('changelevel', sNewMap)
    end)
  else
    cw.player:Notify(player, L('NotValidMap', sNewMap))
  end
end

COMMAND:Register()
