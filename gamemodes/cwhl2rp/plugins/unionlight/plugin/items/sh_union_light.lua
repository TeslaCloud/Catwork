
ITEM.name = 'Union Light'
ITEM.PrintName = '#Item_UnionLight_PrintName'
ITEM.cost = 50
ITEM.model = 'models/props_combine/combine_light001a.mdl'
ITEM.weight = 4
ITEM.classes = { CLASS_EMP, CLASS_EOW }
ITEM.category = 'Lights'
ITEM.useText = '#Item_UnionLight_UseText'
ITEM.business = true
ITEM.description = '#Item_UnionLight_Description'

--- Places a `cw_unionlight` owned by the player where they are looking, within 192 units.
--
-- When used from the ground, the light takes the item entity's place and stays frozen if
-- the item was.
--
-- @return [Boolean `false` when the spot is too far away]
function ITEM:OnUse(player, itemEntity)
  local trace = player:GetEyeTraceNoCursor()
  local entity = ents.Create('cw_unionlight')

  if trace.HitPos:Distance(player:GetShootPos()) <= 192 then
    cw.player:GiveProperty(player, entity)

    entity:SetModel(self.model)
    entity:SetPos(trace.HitPos)
    entity:Spawn()

    if IsValid(itemEntity) then
      local physicsObject = itemEntity:GetPhysicsObject()

      entity:SetPos(itemEntity:GetPos())
      entity:SetAngles(itemEntity:GetAngles())

      if IsValid(physicsObject) then
        if !physicsObject:IsMoveable() then
          physicsObject = entity:GetPhysicsObject()

          if IsValid(physicsObject) then
            physicsObject:EnableMotion(false)
          end
        end
      end
    else
      cw.entity:MakeFlushToGround(entity, trace.HitPos, trace.HitNormal)
    end
  else
    cw.player:Notify(player, L('CantDropFar'))

    return false
  end
end

--- Called when the union light is dropped; does nothing, so it can be dropped freely.
function ITEM:OnDrop(player, position) end
