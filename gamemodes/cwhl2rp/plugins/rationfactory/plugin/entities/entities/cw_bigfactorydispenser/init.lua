--- Server side of the `cw_bigfactorydispenser` entity of the Ration Factory plugin, a button with pipes that produces
-- the factory's empty containers.
--
-- Pressing it spawns a `cw_emptyration` packet (8 second cooldown) or a `cw_emptycrate` (60 seconds) at its pipe,
-- depending on the type set with `SetSpawnType`. It stops while 20 of its containers still exist.
--
-- Originally written for the Iron Wall community.

include('shared.lua')

AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

-- How many containers of one dispenser may exist at once. Nothing removes a container that is left lying around, so
-- without a limit the button could be used to fill the map with entities.
local MAX_PRODUCTS = 20

--- Sets up the button model, attaches two pipes and defaults to producing supply crates.
function ENT:Initialize()
  self:SetModel('models/MaxOfS2D/button_05.mdl')

  self:SetMoveType(MOVETYPE_VPHYSICS)
  self:PhysicsInit(SOLID_VPHYSICS)
  self:SetUseType(SIMPLE_USE)
  self:SetSolid(SOLID_VPHYSICS)

  self.tube = ents.Create('prop_dynamic')
  self.tube:DrawShadow(false)
  self.tube:SetAngles(self:GetAngles() + Angle(90, 0, 0))
  self.tube:SetParent(self)
  self.tube:SetModel('models/props_phx/construct/metal_tube.mdl')
  self.tube:SetMaterial('models/props_pipes/GutterMetal01a')
  self.tube:SetPos(self:GetPos() + Vector(-40, 0, -20))
  self.tube:Spawn()

  self.tube2 = ents.Create('prop_dynamic')
  self.tube2:DrawShadow(false)
  self.tube2:SetAngles(self:GetAngles() + Angle(90, 0, 0))
  self.tube2:SetParent(self)
  self.tube2:SetModel('models/props_phx/construct/metal_tube.mdl')
  self.tube2:SetMaterial('models/props_pipes/GutterMetal01a')
  self.tube2:SetPos(self:GetPos() + Vector(-87, 0, -20))
  self.tube2:Spawn()

  self:DeleteOnRemove(self.tube)

  local phys = self:GetPhysicsObject()

  if IsValid(phys) then
    phys:SetMass(120)
  end

  self:SetCollisionGroup(COLLISION_GROUP_WORLD)

  self.timeStep = 8
  self.products = {}

  self:SetSpawnType(1)
end

--- Returns how many of the containers the dispenser made still exist, forgetting the ones that are gone.
-- @return [Number The container count]
function ENT:CountProducts()
  local products = {}

  for k, v in ipairs(self.products or {}) do
    if IsValid(v) then
      products[#products + 1] = v
    end
  end

  self.products = products

  return #products
end

--- Sets what the dispenser produces; other values are ignored.
-- @param entType [Number `TYPE_WATERCAN` (0) for empty ration packets, `TYPE_SUPPLIES` (1) for empty crates]
function ENT:SetSpawnType(entType)
  if entType == TYPE_WATERCAN or entType == TYPE_SUPPLIES then
    self:SetDTInt(1, entType)
  end
end

--- Makes the dispenser always transmit to clients.
function ENT:UpdateTransmitState()
  return TRANSMIT_ALWAYS
end

--- Plays one of the dispenser's machine sounds at random.
function ENT:EmitRandomSound()
  local randomSounds = {
    'ambient/machines/combine_terminal_idle2.wav',
    'buttons/button4.wav'
  }

  self:EmitSound(randomSounds[math.random(1, #randomSounds)])
end

--- Keeps the dispenser still unless a player holds it or it is constrained.
function ENT:PhysicsUpdate(physicsObject)
  if !self:IsPlayerHolding() and !self:IsConstrained() then
    physicsObject:SetVelocity(Vector(0, 0, 0))
    physicsObject:Sleep()
  end
end

--- Produces an item when a player presses the button, then waits out the item's cooldown.
--
-- Pressing it during the cooldown, or while 20 of its containers still exist, plays a denial sound.
function ENT:Use(activator, caller)
  if activator:IsPlayer() and activator:GetEyeTraceNoCursor().Entity == self then
    local curTime = CurTime()

    if (!self.nextUse or curTime >= self.nextUse) and self:CountProducts() < MAX_PRODUCTS then
      self:EmitRandomSound()

      self:SpawnItem(activator)

      self.nextUse = curTime + self.timeStep
    else
      self:EmitSound('buttons/button11.wav')
    end
  end
end

--- Spawns a `cw_emptyration` (8 second cooldown) or a `cw_emptycrate` (60 seconds) at the pipe.
-- @param activator [Player The player who pressed the button; unused]
function ENT:SpawnItem(activator)
  local entity

  if self:GetSpawnType() == TYPE_WATERCAN then
    entity = ents.Create('cw_emptyration')

    self.timeStep = 8
    entity:SetPos(self.tube:GetPos())
    entity:Spawn()
  else
    entity = ents.Create('cw_emptycrate')

    self.timeStep = 60
    entity:SetPos(self.tube:GetPos() - Vector(0, 0, -20))
    entity:Spawn()
  end

  self.products[#self.products + 1] = entity
end

--- Blocks every toolgun action on the dispenser.
function ENT:CanTool(player, trace, tool)
  return false
end
