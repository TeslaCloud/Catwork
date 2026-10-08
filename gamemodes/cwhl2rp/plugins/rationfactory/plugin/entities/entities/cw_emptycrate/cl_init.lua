--- Client side of the `cw_emptycrate` entity of the Ration Factory plugin, which draws the model and a target ID with
-- how many of its ten rations the crate holds.
--
-- Originally written for the Iron Wall community.

include('shared.lua')

--- Draws how many of the ten rations the crate holds when the player looks at it.
function ENT:HUDPaintTargetID(x, y, alpha)
  y = cw.core:DrawInfo('#Factory_RationsFinished', x, y, cw.option:GetColor('target_id'), alpha)
  y = cw.core:DrawInfo('#Factory_FillState '..self:GetDTInt(1)..' / 10', x, y, Color(255, 255, 255), alpha)
end

--- Draws the crate's model.
function ENT:Draw()
  self:DrawModel()
end
