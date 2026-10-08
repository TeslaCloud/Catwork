--- Server side of the `cw_factory_garbage_paper` entity: sets up the paper recycler and implements its work cycle.
--
-- `ENT:StartWork` starts or resumes a cycle once enough garbage is collected, `ENT:StopWork` pauses it and
-- `ENT:EndWork` spawns the `paper` product at the product position. `ENT:Eject` moves the collected garbage into the
-- storage entity set with `SetEjectStorage`, dropping what does not fit, and `ENT:Use` does nothing, since the
-- recycler is operated through the Factories plugin's entity menu options.

AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

--- Sets up the recycler model, physics and empty garbage state.
function ENT:Initialize()
  self:SetModel('models/props/cs_militia/microwave01.mdl')
  self:SetMoveType(MOVETYPE_VPHYSICS)
  self:PhysicsInit(SOLID_VPHYSICS)
  self:SetSolid(SOLID_VPHYSICS)
  self:SetUseType(SIMPLE_USE)
  self:SetMaterial('models/props_combine/tprotato2_sheet')
  local phys = self:GetPhysicsObject()

  if phys then
    phys:SetMass(120)
    phys:Wake()
  end

  self:SetGarbageCount(0)
  self.Garbages = {}
  self:SetIsWorking(false)
  self:SetProductPos(self:GetPos() + self:GetUp() * 20)
  self:SetEjectStorage(0)

  self.NextWorkSound = nil
  self.NextRandomSound = nil
  self.StopWorkTime = nil
end

--- Spawns a paper recycler 25 units off the aimed surface.
-- @return [Entity The spawned recycler]
function ENT:SpawnFunction(ply, trace)
  local ent = ents.Create('cw_factory_garbage_paper')
  ent:SetPos(trace.HitPos + trace.HitNormal * 25)
  ent:Spawn()
  ent:Activate()
  return ent
end

--- Returns whether the recycler accepts an item as garbage.
-- @param item [Item The item to check]
-- @return [Boolean Whether the item's unique ID is in `ENT.GARBAGE_ITEMS`]
function ENT:CanGarbageUsed(item)
  if table.HasValue(self.GARBAGE_ITEMS, item('uniqueID')) then
    return true
  end

  return false
end

--- Returns the corners of the box above the recycler that garbage is collected from.
-- @return [List<Vector> The two opposite corners, as passed to `ents.FindInBox`]
function ENT:GetSearchPos()
  local up, right, forward = self:GetUp(), self:GetRight(), self:GetForward()
  local pos1 = self:GetPos() + (up * 23) + (right * 18) + (forward * 22)
  local pos2 = self:GetPos() + (up * -0.5) + (right * -18) + (forward * 6)
  return { pos1, pos2 }
end

--- Starts a recycling cycle, or resumes a stopped one where it left off.
--
-- A new cycle only starts once the garbage count is at least `ENT.METAL_GARBAGE_COUNT_START`
-- and lasts `ENT.WORK_TIME` seconds.
function ENT:StartWork()
  if self:GetStopWorkTime() <= 0 then
    if self:GetGarbageCount() < self.METAL_GARBAGE_COUNT_START then
      return
    end

    self:SetStartWorkTime(CurTime())
    self:SetNextWorkTime(CurTime() + self.WORK_TIME)
  else
    local i = self.WORK_TIME - self:GetStopWorkTime()
    self:SetStartWorkTime(CurTime() - i)
    self:SetNextWorkTime((CurTime() + self.WORK_TIME) - i)
  end

  self:SetIsWorking(true)
  self:EmitSound('plats/elevator_large_start1.wav')
  self.NextWorkSound = CurTime() + 1.4
end

--- Moves the collected garbage into the eject storage entity and empties the recycler.
--
-- The storage is found by the creation ID set with `SetEjectStorage`. Does nothing while working or
-- paused, or when the storage does not exist. Items that would push a known container over its weight
-- limit are dropped on top of it instead.
function ENT:Eject()
  if self:GetIsWorking() then return end
  if self:GetStopWorkTime() > 0 then return end

  local id = self:GetEjectStorage()
  local ent = nil

  for k, v in pairs(ents.GetAll()) do
    if v:GetCreationID() == id then
      ent = v
      break
    end
  end

  if !IsValid(ent) then return end

  if !ent.cwInventory then
    cwStorage.storage[ent] = ent

    ent.cwInventory = {}
  end

  for k, v in pairs(self.Garbages) do
    local itemTable = item.FindByID(v)

    local weight = itemTable.storageWeight or itemTable.weight
    local space = itemTable.storageSpace or itemTable.space

    local model = string.lower(ent:GetModel())

    if cwStorage.containerList[model] then
      local containerWeight = cwStorage.containerList[model][1]

      if cw.inventory:CalculateWeight(ent.cwInventory) + math.max(weight, 0) > containerWeight then
        cw.entity:CreateItem(nil, v, ent:GetPos() + ent:GetUp() * 20)
        continue
      end
    end

    cw.inventory:AddInstance(ent.cwInventory, item.CreateInstance(v))
  end

  self:SetGarbageCount(0)
  self.Garbages = {}
end

--- Pauses the current cycle, remembering the time left, and stops the work sounds.
function ENT:StopWork()
  self:SetStopWorkTime(self:GetNextWorkTime() - CurTime())
  self:SetIsWorking(false)
  self.WorkSound:Stop()
  self:EmitSound('plats/elevator_large_stop1.wav')
  self.NextRandomSound = nil
  self.NextGarbageDecrease = nil
end

--- Finishes the cycle, stops the work sounds and spawns a `paper` item at the product position.
function ENT:EndWork()
  self:SetIsWorking(false)
  self.WorkSound:Stop()
  self:EmitSound('plats/elevator_large_stop1.wav')
  self.NextRandomSound = nil
  self.NextGarbageDecrease = nil
  self:SetStopWorkTime(0)

  cw.entity:CreateItem(nil, self.WORK_ITEM, self:GetProductPos())
end

--- Does nothing; the recycler is operated through its entity menu options.
function ENT:Use(activator)
  return
end

--- Stops the recycler's work sound.
function ENT:OnRemove()
  if self.WorkSound then
    self.WorkSound:Stop()
  end
end
