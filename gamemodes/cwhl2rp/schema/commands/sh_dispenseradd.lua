--- Registers `/DispenserAdd`, a superadmin command that spawns a `cw_rationdispenser` where the player is looking.

local COMMAND = cw.command:New('DispenserAdd')
COMMAND.tip = '#Command_Dispenseradd_Description'
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 's'

--- Spawns a ration dispenser where the player is looking, facing them; takes no arguments.
function COMMAND:OnRun(player, arguments)
  local trace = player:GetEyeTraceNoCursor()
  local entity = ents.Create('cw_rationdispenser')

  entity:SetPos(trace.HitPos)
  entity:Spawn()

  if IsValid(entity) then
    entity:SetAngles(Angle(0, player:EyeAngles().yaw + 180, 0))

    cw.player:Notify(player, L('Dispenser_Added'))
  end
end

COMMAND:Register()
