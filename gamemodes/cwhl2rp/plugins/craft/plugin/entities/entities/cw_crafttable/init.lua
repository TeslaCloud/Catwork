include('shared.lua')

AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

--- Sets up the crafting station's model and movable physics.
function ENT:Initialize()
  self:SetModel(self.Model)

  self:SetMoveType(MOVETYPE_VPHYSICS)
  self:PhysicsInit(SOLID_VPHYSICS)
  self:SetUseType(SIMPLE_USE)
  self:SetSolid(SOLID_VPHYSICS)

  local physicsObject = self:GetPhysicsObject()

  if IsValid(physicsObject) then
    physicsObject:Wake()
    physicsObject:EnableMotion(true)
  end
end

--- Opens this station's craft menu for the player using it, at most once a second.
--
-- The menu lists the blueprints whose `craftplace` is this entity's class.
function ENT:Use(activator)
  local curTime = CurTime()

  if !activator.nextUse or activator.nextUse <= curTime then
    netstream.Start(activator, 'Craft::OpenMenu', self:GetClass(), self.PrintName)
    activator.nextUse = curTime + 1
  end
end
