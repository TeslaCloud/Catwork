--- Russian language strings for the Catwork Dev Plugin and its `/SetCharData` command.

local lang = cw.lang:GetTable('ru')

lang['#Developer_CannotSetTable'] = 'Нельзя устанавливать значения-таблицы!'
lang['#Developer_CannotSetUserData'] = 'Нельзя устанавливать значения типа UserData!'
lang['#Developer_NotANumber'] = 'В этом ключе хранится число, поэтому значение должно быть числом!'
lang['#Developer_ModifiedKey'] = 'Вы изменили ключ данных персонажа'
lang['#Developer_CreatedKey'] = 'Вы создали новый ключ данных персонажа'
lang['#Developer_Value'] = 'значение:'
lang['#Developer_OriginalType'] = 'Исходный тип данных:'
lang['#Developer_KeyMustBeString'] = 'Ключ должен быть строкой!'
lang['#Developer_NotAuthorized'] = 'У вас нет прав на использование этой команды!'

-- Commands
lang['#Command_Setchardata_Description'] = 'Установить данные персонажа игрока.'
lang['#Command_Setchardata_Syntax'] = '<игрок> <ключ> <значение>'
