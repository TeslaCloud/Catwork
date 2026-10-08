--- Defines the `Notepad` item of the Notepad plugin, which places a blank `cw_notepad` entity owned by the player where
-- they are looking.

ITEM.name = 'Notepad'
ITEM.PrintName = '#Notepad_Title'
ITEM.cost = 5
ITEM.model = 'models/props_lab/clipboard.mdl'
ITEM.weight = 0.1
ITEM.access = '1v'
ITEM.classes = { CLASS_EMP, CLASS_EOW }
ITEM.business = true
ITEM.description = '#Item_Notepad_Description'

--- Places a blank `cw_notepad` owned by the player where they are looking, within 192 units.
--
-- When used from the ground, the notepad takes the item entity's place and stays frozen if
-- the item was.
--
-- @return [Boolean `false` when the spot is too far away]
function ITEM:OnUse(player, itemEntity)
  local trace = player:GetEyeTraceNoCursor()

  if trace.HitPos:Distance(player:GetShootPos()) <= 192 then
    local entity = ents.Create('cw_notepad')

    cw.player:GiveProperty(player, entity)

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

--- Called when the notepad is dropped; does nothing, so it can be dropped freely.
function ITEM:OnDrop(player, position) end
