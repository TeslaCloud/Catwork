--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New('PlyTakeFlags')
COMMAND.tip = '#Command_Plytakeflags_Description'
COMMAND.text = '#Command_Plytakeflags_Syntax'
COMMAND.access = 's'
COMMAND.arguments = 2
COMMAND.alias = { 'TakeFlags', 'RemoveFlags' }

--- Takes player-wide flags from the target player; arguments are the player name and the flags.
--
-- Admin flags (`a`, `s` and `o`) cannot be taken this way.
function COMMAND:OnRun(player, arguments)
  local target = _player.Find(arguments[1])

  if target then
    if string.find(arguments[2], 'a') or string.find(arguments[2], 's')
    or string.find(arguments[2], 'o') then
      cw.player:Notify(player, L('Command_CannotTakeAdminFlags'))

      return
    end

    cw.player:TakePlayerFlags(target, arguments[2])

    cw.player:NotifyAll(L('Command_Plytakeflags_Took', player:Name(), target:SteamName(), arguments[2]))
  else
    cw.player:Notify(player, L(player, 'NotValidCharacter', arguments[1]))
  end
end

COMMAND:Register()
