--- English language strings of the Personal Doors plugin: the door access notifications and the help text of
-- `/DoorSetAccess` and `/DoorUnsetAccess`.

local lang = cw.lang:GetTable('en')

-- Notifications.
lang['#PersonalDoors_AccessGranted'] = "You have allowed '#1' access to this door."
lang['#PersonalDoors_AlreadyHasAccess'] = 'This player already has access to this door!'
lang['#PersonalDoors_AccessRemoved'] = "You have removed the ability of '#1' to access this door!"
lang['#PersonalDoors_AccessRemovedAll'] = 'You have removed the ability of all players to access this door!'
lang['#PersonalDoors_NotValidDoor'] = 'This is not a valid door!'

-- Commands.
lang['#Command_Doorsetaccess_Description'] = 'Allow a player to have access to a door.'
lang['#Command_Doorsetaccess_Syntax'] = '<string Name> [bool StartLocked]'
lang['#Command_Doorunsetaccess_Description'] = 'Remove the ability for a player to access a door.'
lang['#Command_Doorunsetaccess_Syntax'] = '[string Name]'
