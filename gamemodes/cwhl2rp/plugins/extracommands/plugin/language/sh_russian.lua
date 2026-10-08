--- Russian language strings of the Extra Commands plugin: notifications and the descriptions and syntax of
-- `/Overwatch`, `/PlyResetArmor`, `/PlyResetHealth`, `/CharSetSkin`, `/CharSetBodyGroup`, `/PlySetIcon` and
-- `/CharSetAttribute`.

local lang = cw.lang:GetTable('ru')

-- Notifications.
lang['#ExtraCommands_OverwatchSays'] = 'Надзор сообщает'
lang['#ExtraCommands_MessageTooShort'] = 'Ваше сообщение должно быть не короче 6 символов!'
lang['#ExtraCommands_ArmorReset'] = 'Вы восстановили броню игрока #1 до 100.'
lang['#ExtraCommands_HealthReset'] = 'Вы восстановили здоровье игрока #1 до #2.'
lang['#ExtraCommands_IconSet'] = 'Вы установили игроку #1 иконку чата:'
lang['#ExtraCommands_NotPng'] = 'не является файлом .png!'
lang['#ExtraCommands_AttributeSet'] = 'Вы установили атрибут #2 [#3] игрока #1 на #4.'
lang['#ExtraCommands_NotValidAttribute'] = "Атрибута '#1' не существует!"

-- Commands.
lang['#Command_Overwatch_Description'] = 'Отправить сообщение всем юнитам Гражданской Обороны.'
lang['#Command_Overwatch_Syntax'] = '<текст>'
lang['#Command_Plyresetarmor_Description'] = 'Восстановить броню игрока до максимума.'
lang['#Command_Plyresetarmor_Syntax'] = '<имя>'
lang['#Command_Plyresethealth_Description'] = 'Восстановить здоровье игрока до максимума.'
lang['#Command_Plyresethealth_Syntax'] = '<имя>'
lang['#Command_Charsetskin_Description'] = 'Установить скин игрока.'
lang['#Command_Charsetskin_Syntax'] = '<имя> <номер скина>'
lang['#Command_Charsetbodygroup_Description'] = 'Установить бодигруппу игрока.'
lang['#Command_Charsetbodygroup_Syntax'] = '<имя> <номер бодигруппы> [значение бодигруппы]'
lang['#Command_Plyseticon_Description'] = 'Установить иконку чата игрока.'
lang['#Command_Plyseticon_Syntax'] = '<имя> <путь или URL>'
lang['#Command_Charsetattribute_Description'] = 'Установить значение атрибута персонажа.'
lang['#Command_Charsetattribute_Syntax'] = '<имя> <атрибут> <количество>'
