--- Registers the superadmin command `/FactoryDispenserAdd` of the Ration Factory plugin, which spawns a
-- `cw_factorydispenser` for Breen's Water or citizen supplements where the player is looking.
--
-- Originally written for the Iron Wall community.

local COMMAND = cw.command:New('FactoryDispenserAdd')
COMMAND.tip = '#Command_Factorydispenseradd_Description'
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 's'
COMMAND.arguments = 1
COMMAND.text = '#Command_Factorydispenseradd_Syntax'

--- Spawns a factory dispenser where the player looks, facing them.
--
-- Argument 1 picks the item it dispenses: `1` for `breens_water`, `2` for `citizen_supplements`.
function COMMAND:OnRun(player, arguments)
  local trace = player:GetEyeTraceNoCursor()
  local entity = ents.Create('cw_factorydispenser')

  entity:SetPos(trace.HitPos + Vector(0, 0, 10))
  entity:Spawn()

  if IsValid(entity) then
    entity:SetAngles(Angle(90, player:EyeAngles().yaw + 180, 0))
    -- Anything but 1 gives the second type, as it did when the entity ignored a type it did not know.
    local spawnType = (tonumber(arguments[1]) == 1 and TYPE_WATERCAN) or TYPE_SUPPLIES

    entity:SetSpawnType(spawnType)

    cw.player:Notify(player, L('Factory_DispenserAdded', spawnType + 1))
  end
end

COMMAND:Register()
