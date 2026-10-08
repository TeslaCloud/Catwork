--- English language strings of the Karma plugin: the names of the karma levels, notifications and the descriptions and
-- syntax of `/KarmaSet`, `/KarmaGet`, `/KarmaAdd` and `/KarmaTake`.

local lang = cw.lang:GetTable('en')

lang['#Karma'] = 'Karma'
lang['#Karma_InfoMenu'] = 'KARMA LEVEL'
lang['#Karma_Monster'] = 'Monster'
lang['#Karma_Evil'] = 'Evil'
lang['#Karma_Criminal'] = 'Criminal'
lang['#Karma_Hooligan'] = 'Hooligan'
lang['#Karma_Neutral'] = 'Neutral'
lang['#Karma_Decent'] = 'Decent'
lang['#Karma_Kind'] = 'Kind'
lang['#Karma_GoodSamaritan'] = 'Good Samaritan'
lang['#Karma_Divine'] = 'Divine'
lang['#Karma_Error'] = 'Error'

-- Notifications.
lang['#Karma_SetTo'] = "You have set #1's karma to #2."
lang['#Karma_InvalidLevel'] = 'You have specified an invalid karma level.'

-- Commands.
lang['#Command_Karmaset_Description'] = "Set a player's karma."
lang['#Command_Karmaset_Syntax'] = '<string Name> <number Value>'
lang['#Command_Karmaget_Description'] = "Get a player's karma."
lang['#Command_Karmaget_Syntax'] = '<string Name>'
lang['#Command_Karmaadd_Description'] = 'Add karma to a player.'
lang['#Command_Karmaadd_Syntax'] = '<string Name> <number Value>'
lang['#Command_Karmatake_Description'] = "Reduce a player's karma."
lang['#Command_Karmatake_Syntax'] = '<string Name> <number Value>'
