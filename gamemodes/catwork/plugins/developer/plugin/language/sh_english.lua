--- English language strings for the Catwork Dev Plugin and its `/SetCharData` command.

local lang = cw.lang:GetTable('en')

lang['#Developer_CannotSetTable'] = 'Cannot set table values!'
lang['#Developer_CannotSetUserData'] = 'Cannot set UserData values!'
lang['#Developer_NotANumber'] = 'This key holds a number, so the value must be a number!'
lang['#Developer_ModifiedKey'] = 'You have modified a char data key'
lang['#Developer_CreatedKey'] = 'You have created a new char data key'
lang['#Developer_Value'] = 'value:'
lang['#Developer_OriginalType'] = 'The original data type was:'
lang['#Developer_KeyMustBeString'] = 'The key must be a valid string value!'
lang['#Developer_NotAuthorized'] = 'You are not authorized to use this command!'

-- Commands
lang['#Command_Setchardata_Description'] = "Set a player's character data."
lang['#Command_Setchardata_Syntax'] = '<string Player> <string key> <any value>'
