--- Server side of the `cw_rationdispenser` entity, the Combine dispenser that hands citizens one ration per hour.
--
-- Using it as a citizen starts `ENT:ActivateRation`, which picks the ration item and preparation time from the
-- player's loyalist tier (`ration_highest` in 4 seconds down to `ration_minimal` in 26) and then plays the dispense
-- animation. Combine players lock and unlock it instead, and the next collection time is kept in the `nextration`
-- character data.

include('shared.lua')

AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

--- Sets up the invisible collision box and the parented Combine dispenser model.
function ENT:Initialize()
  self:SetModel('models/props_junk/watermelon01.mdl')

  self:SetMoveType(MOVETYPE_VPHYSICS)
  self:PhysicsInit(SOLID_VPHYSICS)
  self:SetUseType(SIMPLE_USE)
  self:SetSolid(SOLID_VPHYSICS)

  self.dispenser = ents.Create('prop_dynamic')
  self.dispenser:DrawShadow(false)
  self.dispenser:SetAngles(self:GetAngles())
  self.dispenser:SetParent(self)
  self.dispenser:SetModel('models/props_combine/combine_dispenser.mdl')
  self.dispenser:SetPos(self:GetPos())
  self.dispenser:Spawn()

  self:DeleteOnRemove(self.dispenser)

  local minimum = Vector(-8, -8, -8)
  local maximum = Vector(8, 8, 64)

  self:SetCollisionBounds(minimum, maximum)
  self:SetCollisionGroup(COLLISION_GROUP_WORLD)
  self:PhysicsInitBox(minimum, maximum)
  self:DrawShadow(false)
end

--- Always transmits the dispenser to every client.
function ENT:UpdateTransmitState()
  return TRANSMIT_ALWAYS
end

--- Locks the dispenser when it is unlocked and unlocks it when it is locked.
function ENT:Toggle()
  if self:IsLocked() then
    self:Unlock()
  else
    self:Lock()
  end
end

--- Locks the dispenser and plays a random button sound.
function ENT:Lock()
  self:SetDTBool(0, true)
  self:EmitRandomSound()
end

--- Unlocks the dispenser and plays a random button sound.
function ENT:Unlock()
  self:SetDTBool(0, false)
  self:EmitRandomSound()
end

--- Flashes the status light red and plays the denied sound.
-- @param duration [Number How long the light flashes, in seconds]
function ENT:SetFlashDuration(duration)
  self:EmitSound('buttons/combine_button_locked.wav')
  self:SetDTFloat(1, CurTime() + duration)
end

--- Spawns a ration packet prop in front of the dispenser.
-- @param customModel=nil [String Model for the prop; defaults to the minimal tier packet]
-- @return [Entity The spawned `prop_physics`]
function ENT:CreateDummyRation(customModel)
  local forward = self:GetForward() * 15
  local right = self:GetRight() * 0
  local up = self:GetUp() * -8

  local entity = ents.Create('prop_physics')

  entity:SetAngles(self:GetAngles())
  entity:SetModel(customModel or 'models/weapons/w_packati.mdl')
  entity:SetPos(self:GetPos() + forward + right + up)
  entity:Spawn()

  return entity
end

--- Prepares a ration for a player and dispenses it after a delay that depends on their tier.
--
-- The ration tier and delay come from the player's loyalist tier (CWU get the orange tier): red
-- `ration_highest` in 4 seconds down to `ration_minimal` in 26 seconds for unranked citizens. When the
-- delay ends, the dispenser plays its animation and the packet prop becomes a frozen ration item owned by
-- the player. Does nothing while a previous ration is still being prepared, unless forced.
--
-- @param activator [Player The player the ration is for]
-- @param duration=nil [Number Unused; the delay is always set from the tier]
-- @param force=nil [Boolean Whether to dispense even while another ration is being prepared]
function ENT:ActivateRation(activator, duration, force)
  local curTime = CurTime()
  local entModel
  local rationType

  if Schema:PlayerIsLoyalistTier(activator, 'red') then
    entModel = 'models/weapons/w_packatp.mdl'
    rationType = 'ration_highest'
    duration = 4
  elseif Schema:PlayerIsLoyalistTier(activator, 'orange') or Schema:PlayerIsCWU(activator) then
    entModel = 'models/weapons/w_packatp.mdl'
    rationType = 'ration_high'
    duration = 8
  elseif Schema:PlayerIsLoyalistTier(activator, 'blue') then
    entModel = 'models/weapons/w_packatl.mdl'
    rationType = 'ration_medium'
    duration = 12
  elseif Schema:PlayerIsLoyalistTier(activator, 'green') then
    entModel = 'models/weapons/w_packatc.mdl'
    rationType = 'ration_standard'
    duration = 15
  elseif Schema:PlayerIsLoyalistTier(activator, 'white') then
    entModel = 'models/weapons/w_packatc.mdl'
    rationType = 'ration_normal'
    duration = 18
  else
    entModel = 'models/weapons/w_packati.mdl'
    rationType = 'ration_minimal'
    duration = 26
  end

  if force or !self.nextActivateRation or curTime >= self.nextActivateRation then
    self.nextActivateRation = curTime + duration + 2
    self:SetDTFloat(0, curTime + duration)

    timer.Create('ration_'..self:EntIndex(), duration, 1, function()
      if IsValid(self) then
        local frameTime = FrameTime() * 0.5
        local dispenser = self.dispenser
        local entity = self:CreateDummyRation(entModel)

        if IsValid(entity) then
          dispenser:EmitSound('ambient/machines/combine_terminal_idle4.wav')

          entity:SetNotSolid(true)
          entity:SetParent(dispenser)

          timer.Simple(frameTime, function()
            if IsValid(self) and IsValid(entity) then
              entity:Fire('setparentattachment', 'package_attachment', 0)

              timer.Simple(frameTime, function()
                if IsValid(self) and IsValid(entity) then
                  dispenser:Fire('setanimation', 'dispense_package', 0)

                  timer.Simple(1.75, function()
                    if IsValid(self) and IsValid(entity) then
                      local position = entity:GetPos()
                      local angles = entity:GetAngles()

                      entity:CallOnRemove('CreateRation', function()
                        if IsValid(activator) then
                          local itemTable = item.CreateInstance(rationType or 'ration_normal')

                          if itemTable then
                            local entity = cw.entity:CreateItem(activator, itemTable, position, angles)
                            local physObj = entity:GetPhysicsObject()

                            if IsValid(physObj) then
                              physObj:EnableMotion(false)
                            end
                          end
                        end
                      end)

                      entity:SetNoDraw(true)
                      entity:Remove()
                    end
                  end)
                end
              end)
            end
          end)
        end
      end
    end)
  end
end

--- Plays one random Combine button sound from the dispenser.
function ENT:EmitRandomSound()
  local randomSounds = {
    'buttons/combine_button1.wav',
    'buttons/combine_button2.wav',
    'buttons/combine_button3.wav',
    'buttons/combine_button5.wav',
    'buttons/combine_button7.wav'
  }

  self:EmitSound(randomSounds[math.random(1, #randomSounds)])
end

--- Keeps the dispenser still while nobody holds it and it is not constrained.
function ENT:PhysicsUpdate(physicsObject)
  if !self:IsPlayerHolding() and !self:IsConstrained() then
    physicsObject:SetVelocity(Vector(0, 0, 0))
    physicsObject:Sleep()
  end
end

--- Dispenses a ration to a citizen or lets Combine lock and unlock the dispenser.
--
-- Citizens can collect one ration per hour (stored in the `nextration` character data); a locked
-- dispenser or one used too early gives a red flash. Uses are ignored within 3 seconds of each other.
function ENT:Use(activator, caller)
  if activator:IsPlayer() and activator:GetEyeTraceNoCursor().Entity == self then
    local curTime = CurTime()
    local unixTime = os.time()

    if !self.nextUse or curTime >= self.nextUse then
      if !Schema:PlayerIsCombine(activator) then
        if !self:IsLocked() and unixTime >= activator:GetCharacterData('nextration', 0) then
          if !self.nextActivateRation or curTime >= self.nextActivateRation then
            self:ActivateRation(activator)

            activator:SetCharacterData('nextration', unixTime + 3600)
          end
        else
          self:SetFlashDuration(3)
        end
      elseif !self.nextActivateRation or curTime >= self.nextActivateRation then
        self:Toggle()
      end

      self.nextUse = curTime + 3
    end
  end
end

--- Blocks every toolgun action on the dispenser.
-- @return [Boolean Always `false`]
function ENT:CanTool(player, trace, tool)
  return false
end
