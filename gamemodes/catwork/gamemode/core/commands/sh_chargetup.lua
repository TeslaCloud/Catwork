--- Registers the `/CharGetUp` command, which makes a caller who fell over with `/CharFallOver` get up after five
-- seconds.

local COMMAND = cw.command:New('CharGetUp')
COMMAND.tip = '#Command_Chargetup_Description'
COMMAND.flags = CMD_DEFAULT

--- Makes the caller get up after five seconds if they fell over with `/CharFallOver`; takes no arguments.
--
-- Runs the `PlayerCanGetUp` hook first.
function COMMAND:OnRun(player, arguments)
  if player:GetRagdollState() == RAGDOLL_FALLENOVER and player:GetDTBool(BOOL_FALLENOVER)
  and cw.player:GetAction(player) != 'unragdoll' then
    if hook.Run('PlayerCanGetUp', player) then
      cw.player:SetUnragdollTime(player, 5)
      player:SetDTBool(BOOL_FALLENOVER, false)
    end
  end
end

COMMAND:Register()
