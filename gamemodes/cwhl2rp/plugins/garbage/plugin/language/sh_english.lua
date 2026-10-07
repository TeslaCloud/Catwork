--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

local lang = cw.lang:GetTable('en')

-- Config.
lang['#Garbage_RespawnDelay'] = 'Garbage Respawn Delay'
lang['#Garbage_RespawnDelayDesc'] = 'Rate at which a garbage spawn point respawns (in seconds).'
lang['#Garbage_PickupTime'] = 'Garbage Pickup Time'
lang['#Garbage_PickupTimeDesc'] = 'The time it takes to clean up one garbage entity (in seconds).'
lang['#Garbage_ItemPercentage'] = 'Garbage Item Percentage'
lang['#Garbage_ItemPercentageDesc'] = 'The chance of a player finding something in a garbage pile (in percent).'

-- Attributes.
lang['#Attribute_Scavenger'] = 'Scavenger'
lang['#Attribute_Scavenger_Desc'] = 'Affects the chance of finding something valuable in the garbage.'

-- Notifications.
lang['#Garbage_Jackpot'] = 'Ding ding ding, jackpot! 10x RPG!'
lang['#Garbage_FoundRPG'] = 'You have found an RPG. The things people throw in the garbage.'
lang['#Garbage_Found'] = 'You have found:'
lang['#Garbage_FoundNothing'] = 'You have found nothing.'
lang['#Garbage_MustCrouch'] = 'You must crouch to start collecting garbage.'
lang['#Garbage_ProgressHarvesting'] = 'You are harvesting the crops...'
lang['#Garbage_RemovedSpawn'] = 'You have removed #1 garbage spawn.'
lang['#Garbage_RemovedSpawns'] = 'You have removed #1 garbage spawns.'
lang['#Garbage_NoSpawnsNear'] = 'There were no garbage spawns near this position.'
lang['#Garbage_AddedPoint'] = 'You have added a garbage point.'

-- Commands.
lang['#Command_Garbageremove_Description'] = 'Removes the garbage spawn point at your view target.'
lang['#Command_Garbageadd_Description'] = 'Spawns a garbage entity at your target location.'
