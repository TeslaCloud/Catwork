--- Client side of the `cw_notepad` entity of the Notepad plugin, which draws the model and a target ID that says
-- whether the notepad is written or blank.

include('shared.lua')

--- Draws the notepad's name and whether it is written or blank when looked at.
function ENT:HUDPaintTargetID(x, y, alpha)
  local colorTargetID = cw.option:GetColor('target_id')
  local colorWhite = cw.option:GetColor('white')

  y = cw.core:DrawInfo('#Notepad_Title', x, y, colorTargetID, alpha)

  if self:GetDTBool(0) then
    y = cw.core:DrawInfo('#Notepad_Written', x, y, colorWhite, alpha)
  else
    y = cw.core:DrawInfo('#Notepad_Blank', x, y, colorWhite, alpha)
  end
end

--- Draws the notepad's model.
function ENT:Draw()
  self:DrawModel()
end
