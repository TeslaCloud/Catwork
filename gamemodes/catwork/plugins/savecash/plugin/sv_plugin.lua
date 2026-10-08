--- Server-side functions of the Save Cash plugin that save and respawn the `cw_cash` entities on the map.
--
-- `cwSaveCash:SaveCash` and `cwSaveCash:LoadCash` keep each entity's amount, position, angles, frozen state and owner
-- properties in the schema data under `plugins/cash/<map>`.

--- Spawns the cash entities saved for the current map.
--
-- Restores each entity's amount, position, angles, owner key and unique ID, and freezes the ones that
-- were frozen when saved.
function cwSaveCash:LoadCash()
  local cash = cw.core:RestoreSchemaData('plugins/cash/'..game.GetMap())

  for k, v in pairs(cash) do
    local entity = cw.entity:CreateCash({ key = v.key, uniqueID = v.uniqueID }, v.amount, v.position, v.angles)

    if IsValid(entity) and !v.isMoveable then
      local physicsObject = entity:GetPhysicsObject()

      if IsValid(physicsObject) then
        physicsObject:EnableMotion(false)
      end
    end
  end
end

--- Saves every `cw_cash` entity on the map to the schema data.
--
-- Stores the amount, position, angles, whether it can move, and the `key` and `uniqueID` properties.
function cwSaveCash:SaveCash()
  local cash = {}

  for k, v in pairs(ents.FindByClass('cw_cash')) do
    local physicsObject = v:GetPhysicsObject()
    local bMoveable = nil

    if IsValid(physicsObject) then
      bMoveable = physicsObject:IsMoveable()
    end

    cash[#cash + 1] = {
      key = cw.entity:QueryProperty(v, 'key'),
      angles = v:GetAngles(),
      amount = v.cwAmount,
      uniqueID = cw.entity:QueryProperty(v, 'uniqueID'),
      position = v:GetPos(),
      isMoveable = bMoveable
    }
  end

  cw.core:SaveSchemaData('plugins/cash/'..game.GetMap(), cash)
end
