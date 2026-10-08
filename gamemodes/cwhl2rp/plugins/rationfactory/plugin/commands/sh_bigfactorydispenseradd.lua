--- Registers the superadmin command `/FactoryBigDispenserAdd` of the Ration Factory plugin, which spawns a
-- `cw_bigfactorydispenser` for empty ration packets or empty crates where the player is looking.
--
-- Originally written for the Iron Wall community.

local COMMAND = cw.command:New('FactoryBigDispenserAdd')
COMMAND.tip = '#Command_Factorybigdispenseradd_Description'
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 's'
COMMAND.arguments = 1
COMMAND.text = '#Command_Factorybigdispenseradd_Syntax'

--- Spawns a big factory dispenser where the player looks, facing them.
--
-- Argument 1 picks what it produces: `1` for empty ration packets, `2` for empty supply crates.
function COMMAND:OnRun(player, arguments)
  local trace = player:GetEyeTraceNoCursor()
  local entity = ents.Create('cw_bigfactorydispenser')

  entity:SetPos(trace.HitPos + Vector(0, 0, 10))
  entity:Spawn()

  if IsValid(entity) then
    entity:SetAngles(Angle(90, player:EyeAngles().yaw + 180, 0))
    -- Anything but 1 gives the second type, as it did when the entity ignored a type it did not know.
    local spawnType = (tonumber(arguments[1]) == 1 and TYPE_WATERCAN) or TYPE_SUPPLIES

    entity:SetSpawnType(spawnType)

    cw.player:Notify(player, L('Factory_BigDispenserAdded', spawnType + 1))
  end
end

COMMAND:Register()
