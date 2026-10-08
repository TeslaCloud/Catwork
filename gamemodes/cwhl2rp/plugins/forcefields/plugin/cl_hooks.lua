--- Client-side hooks of the Force Fields plugin, which stop the local player from getting up within 50 units of a
-- `cw_forcefield` and periodically rebuild the client-side collision mesh of every forcefield.

--- Called to check whether the local player can get up; blocks it within 50 units of a forcefield.
--
-- @return [Boolean `false` near a forcefield, otherwise `nil`]
function cwForceField:PlayerCanGetUp()
  local entities = ents.FindInSphere(cw.client:GetPos(), 50)

  for k, v in pairs(entities) do
    if v:GetClass() == 'cw_forcefield' then
      return false
    end
  end
end

timer.Create('forcefieldUpdater', 250, 0, function()
  for k, v in pairs(ents.FindByClass('cw_forcefield')) do
    if IsValid(v:GetDTEntity(0)) then
      local startPos = v:GetDTEntity(0):GetPos() - Vector(0, 0, 50)
      local verts = {
        { pos = Vector(0, 0, -35) },
        { pos = Vector(0, 0, 150) },
        { pos = v:WorldToLocal(startPos) + Vector(0, 0, 150) },
        { pos = v:WorldToLocal(startPos) + Vector(0, 0, 150) },
        { pos = v:WorldToLocal(startPos) - Vector(0, 0, 35) },
        { pos = Vector(0, 0, -35) }
      }

      v:PhysicsFromMesh(verts)
      v:EnableCustomCollisions(true)
      v:GetPhysicsObject():EnableCollisions(false)
    end
  end
end)
