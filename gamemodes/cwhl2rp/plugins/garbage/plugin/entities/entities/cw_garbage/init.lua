--- Server side of the `cw_garbage` entity, a garbage pile with a random junk model that players search with the use
-- key.
--
-- Searching needs a crouching, untied player or one holding the `cw_pushbroom` weapon; it runs a timed `cleanup`
-- action lasting what the `GetGarbageTime` hook returns, then removes the pile and fires `PlayerTakeGarbage`. The pile
-- stays frozen in place and cannot be tooled.

include('shared.lua')

AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

local garbageModels = {
  'models/props_junk/garbage128_composite001a.mdl',
  'models/props_junk/garbage128_composite001b.mdl',
  'models/props_junk/TrashCluster01a.mdl',
  'models/props_junk/garbage128_composite001d.mdl',
  'models/props_junk/garbage256_composite001b.mdl'
}

--- Returns whether a player holds the push broom, which lets them clean up without crouching.
-- @param player [Player The player to check]
-- @return [Boolean Whether the player's active weapon is `cw_pushbroom`]
local function HoldsBroom(player)
  local weapon = player:GetActiveWeapon()

  return IsValid(weapon) and weapon:GetClass() == 'cw_pushbroom'
end

--- Picks a random garbage model and sets up the pile's physics, colliding only with the world.
function ENT:Initialize()
  self:SetModel(table.Random(garbageModels))

  self:SetMoveType(MOVETYPE_VPHYSICS)
  self:PhysicsInit(SOLID_VPHYSICS)
  self:SetUseType(SIMPLE_USE)
  self:SetSolid(SOLID_VPHYSICS)

  self:SetCollisionGroup(COLLISION_GROUP_WORLD)

  local phys = self:GetPhysicsObject()

  if IsValid(phys) then
    phys:SetMass(120)
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
    physicsObject:SetVelocity(vector_origin)
    physicsObject:Sleep()
  end
end

--- Starts searching the pile when a crouching, untied player or one holding a push broom uses it.
--
-- The search takes `GetGarbageTime` seconds within 192 units and runs `PlayerTakeGarbage`
-- once the pile has been removed. Standing players are told to crouch.
function ENT:Use(activator, caller)
  if !IsValid(activator) or !activator:IsPlayer() or activator:GetEyeTraceNoCursor().Entity != self then return end

  if (activator:GetNetVar('tied') == 0 and activator:Crouching()) or HoldsBroom(activator) then
    local time = hook.Run('GetGarbageTime', activator)

    -- Started before the action: it ends the player's previous search, which clears that search's action.
    cw.player:EntityConditionTimer(activator, self, self, time, 192, function()
      return activator:Alive() and !activator:IsRagdolled() and activator:GetNetVar('tied') == 0 and
        (activator:Crouching() or HoldsBroom(activator))
    end, function(success)
      -- Two players can finish in the same tick, in which the removed pile is still valid.
      if success and IsValid(self) and !self.cwSearched then
        self.cwSearched = true

        activator:EmitSound('physics/body/body_medium_impact_soft'..math.random(1, 7)..'.wav')
        activator:FakePickup(self)
        self:Remove()

        hook.Run('PlayerTakeGarbage', activator, self)
      end

      if IsValid(activator) then
        cw.player:SetAction(activator, 'cleanup', false)
      end
    end)

    cw.player:SetAction(activator, 'cleanup', time)
  elseif activator:GetNetVar('tied') == 0 then
    cw.player:Notify(activator, L('Garbage_MustCrouch'))
  end
end

--- Blocks every tool on the pile.
--
-- @return [Boolean Always `false`]
function ENT:CanTool(player, trace, tool)
  return false
end
