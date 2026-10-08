--- Server side of the `cw_crafttable` entity of the Craft plugin, the crafting station that opens the craft menu when
-- used.
--
-- `ENT:Use` sends the `Craft::OpenMenu` netstream with the entity's class and name, at most once a second per player,
-- so the menu lists the blueprints whose `craftplace` is that class, and remembers the station in
-- `player.cwCraftStation` for the `Craft::CraftItem` handler to check. The other stations inherit this behaviour.

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
  if !IsValid(activator) or !activator:IsPlayer() then return end

  local curTime = CurTime()

  if !activator.nextUse or activator.nextUse <= curTime then
    netstream.Start(activator, 'Craft::OpenMenu', self:GetClass(), self.PrintName)
    activator.cwCraftStation = self
    activator.nextUse = curTime + 1
  end
end
