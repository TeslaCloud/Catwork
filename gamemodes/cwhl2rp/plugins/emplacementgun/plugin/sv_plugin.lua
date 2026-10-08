local PLUGIN = PLUGIN

--- Called after Catwork has loaded the map entities; spawns the saved emplacement guns.
function PLUGIN:ClockworkInitPostEntity()
  self:LoadEmplacementGuns()
end

--- Called after data is saved; saves the emplacement guns.
function PLUGIN:PostSaveData()
  self:SaveEmplacementGuns()
end

--- Spawns the emplacement guns saved for the current map, each on a new frozen barricade.
function PLUGIN:LoadEmplacementGuns()
  local emplacementGuns = cw.core:RestoreSchemaData('plugins/emplacementGuns/'..game.GetMap())

  for k, v in pairs(emplacementGuns) do
    local entity = ents.Create('cw_emplacementgun')
    entity:SetAngles(v.angles)
    entity:SetPos(v.position)
    entity:Spawn()
    entity:Activate()
    entity:SpawnProp()

    if IsValid(entity) then
      entity:SetAngles(v.angles)
    end
  end
end

--- Saves the position and angles of every `cw_emplacementgun` on the map to the schema data.
--
-- Writes `plugins/emplacementGuns/<map>`.
function PLUGIN:SaveEmplacementGuns()
  local emplacementGuns = {}

  for k, v in pairs(ents.FindByClass('cw_emplacementgun')) do
    emplacementGuns[#emplacementGuns + 1] = {
      angles = v:GetAngles(),
      position = v:GetPos(),
      uniqueID = cw.entity:QueryProperty(v, 'uniqueID')
    }
  end

  cw.core:SaveSchemaData('plugins/emplacementGuns/'..game.GetMap(), emplacementGuns)
end
