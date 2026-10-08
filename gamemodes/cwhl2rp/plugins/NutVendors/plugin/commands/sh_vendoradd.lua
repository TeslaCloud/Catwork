--- Registers the `/NutVendorAdd` admin command, which spawns a `nut_vend` vending machine where the player is looking.

local COMMAND = cw.command:New('NutVendorAdd')
COMMAND.tip = '#Command_Nutvendoradd_Description'
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 'a'

--- Spawns a vending machine where the player is looking and notifies them.
function COMMAND:OnRun(player, arguments)
  local trace = player:GetEyeTraceNoCursor()
  -- local entity = ents.Create("nut_vend")
  local entity = scripted_ents.Get('nut_vend'):SpawnFunction(player, trace)

  -- entity:SetPos(trace.HitPos + Vector(0, 0, 48))
  -- entity:SpawnFunction(player, trace)

  if IsValid(entity) then
    -- entity:SetStock(math.random(10, 20), true)
    -- entity:SetAngles(Angle(0, player:EyeAngles().yaw + 180, 0))

    cw.player:Notify(player, L('NutVend_Added'))
  end
end

COMMAND:Register()
