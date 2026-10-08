--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

--- Called to check whether the character menu background should be drawn; hides it when a map scene is set.
--
-- @return [Boolean False while a map scene is shown, otherwise nil]
function cwMapScene:ShouldDrawCharacterBackground()
  if self.curStored then return false end
end

--- Called when the view is calculated; moves the camera to the map scene while choosing a character.
--
-- Spinning scenes slowly sway the camera's yaw back and forth.
--
-- @param player [Player The local player]
-- @param origin [Vector The default view origin]
-- @param angles [Angle The default view angles]
-- @param fov [Number The default field of view, kept as is]
-- @return [Map The view table with `origin`, `angles`, `fov`, `vm_origin` and `vm_angles`, or nil
-- when no scene applies]
function cwMapScene:CalcView(player, origin, angles, fov)
  if cw.core:IsChoosingCharacter() and self.curStored then
    local addAngles = Angle(0, 0, 0)

    if self.curStored.shouldSpin then
      addAngles = Angle(0, math.sin(CurTime() * 0.2) * 180, 0)
    end

    return {
      vm_origin = self.curStored.position + Vector(0, 0, 2048),
      vm_angles = Angle(0, 0, 0),
      origin = self.curStored.position,
      angles = self.curStored.angles + addAngles,
      fov = fov
    }
  end
end
