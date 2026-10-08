--- Russian strings of the Apply plugin: its config, notifications and the descriptions of `/Apply`, `/ApplySay`,
-- `/Name` and `/NameSay`.

local lang = cw.lang:GetTable('ru')

-- Config.
lang['#Apply_RecogniseEnable'] = 'Включить узнавание при /Apply'
lang['#Apply_RecogniseEnableDesc'] = 'Должны ли игроки узнавать других персонажей, когда те используют /Apply.'

-- Notifications.
lang['#Apply_NoCIDSorry'] = 'Извините, но у Вас нет CID. Используйте /Name!'
lang['#Apply_NoCID'] = 'Похоже, у Вас нет CID. Используйте /Name!'

-- Commands.
lang['#Command_Apply_Description'] = 'Назвать своё имя и CID.'
lang['#Command_Applysay_Description'] = 'Назвать своё имя и CID в неформальной манере.'
lang['#Command_Name_Description'] = 'Назвать своё имя.'
lang['#Command_Namesay_Description'] = 'Назвать своё имя в неформальной манере.'
