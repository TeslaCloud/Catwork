--- Registers the superadmin command `/FactoryRationDispenserAdd` of the Ration Factory plugin, which spawns a
-- `cw_factoryrationdispenser` where the player is looking.
--
-- Originally written for the Iron Wall community.

local COMMAND = cw.command:New('FactoryRationDispenserAdd')
COMMAND.tip = '#Command_Factoryrationdispenseradd_Description'
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 's'

--- Spawns a factory ration dispenser where the player looks, facing them.
function COMMAND:OnRun(player, arguments)
  local trace = player:GetEyeTraceNoCursor()
  local entity = ents.Create('cw_factoryrationdispenser')

  entity:SetPos(trace.HitPos + Vector(0, 0, 10))
  entity:Spawn()

  if IsValid(entity) then
    entity:SetAngles(Angle(0, player:EyeAngles().yaw + 180, 0))

    cw.player:Notify(player, L('Factory_RationDispenserAdded'))
  end
end

COMMAND:Register()
