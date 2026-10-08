--- Server side of the `cw_unionlight` entity, the Union Light placed from an item: sets the Combine light model and its
-- physics and defines the spawn function, with no use or think behaviour.

include('shared.lua')

AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

--- Sets the Combine light model and its physics.
function ENT:Initialize()
  self:SetModel('models/props_combine/combine_light001a.mdl')
  self:PhysicsInit(SOLID_VPHYSICS)
  self:SetMoveType(MOVETYPE_VPHYSICS)
  self:SetSolid(SOLID_VPHYSICS)
  local phys = self:GetPhysicsObject()
  if phys:IsValid() then phys:Wake() end
end

--- Spawns a union light 16 units off the surface the player is looking at.
--
-- @return [Entity The new light, or `nil` when the trace hit nothing]
function ENT:SpawnFunction(ply, tr)
  if !tr.Hit then return end

  local ent = ents.Create('cw_unionlight')
  ent:SetPos(tr.HitPos + tr.HitNormal * 16)
  ent:Spawn()
  ent:Activate()

  return ent
end

--- Does nothing.
function ENT:OnRemove()
end

--- Does nothing on the server.
function ENT:Think()
end

--- Does nothing; the light cannot be used.
function ENT:Use()
end
