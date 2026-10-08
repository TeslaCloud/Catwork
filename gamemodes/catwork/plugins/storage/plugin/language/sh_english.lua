--- English strings of the Storage plugin: container labels, the names of the container types, notifications and the
-- descriptions and syntax of the `/Cont` commands.

local lang = cw.lang:GetTable('en')

-- Containers
lang['#Container_Name'] = 'Container'
lang['#Container_TargetID'] = 'You can put something in here.'
lang['#Container_Message'] = 'Message'
lang['#Container_Password'] = 'Password'
lang['#Container_PasswordRequest'] = 'What is the password for this container?'

-- Container names
lang['#Container_Closet'] = 'Closet'
lang['#Container_FileCabinet'] = 'File Cabinet'
lang['#Container_Suitcase'] = 'Suitcase'
lang['#Container_WoodenCrate'] = 'Wooden Crate'
lang['#Container_Desk'] = 'Desk'
lang['#Container_Refrigerator'] = 'Refrigerator'
lang['#Container_Dumpster'] = 'Dumpster'
lang['#Container_LargeCrate'] = 'Large Crate'
lang['#Container_TrashBin'] = 'Trash Bin'
lang['#Container_Crate'] = 'Crate'
lang['#Container_Barrel'] = 'Barrel'
lang['#Container_Box'] = 'Box'
lang['#Container_IndustrialRefrigerator'] = 'Industrial Refrigerator'
lang['#Container_Mailbox'] = 'Mailbox'
lang['#Container_LargeFileCabinet'] = 'Large File Cabinet'
lang['#Container_Chest'] = 'Chest'
lang['#Container_WashingMachine'] = 'Washing Machine'
lang['#Container_Stove'] = 'Stove'
lang['#Container_Locker'] = 'Locker'
lang['#Container_CargoContainer'] = 'Cargo Container'
lang['#Container_Briefcase'] = 'Briefcase'
lang['#Container_Table'] = 'Table'
lang['#Container_Dryer'] = 'Dryer'
lang['#Container_Cupboard'] = 'Cupboard'
lang['#Container_KitchenCounter'] = 'Kitchen Counter'
lang['#Container_PaintCan'] = 'Paint Can'
lang['#Container_AmmoBox'] = 'Ammo Box'
lang['#Container_Boxes'] = 'Boxes'
lang['#Container_Lockers'] = 'Lockers'

-- Notifications
lang['#Container_NotValid'] = 'This is not a valid container!'
lang['#Container_NotValidScale'] = 'This is not a valid scale!'
lang['#Container_CategoryNotExist'] = "That category doesn't exist!"
lang['#Container_Filled'] = 'This container has been filled with random items.'
lang['#Container_MessageSet'] = "You have set this container's message."
lang['#Container_PasswordSet'] = "This container's password has been set to"
lang['#Container_PasswordRemoved'] = "This container's password has been removed."
lang['#Container_WrongPassword'] = 'You have entered an incorrect password!'

-- Commands
lang['#Command_Contfill_Description'] = 'Fill a container with random items.'
lang['#Command_Contfill_Syntax'] = '<number Density: 1-5> [string Category]'
lang['#Command_Contsetmessage_Description'] = "Set a container's message."
lang['#Command_Contsetmessage_Syntax'] = '<string Message>'
lang['#Command_Contsetname_Description'] = "Set a container's name."
lang['#Command_Contsetname_Syntax'] = '[string Name]'
lang['#Command_Contsetpassword_Description'] = "Set a container's password."
lang['#Command_Contsetpassword_Syntax'] = '<string Pass>'
lang['#Command_Conttakename_Description'] = "Take a container's name."
lang['#Command_Conttakepassword_Description'] = "Take a container's password."
