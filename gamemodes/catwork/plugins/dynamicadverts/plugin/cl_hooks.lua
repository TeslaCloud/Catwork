--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

--- Called after translucent renderables are drawn; draws every advert whose material has loaded.
--
-- Skips the depth and 3D skybox passes.
--
-- @param bDrawingDepth [Boolean Whether this is the depth pass]
-- @param bDrawingSkybox [Boolean Whether the skybox is being drawn]
-- @param bDrawing3DSkybox [Boolean Whether the 3D skybox is being drawn]
function cwDynamicAdverts:PostDrawTranslucentRenderables(bDrawingDepth, bDrawingSkybox, bDrawing3DSkybox)
  if bDrawing3DSkybox or bDrawingDepth then return end

  local eyePos = EyePos()
  local eyeAngles = EyeAngles()

  for k, v in pairs(self.storedList) do
    if v.material then
      cam.Start3D2D(v.position, v.angles, v.scale or 0.25)
        render.PushFilterMin(TEXFILTER.ANISOTROPIC)
        render.PushFilterMag(TEXFILTER.ANISOTROPIC)
        surface.SetDrawColor(255, 255, 255)
        surface.SetMaterial(v.material)
        surface.DrawTexturedRect(0, 0, v.width, v.height)
        render.PopFilterMag()
        render.PopFilterMin()
      cam.End3D2D()
    end
  end
end
