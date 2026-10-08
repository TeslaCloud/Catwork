--- English language strings of the Hunger plugin: the hunger and thirst config keys, notifications and the descriptions
-- and syntax of `/CharSetHunger`, `/CharSetThirst`, `/CharSetFatigue`, `/CharResetNeeds` and `/Sleep`.

local lang = cw.lang:GetTable('en')

-- Config.
lang['#Hunger_Tick'] = 'Hunger Tick'
lang['#Hunger_TickDesc'] = 'How quickly the hunger bar drains (higher = slower).'
lang['#Hunger_DefaultRefill'] = 'Hunger Default Refill'
lang['#Hunger_DefaultRefillDesc'] = 'The default amount of hunger to be restored when a player eats food (in percent).'
lang['#Hunger_ThirstTick'] = 'Thirst Tick'
lang['#Hunger_ThirstTickDesc'] = 'How quickly thirst blocks the hunger bar (higher = slower).'
lang['#Hunger_ThirstDrainScale'] = 'Thirst Drain Scale'
lang['#Hunger_ThirstDrainScaleDesc'] = 'How quickly thirst drains when a player runs or jumps (in percent).'

-- Notifications.
lang['#Hunger_HungerSetBy'] = '#1 has set your hunger to #2.'
lang['#Hunger_HungerSet'] = "You have set #1's hunger to #2."
lang['#Hunger_HungerSetOwn'] = 'You have set your own hunger to #1.'
lang['#Hunger_ThirstSetBy'] = '#1 has set your thirst to #2.'
lang['#Hunger_ThirstSet'] = "You have set #1's thirst to #2."
lang['#Hunger_ThirstSetOwn'] = 'You have set your own thirst to #1.'
lang['#Hunger_SleepSetBy'] = '#1 has set your sleep to #2.'
lang['#Hunger_SleepSet'] = "You have set #1's sleep to #2."
lang['#Hunger_SleepSetOwn'] = 'You have set your own sleep to #1.'
lang['#Hunger_NeedsSetBy'] = '#1 has set your needs to full.'
lang['#Hunger_NeedsSet'] = "You have set #1's needs to full."
lang['#Hunger_NeedsSetOwn'] = 'You have set your own needs to full.'
lang['#Hunger_PlayerIsCombine'] = 'This player is a Combine!'
lang['#Hunger_TooAwakeToSleep'] = 'You are too awake to sleep!'

-- Commands.
lang['#Command_Charsethunger_Description'] = "Set a player's hunger level."
lang['#Command_Charsethunger_Syntax'] = '<string Name> <number Amount>'
lang['#Command_Charsetthirst_Description'] = "Set a player's thirst level."
lang['#Command_Charsetthirst_Syntax'] = '<string Name> <number Amount>'
lang['#Command_Charsetfatigue_Description'] = "Set a player's sleep level."
lang['#Command_Charsetfatigue_Syntax'] = '<string Name> <number Amount>'
lang['#Command_Charresetneeds_Description'] = "Set a player's needs level to 100."
lang['#Command_Charresetneeds_Syntax'] = '<string Name>'
lang['#Command_Sleep_Description'] = 'Good night.'
