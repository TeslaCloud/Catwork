--- English language strings for the Door Commands plugin, its commands and its door tools.

local lang = cw.lang:GetTable('en')

-- Tools
lang['#tool.doortool.name'] = 'Door Tool'
lang['#tool.doortool.desc'] = 'Do various things with doors.'
lang['#tool.doortool.0'] = 'Primary: Do Action | Secondary: Do Action (If Applicable)'
lang['#tool.doortool.mode'] = 'Tool Mode'
lang['#tool.doortool.mode1'] = 'Lock/Unlock Door'
lang['#tool.doortool.mode1desc'] = 'Lock and unlock doors!'
lang['#tool.doortool.mode2'] = 'Door Set Ownable'
lang['#tool.doortool.mode3'] = 'Door Set Unownable'
lang['#tool.doortool.doorname'] = 'Door Name'
lang['#tool.doortool.doordesc'] = 'Door Description'
lang['#tool.doorparent.name'] = 'Door Parenting Manager'
lang['#tool.doorparent.desc'] = 'Manage parent doors.'
lang['#tool.doorparent.0'] = 'Primary: Set Parent/Child | Reload: Clear Active Parent | Secondary: Remove Door Parent'
lang['#tool.doorparent.header'] = 'Door Parenting'
lang['#tool.doorparent.helpTitle'] = 'Help'
lang['#tool.doorparent.help'] = "Door parenting lets you create a parent door, and once a player purchases that door, they will have access to the door's 'children', thus eliminating the need to set every door ownable.\n\nHow to use door parenting:\n\n1. First, choose a parent door using Left Click. This is usually the 'front' door.\n\n2. Now Left Click any doors within the property.\n\n3. Now you may make the front door 'ownable'. You can also make the other doors unownable to set text on them.\n\n*Make sure you unset the parent door once you are done."

-- Config
lang['#DoorsDefaultHidden'] = 'Doors Default Hidden'
lang['#DoorsDefaultHiddenDesc'] = 'Set whether doors are hidden and unownable by default.'
lang['#DoorsSaveState'] = 'Doors Save State'
lang['#DoorsSaveStateDesc'] = 'Set whether or not doors will save being open or closed and locked.'

-- Notifications
lang['#DoorCmds_NotValidDoor'] = 'This is not a valid door!'
lang['#DoorCmds_ChildAdded'] = 'You have added this as a child to the active parent door.'
lang['#DoorCmds_CannotParentToItself'] = 'You cannot parent the active parent door to itself!'
lang['#DoorCmds_AlreadyChild'] = 'This door is already a child of the active parent door!'
lang['#DoorCmds_NoValidParent'] = 'You have not selected a valid parent door!'
lang['#DoorCmds_Locked'] = 'You have locked the target door.'
lang['#DoorCmds_Unlocked'] = 'You have unlocked the target door.'
lang['#DoorCmds_MadeFalse'] = 'You have made this door false.'
lang['#DoorCmds_MadeNotFalse'] = 'This door is no longer false.'
lang['#DoorCmds_AllSetUnownable'] = '#1 doors have been set unownable.'
lang['#DoorCmds_AllSetOwnable'] = '#1 doors have been set ownable.'
lang['#DoorCmds_AllDoorsReminder'] = 'Remember: This is ALL doors!'
lang['#DoorCmds_ParentSet'] = 'You have set the active parent door to this. The parent has been highlighted orange, and its children blue.'
lang['#DoorCmds_ParentCleared'] = 'You have cleared your active parent door.'
lang['#DoorCmds_NoActiveParent'] = 'You do not have an active parent door.'
lang['#DoorCmds_SetOwnable'] = 'You have set an ownable door.'
lang['#DoorCmds_SetUnownable'] = 'You have set an unownable door.'
lang['#DoorCmds_Unparented'] = 'You have unparented this door.'
lang['#DoorCmds_Hidden'] = 'You have hidden this door.'
lang['#DoorCmds_Unhidden'] = 'You have unhidden this door.'

-- Commands
lang['#Command_Doorlock_Description'] = 'Lock a door.'
lang['#Command_Doorresetparent_Description'] = "Reset the player's active parent door."
lang['#Command_Doorsetallownable_Description'] = 'Set all doors ownable.'
lang['#Command_Doorsetallownable_Syntax'] = '<string Name>'
lang['#Command_Doorsetallunownable_Description'] = 'Set all doors unownable.'
lang['#Command_Doorsetallunownable_Syntax'] = '<string Name>'
lang['#Command_Doorsetchild_Description'] = 'Add a child to the active parent door.'
lang['#Command_Doorsetfalse_Description'] = 'Set whether a door is false.'
lang['#Command_Doorsetfalse_Syntax'] = '<bool IsFalse>'
lang['#Command_Doorsethidden_Description'] = 'Set whether a door is hidden.'
lang['#Command_Doorsethidden_Syntax'] = '<bool IsHidden>'
lang['#Command_Doorsetownable_Description'] = 'Set an ownable door.'
lang['#Command_Doorsetownable_Syntax'] = '<string Name>'
lang['#Command_Doorsetparent_Description'] = 'Set the active parent door to your target.'
lang['#Command_Doorsetunownable_Description'] = 'Set an unownable door.'
lang['#Command_Doorsetunownable_Syntax'] = '<string Name> [string Text]'
lang['#Command_Doorunlock_Description'] = 'Unlock a door.'
lang['#Command_Doorunparent_Description'] = 'Unparent the target door.'
