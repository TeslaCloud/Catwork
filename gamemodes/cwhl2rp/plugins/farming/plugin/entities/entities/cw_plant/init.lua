--- Server side of the `cw_plant` entity, a plant grown from a seed item that scales up as it ripens and can be
-- harvested with the use key.
--
-- Harvesting needs a ripe plant and a crouching, untied player; it runs a timed `farming` action shortened by the
-- Farming attribute and then fires the `PlayerHarvest` hook and removes the plant. Damage from a player destroys the
-- plant. The setters for the spawn time, grow time and seed item ID are defined here.

include('shared.lua')

AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

--- Sets up the plant's default pot model and physics.
function ENT:Initialize()
  self:SetModel('models/props/de_inferno/claypot03_damage_01.mdl')
  self:SetMoveType(MOVETYPE_VPHYSICS)
  self:PhysicsInit(SOLID_VPHYSICS)
  self:SetUseType(SIMPLE_USE)
  self:SetSolid(SOLID_VPHYSICS)
  self:SetCollisionGroup(COLLISION_GROUP_WORLD)

  local phys = self:GetPhysicsObject()

  if IsValid(physObj) then
    physObj:EnableMotion(false)
    physObj:Sleep()
    -- physObj:SetMass(500)
  end
end

--- Scales the plant up from a quarter of its size as it grows.
function ENT:Think()
  if self:GetSpawnTime() and self:GetGrowTime() and self:GetGrowTime() > CurTime() then
    local GrowthPercent = (CurTime() - self:GetSpawnTime()) / (self:GetGrowTime() - self:GetSpawnTime())

    if GrowthPercent <= 1 then
      self:SetModelScale(math.max(1 * GrowthPercent, 0.25))
    end
  end
end

--- Destroys the plant when a player damages it.
function ENT:OnTakeDamage(dmg)
  local player = dmg:GetAttacker()

  if player:IsPlayer() then self:Remove() end
end

--- Starts harvesting the ripe plant for a crouching, untied player.
--
-- The harvest takes 11 to 25 seconds, less with the farming attribute, during which the player
-- must stay crouched and near the plant. On success it fires `PlayerHarvest` and removes the
-- plant.
function ENT:Use(activator)
  if self:GetGrowTime() <= CurTime() and !self.isGathering then
    if activator:GetNetVar('tied') == 0 and activator:Crouching() then
      local gathertime = math.random(11, 25) - math.Round(cw.attributes:Fraction(activator, ATB_FARM, 10))

      self.isGathering = true

      cw.player:SetAction(activator, 'farming', gathertime)
      cw.player:EntityConditionTimer(activator, self, self, gathertime, 192, function()
        return activator:Alive() and !activator:IsRagdolled() and activator:GetNetVar('tied') == 0 and
          activator:Crouching()
      end,
      function(success)
        if success then
          hook.Run('PlayerHarvest', activator, self:GetItem())

          self.isGathering = false
          activator:EmitSound('physics/body/body_medium_impact_soft'..math.random(1, 7)..'.wav')
          activator:FakePickup(self)
          self:Remove()
        else
          self.isGathering = false
        end

        cw.player:SetAction(activator, 'farming', false)
      end)
    else
      cw.player:Notify(activator, L('Farming_MustCrouch'))
    end
  else
    cw.player:Notify(activator, L('Farming_NotRipe'))
  end
end

--- Sets when the plant was planted.
-- @param time [Number The `CurTime` the seeds were planted at]
function ENT:SetSpawnTime(time)
  self:SetNWFloat(0, time)
end

--- Sets when the plant is ripe.
-- @param time [Number The `CurTime` the plant ripens at]
function ENT:SetGrowTime(time)
  self:SetNWFloat(1, time)
end

--- Sets the seed item the plant grew from, which decides its name and harvest.
-- @param uniqueID [String The seed item's unique ID]
function ENT:SetItem(uniqueID)
  self:SetNWString(0, uniqueID)
end
