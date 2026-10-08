--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

ITEM.name = 'Stationary Radio'
ITEM.PrintName = '#ITEM_Stationary_Radio'
ITEM.cost = 30
ITEM.model = 'models/props_lab/citizenradio.mdl'
ITEM.weight = 2
ITEM.access = 'v'
ITEM.classes = { CLASS_EMP, CLASS_EOW }
ITEM.category = 'Communication'
ITEM.business = true
ITEM.description = '#ITEM_Stationary_Radio_Desc'

--- Places a `cw_radio` entity owned by the player where they are looking, within 192 units.
--
-- Used from the ground, the radio takes the item entity's position and angles and stays frozen if it was;
-- otherwise it is placed flush to the ground. Keeps the item, with a notification, when the spot is too far.
function ITEM:OnUse(player, itemEntity)
  local trace = player:GetEyeTraceNoCursor()

  if trace.HitPos:Distance(player:GetShootPos()) <= 192 then
    local entity = ents.Create('cw_radio')

    cw.player:GiveProperty(player, entity)

    entity:SetItemTable(self)
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

--- Lets the item be dropped; nothing else happens.
function ITEM:OnDrop(player, position) end
