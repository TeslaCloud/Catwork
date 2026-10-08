--- English language strings of the Gathering plugin: the `nodes_respawn_delay` config key, notifications and the
-- descriptions of `/WoodAdd` and `/WoodRemove`.

local lang = cw.lang:GetTable('en')

-- Config.
lang['#Gathering_NodesRespawnDelay'] = 'Nodes Respawn Delay'
lang['#Gathering_NodesRespawnDelayDesc'] = 'Rate at which a gathering spawn point respawns (in seconds).'

-- Notifications.
lang['#Gathering_RemovedPoint'] = 'You have removed #1 furniture spawn point.'
lang['#Gathering_RemovedPoints'] = 'You have removed #1 furniture spawn points.'
lang['#Gathering_NoPointsFound'] = 'No spawn points were found.'
lang['#Gathering_AddedWoodPoint'] = 'You have added a wooden furniture spawn point.'
lang['#Gathering_MustCrouch'] = 'You must crouch to start collecting garbage.'

-- Commands.
lang['#Command_Woodadd_Description'] = 'Add a spawn point for wooden furniture that can be harvested.'
lang['#Command_Woodremove_Description'] = 'Remove a wooden furniture spawn point.'
