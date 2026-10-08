--- Client side of the `cw_forcefield` entity of the Force Fields plugin, which builds the field's client-side collision
-- mesh and draws the post and the shield stretched to the far post.
--
-- The shield is drawn on both sides with the `effects/com_shield003a` material and is hidden while the field is in
-- mode 4, which is off.

include('shared.lua')

local material = Material('effects/com_shield003a')
local boundsOffset = Vector(0, 0, 40)
local angleFlip = Angle(0, 180, 0)

--- Builds the field's collision mesh between this post and the wall up to 600 units to its side.
function ENT:Initialize()
  local data = {}
  data.start = self:GetPos() + Vector(0, 0, 50) + self:GetRight() * -16
  data.endpos = self:GetPos() + Vector(0, 0, 50) + self:GetRight() * -600
  data.filter = self
  local trace = util.TraceLine(data)

  local verts = {
    { pos = Vector(0, 0, -35) },
    { pos = Vector(0, 0, 150) },
    { pos = self:WorldToLocal(trace.HitPos - Vector(0, 0, 50)) + Vector(0, 0, 150) },
    { pos = self:WorldToLocal(trace.HitPos - Vector(0, 0, 50)) + Vector(0, 0, 150) },
    { pos = self:WorldToLocal(trace.HitPos - Vector(0, 0, 50)) - Vector(0, 0, 35) },
    { pos = Vector(0, 0, -35) }
  }

  self:PhysicsFromMesh(verts)
  self:EnableCustomCollisions(true)
end

--- Draws the post and the shield on both sides of the field, sized to reach the far post.
function ENT:Draw()
  local post = self:GetDTEntity(0)
  local angles = self:GetAngles()
  local matrix = Matrix()

  self:DrawModel()
  matrix:Translate(self:GetPos() + self:GetUp() * -40 + self:GetForward() * -2)
  matrix:Rotate(angles)

  render.SetMaterial(material)

  if IsValid(post) then
    local vertex = self:WorldToLocal(post:GetPos())
    self:SetRenderBounds(vector_origin - boundsOffset, vertex + self:GetUp() * 150)

    cam.PushModelMatrix(matrix)
    self:DrawShield(vertex)
    cam.PopModelMatrix()

    matrix:Translate(vertex)
    matrix:Rotate(angleFlip)

    cam.PushModelMatrix(matrix)
    self:DrawShield(vertex)
    cam.PopModelMatrix()
  end
end

--- Draws one side of the shield as a textured quad up to the far post, unless the field is off.
--
-- Based on how Chessnut draws his forcefields.
--
-- @param vertex [Vector The far post's position, local to this post]
function ENT:DrawShield(vertex)
  if self:GetDTInt(0) != 4 then
    local dist = self:GetDTEntity(0):GetPos():Distance(self:GetPos())
    local matFac = 45
    local height = 5
    local width = dist / matFac
    mesh.Begin(MATERIAL_QUADS, 1)
    mesh.Position(vector_origin)
    mesh.TexCoord(0, 0, 0)
    mesh.AdvanceVertex()
    mesh.Position(self:GetUp() * 190)
    mesh.TexCoord(0, 0, height)
    mesh.AdvanceVertex()
    mesh.Position(vertex + self:GetUp() * 190)
    mesh.TexCoord(0, width, height)
    mesh.AdvanceVertex()
    mesh.Position(vertex)
    mesh.TexCoord(0, width, 0)
    mesh.AdvanceVertex()
    mesh.End()
  end
end
