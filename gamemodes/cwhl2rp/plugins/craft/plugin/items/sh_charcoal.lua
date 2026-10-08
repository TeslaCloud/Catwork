
ITEM.name = 'Charcoal'
ITEM.PrintName = '#Item_Charcoal_Name'
ITEM.model = 'models/props_debris/concrete_chunk05g.mdl'
ITEM.weight = 0.2
ITEM.category = 'Materials'
ITEM.business = false
ITEM.description = '#Item_Charcoal_Description'

--- Lets the item be dropped, with no extra effect.
function ITEM:OnDrop(player, position) end

--- Gives the dropped charcoal entity a wood bark material.
function ITEM:OnEntitySpawned(entity)
  entity:SetMaterial('models/props_foliage/tree_deciduous_01a_trunk')
end
