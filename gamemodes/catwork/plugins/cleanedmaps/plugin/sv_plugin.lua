--- Defines the Cleaned Maps plugin's `remove_map_physics` config key and `cwCleanedMaps.entityList`, the entity classes
-- removed from every map.

config.Add('remove_map_physics', false, nil, nil, nil, nil, true)

cwCleanedMaps.entityList = {
  'item_healthcharger',
  'item_suitcharger',
  'weapon_*'
}
