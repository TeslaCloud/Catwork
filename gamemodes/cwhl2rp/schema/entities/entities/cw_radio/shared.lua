--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

DEFINE_BASECLASS('base_gmodentity')

ENT.Type = 'anim'
ENT.Author = 'kurozael'
ENT.PrintName = 'Radio'
ENT.Spawnable = false
ENT.AdminSpawnable = false

--- Declares the off state data table variable.
function ENT:SetupDataTables()
  self:DTVar('Bool', 0, 'off')
end

--- Returns the frequency the radio is tuned to.
-- @return [String The frequency, or an empty string when none is set]
function ENT:GetFrequency()
  return self:GetNWString('frequency')
end

--- Returns whether the radio is off.
-- @return [Boolean Whether the radio is off]
function ENT:IsOff()
  return self:GetDTBool(0)
end
