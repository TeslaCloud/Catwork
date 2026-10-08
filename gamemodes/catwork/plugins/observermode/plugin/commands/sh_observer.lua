--- Registers the `/Observer` operator command, which makes the player enter or leave observer mode.

local COMMAND = cw.command:New('Observer')
COMMAND.tip = '#Command_Observer_Description'
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 'o'

--- Toggles observer mode for the player; does nothing while dead, ragdolled or still leaving observer mode.
function COMMAND:OnRun(player, arguments)
  if player:Alive() and !player:IsRagdolled() and !player.cwObserverReset then
    if player:GetMoveType(player) == MOVETYPE_NOCLIP then
      cwObserverMode:MakePlayerExitObserverMode(player)
    else
      cwObserverMode:MakePlayerEnterObserverMode(player)
    end
  end
end

COMMAND:Register()
