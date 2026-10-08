--- Registers the `/NutVendorAdd` admin command, which spawns a `nut_vend` vending machine where the player is looking.

local COMMAND = cw.command:New('NutVendorAdd')
COMMAND.tip = '#Command_Nutvendoradd_Description'
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 'a'

--- Spawns a vending machine where the player is looking and notifies them.
function COMMAND:OnRun(player, arguments)
  local trace = player:GetEyeTraceNoCursor()
  local entity = scripted_ents.Get('nut_vend'):SpawnFunction(player, trace)

  if IsValid(entity) then
    cw.player:Notify(player, L('NutVend_Added'))
  end
end

COMMAND:Register()
