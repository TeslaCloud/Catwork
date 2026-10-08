--- English strings of the Spawn Points plugin: notifications and the descriptions and syntax of `/SpawnPointAdd` and
-- `/SpawnPointRemove`.

local lang = cw.lang:GetTable('en')

lang['#SpawnPoints_Added'] = 'You have added a spawn point for #1.'
lang['#SpawnPoints_AddedDefault'] = 'You have added a default spawn point.'
lang['#SpawnPoints_NotValidClassOrFaction'] = 'This is not a valid class or faction!'
lang['#SpawnPoints_RemovedOne'] = 'You have removed #1 #2 spawn point.'
lang['#SpawnPoints_RemovedMany'] = 'You have removed #1 #2 spawn points.'
lang['#SpawnPoints_NoneNear'] = 'There were no #1 spawn points near this position.'
lang['#SpawnPoints_None'] = 'There are no #1 spawn points.'
lang['#SpawnPoints_RemovedDefaultOne'] = 'You have removed #1 default spawn point.'
lang['#SpawnPoints_RemovedDefaultMany'] = 'You have removed #1 default spawn points.'
lang['#SpawnPoints_NoneNearDefault'] = 'There were no default spawn points near this position.'
lang['#SpawnPoints_NoneDefault'] = 'There are no default spawn points.'

-- Commands
lang['#Command_Spawnpointadd_Description'] = 'Add a spawn point at your target position.'
lang['#Command_Spawnpointadd_Syntax'] = '<string Class|Faction|Default> [number Rotate]'
lang['#Command_Spawnpointremove_Description'] = 'Remove spawn points at your target position.'
lang['#Command_Spawnpointremove_Syntax'] = '<string Class|Faction|Default>'
