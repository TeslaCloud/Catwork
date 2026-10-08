--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

ITEM.isBaseItem = true
ITEM.name = 'Book Base'
ITEM.weight = 0.4
ITEM.access = '3'
ITEM.category = 'Literature'

--- Places the book as a `cw_book` owned by the player where they are looking, within 192 units.
--
-- When used from the ground, the book takes the item entity's place and stays frozen if the
-- item was.
--
-- @return [Boolean `false` when the spot is too far away]
function ITEM:OnUse(player, itemEntity)
  local trace = player:GetEyeTraceNoCursor()

  if trace.HitPos:Distance(player:GetShootPos()) <= 192 then
    local entity = ents.Create('cw_book')

    cw.player:GiveProperty(player, entity)

    entity:SetModel(self.model)
    entity:SetBook(self.uniqueID)
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
    cw.player:Notify(player, '#CantDropFar')

    return false
  end
end

--- Turns the book's `bookInformation` text into HTML for the book window.
--
-- Line breaks become `<br>` and tabs four non-breaking spaces.
function ITEM:OnSetup()
  if self.bookInformation then
    self.bookInformation = string.gsub(string.gsub(self.bookInformation, '\n', '<br>'), '\t', string.rep('&nbsp;', 4))
    self.bookInformation = "<html><font face='Arial' size='2'>"..self.bookInformation..'</font></html>'
  end
end
