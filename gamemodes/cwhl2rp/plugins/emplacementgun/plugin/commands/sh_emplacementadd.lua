--- Registers the superadmin command `/EmplacementAdd` of the Emplacement Gun plugin, which spawns a `cw_emplacementgun`
-- where the player is looking.

local COMMAND = cw.command:New('EmplacementAdd')
COMMAND.tip = '#Command_Emplacementadd_Description'
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 's'

--- Spawns an emplacement gun where the player is looking, creating a barricade under it if needed.
function COMMAND:OnRun(player, arguments)
  local trace = player:GetEyeTraceNoCursor()
  if !trace.Hit then return end

  local emplacementGun = ents.Create('cw_emplacementgun')
  local entity = emplacementGun:SpawnFunction(player, trace)
  emplacementGun:Remove()

  if IsValid(entity) then
    cw.player:Notify(player, L('Emplacement_Added'))
  end
end

COMMAND:Register()
