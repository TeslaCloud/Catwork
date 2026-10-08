--- Registers `/VendorAdd`, an admin command that spawns a `cw_vendingmachine` with a random stock of 10 to 20 where the
-- player is looking.

local COMMAND = cw.command:New('VendorAdd')
COMMAND.tip = '#Command_Vendoradd_Description'
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 'a'

--- Spawns a vending machine with random stock where the player is looking; takes no arguments.
function COMMAND:OnRun(player, arguments)
  local trace = player:GetEyeTraceNoCursor()
  local entity = ents.Create('cw_vendingmachine')

  entity:SetPos(trace.HitPos + Vector(0, 0, 48))
  entity:Spawn()

  if IsValid(entity) then
    entity:SetStock(math.random(10, 20), true)
    entity:SetAngles(Angle(0, player:EyeAngles().yaw + 180, 0))

    cw.player:Notify(player, L('VendingMachine_Added'))
  end
end

COMMAND:Register()
