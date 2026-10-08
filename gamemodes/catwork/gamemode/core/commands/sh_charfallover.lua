--- Registers the `/CharFallOver` command (alias `/Fallover`), which makes the caller fall over as a ragdoll, optionally
-- for 2 to 30 seconds.

local COMMAND = cw.command:New('CharFallOver')
COMMAND.tip = '#Command_Charfallover_Description'
COMMAND.text = '#Command_Charfallover_Syntax'
COMMAND.flags = CMD_DEFAULT
COMMAND.optionalArguments = 1
COMMAND.alias = { 'Fallover' }
COMMAND.cooldown = 5

--- Makes the caller fall over; the optional argument is how many seconds to stay down (2 to 30).
--
-- Can be used at most once every five seconds, and not in a vehicle or while noclipping.
function COMMAND:OnRun(player, arguments)
  local curTime = CurTime()

  if !player.cwNextFallTime or curTime >= player.cwNextFallTime then
    player.cwNextFallTime = curTime + 5

    if !player:InVehicle() and !cw.player:IsNoClipping(player) then
      local seconds = tonumber(arguments[1])

      if seconds and seconds == seconds then
        seconds = math.Clamp(seconds, 2, 30)
      else
        seconds = nil
      end

      if !player:IsRagdolled() then
        cw.player:SetRagdollState(player, RAGDOLL_FALLENOVER, seconds)

        player:SetDTBool(BOOL_FALLENOVER, true)
      end
    else
      cw.player:Notify(player, L('CannotActionRightNow'))
    end
  end
end

COMMAND:Register()
