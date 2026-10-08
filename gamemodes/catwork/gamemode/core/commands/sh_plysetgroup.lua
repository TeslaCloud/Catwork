--- Registers the superadmin command `/PlySetGroup` (alias `/SetGroup`), which puts the target player in the
-- `superadmin`, `admin` or `operator` group and respawns them.

local COMMAND = cw.command:New('PlySetGroup')
COMMAND.tip = '#Command_Plysetgroup_Description'
COMMAND.text = '#Command_Plysetgroup_Syntax'
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 's'
COMMAND.arguments = 2
COMMAND.alias = { 'SetGroup' }

--- Sets the target player's user group and respawns them; arguments are the player name and the group.
--
-- The group must be `superadmin`, `admin` or `operator`.
function COMMAND:OnRun(player, arguments)
  local target = _player.Find(arguments[1])
  local userGroup = arguments[2]

  if userGroup != 'superadmin' and userGroup != 'admin'
  and userGroup != 'operator' then
    cw.player:Notify(player, L('Command_Plysetgroup_InvalidGroup'))

    return
  end

  if target then
    if !cw.player:IsProtected(target) then
      cw.player:NotifyAll(L('Command_Plysetgroup_Set', player:Name(), target:Name(), userGroup))
        target:SetClockworkUserGroup(userGroup)
      cw.player:LightSpawn(target, true, true)
    else
      cw.player:Notify(player, L('Command_PlayerProtected', target:Name()))
    end
  else
    cw.player:Notify(player, L('NotValidPlayer', arguments[1]))
  end
end

COMMAND:Register()
