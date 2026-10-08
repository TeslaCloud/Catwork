--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

util.Include('shared.lua')

--- Draws the salesman's name and physical description when the `SalesmanTargetID` hook returns a true value.
function ENT:HUDPaintTargetID(x, y, alpha)
  if hook.Run('SalesmanTargetID', self, x, y, alpha) then
    local colorTargetID = cw.option:GetColor('target_id')
    local colorWhite = cw.option:GetColor('white')
    local physDesc = self:GetNWString('PhysDesc')
    local name = self:GetNWString('Name')

    y = cw.core:DrawInfo(name, x, y, colorTargetID, alpha)

    if physDesc != '' then
      y = cw.core:DrawInfo(physDesc, x, y, colorWhite, alpha)
    end
  end
end

--- Enables automatic frame advance so the salesman's animation plays.
function ENT:Initialize()
  self.AutomaticFrameAdvance = true
end

--- Advances the salesman's animation every frame.
function ENT:Think()
  self:FrameAdvance(FrameTime())
  self:NextThink(CurTime())
end
