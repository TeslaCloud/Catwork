--[[
  Catwork � 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

include('shared.lua')

--- Draws the pile's model.
function ENT:Draw()
  self:DrawModel()
end

--- Does nothing on the client.
function ENT:Initialize()
end

--- Does nothing on the client.
function ENT:Think()
end
