--[[
  © 2013 CloudSixteen.com do not share, re-distribute or modify
  without permission of its author (kurozael@gmail.com).
--]]

DEFINE_BASECLASS('base_gmodentity')

ENT.Type = 'anim'
ENT.Author = 'SchwarzKruppzo'
ENT.PrintName = 'Combine Monitor s2120'
ENT.Category = 'HL2RP'
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.UsableInVehicle = false
ENT.PhysgunDisabled = false

--- Sets up the networked strings 0 to 2 (the three text lines), 3 (the access level) and int 4 (`status`).
--
-- The status is read and written as int 5 everywhere else: 0 is normal, 1 destroyed and
-- 2 error.
function ENT:SetupDataTables()
  self:DTVar('String', 0, 'text1')
  self:DTVar('String', 1, 'text2')
  self:DTVar('String', 2, 'text3')
  self:DTVar('String', 3, 'level')
  self:DTVar('Int', 4, 'status') // 0 - normal; 1 - destroyed; 2 - error
end
