--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

include('shared.lua')

AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

--- Sets up the soda machine model and physics with an empty stock.
function ENT:Initialize()
  self:SetModel('models/props_interiors/vendingmachinesoda01a.mdl')

  self:SetMoveType(MOVETYPE_VPHYSICS)
  self:PhysicsInit(SOLID_VPHYSICS)
  self:SetUseType(SIMPLE_USE)
  self:SetSolid(SOLID_VPHYSICS)
  self:SetStock(0, true)
end

--- Always transmits the machine to every client.
function ENT:UpdateTransmitState()
  return TRANSMIT_ALWAYS
end

--- Takes one can from the stock and dispenses a random Breen's water in front of the machine.
--
-- Dispenses a special Breen's water 1 time in 20, a smooth one 10 times in 20 and a regular one otherwise.
--
-- @param activator [Player The buyer, recorded as the item entity's owner]
function ENT:CreateWater(activator)
  self:GiveStock(-1)
  self:EmitSound('buttons/button4.wav')
  self:SetFlashDuration(3, true)

  local forward = self:GetForward() * 18
  local chance = math.random(1, 20)
  local right = self:GetRight() * 3
  local up = self:GetUp() * -24

  if chance == 20 then
    cw.entity:CreateItem(
      activator,
      item.CreateInstance('special_breens_water'),
      self:GetPos() + forward + right + up,
      self:GetAngles()
    )
  elseif chance >= 10 then
    cw.entity:CreateItem(
      activator,
      item.CreateInstance('smooth_breens_water'),
      self:GetPos() + forward + right + up,
      self:GetAngles()
    )
  else
    cw.entity:CreateItem(
      activator,
      item.CreateInstance('breens_water'),
      self:GetPos() + forward + right + up,
      self:GetAngles()
    )
  end
end

--- Returns the stock the machine is refilled to on restock.
-- @return [Number The default stock, 0 when none was set]
function ENT:GetDefaultStock()
  return self.defaultStock or 0
end

--- Adds to the machine's stock, clamped between 0 and the default stock.
-- @param amount [Number Cans to add; negative to take some away]
function ENT:GiveStock(amount)
  self:SetStock(math.Clamp(self:GetStock() + amount, 0, self:GetDefaultStock()))
end

--- Sets the machine's stock and optionally its default stock.
-- @param amount [Number The new stock]
-- @param default=nil [Any A number to use as the default stock, or `true` to make `amount` the default]
function ENT:SetStock(amount, default)
  self:SetDTInt(0, amount)

  if default then
    if type(default) == 'number' then
      self.defaultStock = default
    else
      self.defaultStock = amount
    end
  end
end

--- Refills the machine to its default stock with a flash and sound.
function ENT:Restock()
  self:SetFlashDuration(3, true)
  self:EmitSound('buttons/button5.wav')
  self:SetStock(self:GetDefaultStock())
end

--- Flashes the machine's status light.
-- @param duration [Number How long the light flashes, in seconds]
-- @param action=nil [Boolean `true` for a blue success flash; otherwise a red refusal flash with a sound]
function ENT:SetFlashDuration(duration, action)
  self:SetDTFloat(0, CurTime() + duration)

  if action then
    self:SetDTBool(0, true)
  else
    self:EmitSound('buttons/button2.wav')
    self:SetDTBool(0, false)
  end
end

--- Keeps the machine still while nobody holds it and it is not constrained.
function ENT:PhysicsUpdate(physicsObject)
  if !self:IsPlayerHolding() and !self:IsConstrained() then
    physicsObject:SetVelocity(Vector(0, 0, 0))
    physicsObject:Sleep()
  end
end

--- Sells a Breen's water to a citizen for 8 tokens, or lets Combine restock an empty machine.
--
-- Citizens can buy once every 10 minutes; an empty machine, a player who cannot pay or one on cooldown
-- gets a red flash. Uses are ignored within 3 seconds of each other and while the light flashes.
function ENT:Use(activator, caller)
  if activator:IsPlayer() and activator:GetEyeTraceNoCursor().Entity == self then
    local curTime = CurTime()

    if !self.nextUse or curTime >= self.nextUse then
      if curTime > self:GetDTFloat(0) then
        self.nextUse = curTime + 3

        if !Schema:PlayerIsCombine(activator) then
          if self:GetStock() == 0 or !cw.player:CanAfford(activator, 8) then
            self:SetFlashDuration(3)
          elseif !activator.nextVendingMachine or curTime >= activator.nextVendingMachine then
            self:CreateWater(activator)

            activator.nextVendingMachine = curTime + 600

            cw.player:GiveCash(activator, -8, L('VendingMachine_CashReason'))
          else
            self:SetFlashDuration(3)
          end
        elseif self:GetStock() == 0 then
          self:Restock()
        end
      end
    end
  end
end

--- Blocks every toolgun action on the machine.
-- @return [Boolean Always `false`]
function ENT:CanTool(player, trace, tool)
  return false
end
