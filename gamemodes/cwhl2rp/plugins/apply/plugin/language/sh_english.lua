--- English strings of the Apply plugin: its config, notifications and the descriptions of `/Apply`, `/ApplySay`,
-- `/Name` and `/NameSay`.

local lang = cw.lang:GetTable('en')

-- Config.
lang['#Apply_RecogniseEnable'] = 'Enable Apply Recognise'
lang['#Apply_RecogniseEnableDesc'] = 'Whether or not players should recognise other characters when they use /Apply.'

-- Notifications.
lang['#Apply_NoCIDSorry'] = 'Sorry, but you do not have a CID. Use /Name instead!'
lang['#Apply_NoCID'] = 'You do not appear to have a CID. Use /Name instead!'

-- Commands.
lang['#Command_Apply_Description'] = 'Says your name and CID.'
lang['#Command_Applysay_Description'] = 'Says your name and CID informally.'
lang['#Command_Name_Description'] = 'Says your name.'
lang['#Command_Namesay_Description'] = 'Says your name informally.'
