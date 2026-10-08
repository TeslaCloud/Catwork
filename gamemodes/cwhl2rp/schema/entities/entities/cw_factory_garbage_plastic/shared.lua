--- Shared definition of the `cw_factory_garbage_plastic` entity, a spawnable garbage recycler that turns plastic junk
-- items into `plastic` items, with its settings, network vars and think logic.
--
-- `ENT.GARBAGE_ITEMS` lists the accepted items (`empty_tin_can`, `empty_plastic_bottle` and `empty_jug`),
-- `ENT.METAL_GARBAGE_COUNT_START` (8) is the garbage needed for a cycle and `ENT.WORK_TIME` (20) its length in
-- seconds. `ENT:Think` absorbs accepted `cw_item` entities above an idle recycler, each counting twice its weight,
-- drains the count during a cycle and calls `ENT:EndWork` when the time is up. The single-file
-- `cw_factory_garbage_plastic.lua` next to this folder defines the same class and is loaded after it.

ENT.Base = 'base_gmodentity'
ENT.Type = 'anim'

ENT.PrintName = '#GarbageRecycler_PrintName_Plastic'
ENT.Category = '#GarbageRecycler_Category'
ENT.Author = 'AleXXX_007'

ENT.Contact			= ''
ENT.Purpose 		= ''
ENT.Instructions = ''

ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.IsFactory = true

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.Model = 'models/props_combine/combine_smallmonitor001.mdl'

ENT.WORK_ITEM = 'plastic'
ENT.WORK_TIME = 20
ENT.METAL_GARBAGE_COUNT_START = 8
ENT.GARBAGE_ITEMS = {
  'empty_tin_can',
  'empty_plastic_bottle',
  'empty_jug'
}

--- Declares the product position, garbage count, working state, work timing, eject storage and
-- stop time network vars.
function ENT:SetupDataTables()
  self:NetworkVar('Vector', 0, 'ProductPos')
  self:NetworkVar('Float', 2, 'GarbageCount')
  self:NetworkVar('Bool', 0, 'IsWorking')
  self:NetworkVar('Float', 0, 'StartWorkTime')
  self:NetworkVar('Float', 1, 'NextWorkTime')
  self:NetworkVar('Int', 0, 'EjectStorage')
  self:NetworkVar('Float', 3, 'StopWorkTime')
end

--- Collects garbage, plays the work sounds and advances the recycling cycle every tick on the server.
--
-- Garbage `cw_item` entities inside `ENT:GetSearchPos` are taken while the recycler is idle and not full.
-- During a cycle the garbage count drains step by step and `ENT:EndWork` runs when the time is up.
function ENT:Think()
  if SERVER then
    if !self:GetIsWorking() then
      if self:GetStopWorkTime() <= 0 then
        local pos = self:GetSearchPos()

        for k, v in pairs(ents.FindInBox(pos[1], pos[2])) do
          if self:GetGarbageCount() >= self.METAL_GARBAGE_COUNT_START then break end

          -- An item that was picked up this tick is still around until the tick ends.
          if v:GetClass() != 'cw_item' or v:IsMarkedForDeletion() then continue end

          local itemTable = v:GetItemTable()

          if !itemTable or !self:CanGarbageUsed(itemTable) then continue end

          v:Remove()
          self:SetGarbageCount(self:GetGarbageCount() + (itemTable('weight') or 0.5) * 2)
          self.Garbages[#self.Garbages + 1] = itemTable('uniqueID')
          self:EmitSound('items/ammocrate_close.wav')
        end
      end
    end

    if self.NextWorkSound and CurTime() > self.NextWorkSound then
      self.WorkSound = CreateSound(self, 'plats/rackmove1.wav')
      self.WorkSound:Play()
      self.NextRandomSound = CurTime() + 0.65
      self.NextWorkSound = nil
    end

    if self.NextRandomSound and CurTime() > self.NextRandomSound then
      if math.Rand(0, 1) > 0.8 then
        self:EmitSound('plats/hall_elev_stop.wav')
      end

      self.NextRandomSound = CurTime() + 0.65
    end

    if self:GetIsWorking() then
      if !self.NextGarbageDecrease then
        self.NextGarbageDecrease =
          CurTime() + ((self:GetNextWorkTime() - self:GetStartWorkTime()) - 5) / self.METAL_GARBAGE_COUNT_START
      elseif self.NextGarbageDecrease and CurTime() > self.NextGarbageDecrease then
        self:SetGarbageCount(math.Clamp(self:GetGarbageCount() - 1, 0, self.METAL_GARBAGE_COUNT_START))
        table.remove(self.Garbages)
        self.NextGarbageDecrease = nil
      end

      if CurTime() > self:GetNextWorkTime() then
        self:EndWork()
      end
    elseif self.WorkSound and self.WorkSound:IsPlaying() then
      self.WorkSound:Stop()
    end
  end

  self:NextThink(CurTime())
end
