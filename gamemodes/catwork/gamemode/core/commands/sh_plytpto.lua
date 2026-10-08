--- Registers the operator command `/PlyTeleportTo` (aliases `/PlyTPTo`, `/TPTo`), which teleports one player to another
-- player's position.

local COMMAND = cw.command:New('PlyTeleportTo')
COMMAND.tip = '#Command_Plytpto_Description'
COMMAND.text = '#Command_Plytpto_Syntax'
COMMAND.access = 'o'
COMMAND.arguments = 2
COMMAND.optionalArguments = 1
COMMAND.alias = { 'PlyTPTo', 'TPTo' }

--- Teleports one player to another; arguments are the player to move, the destination player and a silent flag.
function COMMAND:OnRun(player, arguments)
  local target = _player.Find(arguments[1])
  local ply = _player.Find(arguments[2])
  local isSilent = cw.core:ToBool(arguments[3])

  if target then
    if ply then
      cw.player:SetSafePosition(target, ply:GetPos())

      if !isSilent then
        cw.player:NotifyAll(L('Command_Plytpto_Teleported', player:Name(), target:Name(), ply:Name()))
      end
    else
      cw.player:Notify(player, L('NotValidPlayer', arguments[2]))
    end
  else
    cw.player:Notify(player, L('NotValidPlayer', arguments[1]))
  end
end

COMMAND:Register()
