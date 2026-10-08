--- Registers the operator command `/PlyRespawnStay` (aliases `/PlyRStay`, `/RespawnStay`), which respawns the target
-- player at the spot where they currently are.

local COMMAND = cw.command:New('PlyRespawnStay')
COMMAND.tip = '#Command_Plyrespawnstay_Description'
COMMAND.text = '#Command_Plyrespawnstay_Syntax'
COMMAND.arguments = 1
COMMAND.access = 'o'
COMMAND.alias = { 'PlyRStay', 'RespawnStay' }

--- Respawns the target player where they currently stand; the argument is the player name.
function COMMAND:OnRun(player, arguments)
  local target = _player.Find(arguments[1])

  if target then
    local pos = target:GetPos()
    target:Spawn()
    target:SetPos(pos)
    cw.player:Notify(player, L('Command_Plyrespawnstay_Respawned', target:GetName()))
  else
    cw.player:Notify(player, L('NotValidPlayer', arguments[1]))
  end
end

COMMAND:Register()
