--- Server side of the `cw_garbage` entity, a garbage pile with a random junk model that players search with the use
-- key.
--
-- Searching needs a crouching, untied player or one holding the `cw_pushbroom` weapon; it runs a timed `cleanup`
-- action lasting what the `GetGarbageTime` hook returns, then fires `PlayerTakeGarbage` and removes the pile. The pile
-- stays frozen in place and cannot be tooled.

include('shared.lua')

AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

--- Picks a random garbage model and sets up the pile's physics, colliding only with the world.
function ENT:Initialize()
  local garbageModels = {
    'models/props_junk/garbage128_composite001a.mdl',
    'models/props_junk/garbage128_composite001b.mdl',
    'models/props_junk/TrashCluster01a.mdl',
    'models/props_junk/garbage128_composite001d.mdl',
    'models/props_junk/garbage256_composite001b.mdl'
  }

  self:SetModel(table.Random(garbageModels))

  self:SetMoveType(MOVETYPE_VPHYSICS)
  self:PhysicsInit(SOLID_VPHYSICS)
  self:SetUseType(SIMPLE_USE)
  self:SetSolid(SOLID_VPHYSICS)

  self:SetCollisionGroup(COLLISION_GROUP_WORLD)

  local phys = self:GetPhysicsObject()
  phys:SetMass(120)

  self:SetSpawnType(1)
end

--- Stores the pile's type in the networked int 1, for `TYPE_WATERCAN` or `TYPE_SUPPLIES` only.
--
-- @param entType [Number `TYPE_WATERCAN` or `TYPE_SUPPLIES`]
function ENT:SetSpawnType(entType)
  if entType == TYPE_WATERCAN or entType == TYPE_SUPPLIES then
    self:SetDTInt(1, entType)
  end
end

--- Returns `TRANSMIT_ALWAYS`, so the pile is networked to every client.
--
-- @return [Number `TRANSMIT_ALWAYS`]
function ENT:UpdateTransmitState()
  return TRANSMIT_ALWAYS
end

--- Stops the pile from moving unless a player holds it or it is constrained.
function ENT:PhysicsUpdate(physicsObject)
  if !self:IsPlayerHolding() and !self:IsConstrained() then
    physicsObject:SetVelocity(Vector(0, 0, 0))
    physicsObject:Sleep()
  end
end

--- Starts searching the pile when a crouching, untied player or one holding a push broom uses it.
--
-- The search takes `GetGarbageTime` seconds within 192 units and runs `PlayerTakeGarbage`
-- before removing the pile. Standing players are told to crouch.
function ENT:Use(activator, caller)
  if activator:IsPlayer() and activator:GetEyeTraceNoCursor().Entity == self then
    local weapon = activator:GetActiveWeapon()

    if (activator:GetNetVar('tied') == 0 and activator:Crouching()) or (weapon:GetClass() == 'cw_pushbroom') then
      local time = hook.Run('GetGarbageTime', activator)

      cw.player:SetAction(activator, 'cleanup', time)
      cw.player:EntityConditionTimer(activator, self, self, time, 192, function()
        return activator:Alive() and !activator:IsRagdolled() and activator:GetNetVar('tied') == 0 and
          (activator:Crouching() or weapon:GetClass() == 'cw_pushbroom')
      end, function(success)
        if success then
          hook.Run('PlayerTakeGarbage', activator, self)

          activator:EmitSound('physics/body/body_medium_impact_soft'..math.random(1, 7)..'.wav')
          activator:FakePickup(self)
          self:Remove()
        end

        cw.player:SetAction(activator, 'cleanup', false)
      end)
    elseif activator:GetNetVar('tied') == 0 and (!activator:Crouching() or weapon:GetClass() != 'cw_pushbroom') then
      cw.player:Notify(activator, L('Garbage_MustCrouch'))
    end
  end
end

--- Blocks every tool on the pile.
--
-- @return [Boolean Always `false`]
function ENT:CanTool(player, trace, tool)
  return false
end
