--- Server side of the `cw_factorydispenser` entity of the Ration Factory plugin, a button with a pipe that dispenses
-- the contents of a ration.
--
-- Pressing it creates a `breens_water` or a `citizen_supplements` item, depending on the type set with `SetSpawnType`,
-- with a five second cooldown. It stops while 20 of its items are still lying around.
--
-- Originally written for the Iron Wall community.

include('shared.lua')

AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

-- How many items of one dispenser may exist at once. Nothing removes an item that is left lying around, so without a
-- limit the button could be used to fill the map with entities.
local MAX_PRODUCTS = 20

--- Sets up the button model, attaches the output pipe and defaults to dispensing supplies.
function ENT:Initialize()
  self:SetModel('models/MaxOfS2D/button_05.mdl')

  self:SetMoveType(MOVETYPE_VPHYSICS)
  self:PhysicsInit(SOLID_VPHYSICS)
  self:SetUseType(SIMPLE_USE)
  self:SetSolid(SOLID_VPHYSICS)

  self.tube = ents.Create('prop_dynamic')
  self.tube:DrawShadow(false)
  self.tube:SetAngles(self:GetAngles() + Angle(0, 90, 0))
  self.tube:SetParent(self)
  self.tube:SetModel('models/mechanics/solid_steel/box_beam_4.mdl')
  self.tube:SetMaterial('models/props_pipes/GutterMetal01a')
  self.tube:SetPos(self:GetPos() + Vector(-16, 0, -6))
  self.tube:Spawn()

  self:DeleteOnRemove(self.tube)

  self:SetCollisionGroup(COLLISION_GROUP_WORLD)

  local phys = self:GetPhysicsObject()

  if IsValid(phys) then
    phys:SetMass(120)
  end

  self.products = {}

  self:SetSpawnType(1)
end

--- Returns how many of the items the dispenser made still exist, forgetting the ones that are gone.
-- @return [Number The item count]
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

--- Sets what the dispenser spawns; other values are ignored.
-- @param entType [Number `TYPE_WATERCAN` (0) for `breens_water`, `TYPE_SUPPLIES` (1) for `citizen_supplements`]
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

--- Dispenses an item when a player presses the button, with a five second cooldown.
--
-- Pressing it during the cooldown, or while 20 of its items still exist, plays a denial sound.
function ENT:Use(activator, caller)
  if activator:IsPlayer() and activator:GetEyeTraceNoCursor().Entity == self then
    local curTime = CurTime()

    if (!self.nextUse or curTime >= self.nextUse) and self:CountProducts() < MAX_PRODUCTS then
      self:EmitRandomSound()

      self:SpawnItem(activator)

      self.nextUse = curTime + 5
    else
      self:EmitSound('buttons/button11.wav')
    end
  end
end

--- Spawns the dispenser's item: Breen's Water at the pipe, or citizen supplements at the button.
-- @param activator [Player The player who pressed the button, passed on as the item's creator]
function ENT:SpawnItem(activator)
  local entity

  if self:GetSpawnType() == TYPE_WATERCAN then
    entity = cw.entity:CreateItem(activator, 'breens_water', self.tube:GetPos())
  else
    entity = cw.entity:CreateItem(activator, 'citizen_supplements', self:GetPos())
  end

  if IsValid(entity) then
    self.products[#self.products + 1] = entity
  end
end

--- Blocks every toolgun action on the dispenser.
function ENT:CanTool(player, trace, tool)
  return false
end
