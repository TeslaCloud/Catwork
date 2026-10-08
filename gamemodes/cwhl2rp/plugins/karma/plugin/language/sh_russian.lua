--- Russian language strings of the Karma plugin: the names of the karma levels, notifications and the descriptions and
-- syntax of `/KarmaSet`, `/KarmaGet`, `/KarmaAdd` and `/KarmaTake`.

local lang = cw.lang:GetTable('ru')

lang['#Karma'] = 'Карма'
lang['#Karma_InfoMenu'] = 'УРОВЕНЬ КАРМЫ'
lang['#Karma_Monster'] = 'Чудовище'
lang['#Karma_Evil'] = 'Злодей'
lang['#Karma_Criminal'] = 'Преступник'
lang['#Karma_Hooligan'] = 'Хулиган'
lang['#Karma_Neutral'] = 'Нейтральный'
lang['#Karma_Decent'] = 'Порядочный'
lang['#Karma_Kind'] = 'Хороший'
lang['#Karma_GoodSamaritan'] = 'Добродушный'
lang['#Karma_Divine'] = 'Божественный'
lang['#Karma_Error'] = 'Ошибка'

-- Notifications.
lang['#Karma_SetTo'] = 'Вы установили карму #1 на #2.'
lang['#Karma_InvalidLevel'] = 'Вы указали неверный уровень кармы.'

-- Commands.
lang['#Command_Karmaset_Description'] = 'Установить карму игрока.'
lang['#Command_Karmaset_Syntax'] = '<имя> <значение>'
lang['#Command_Karmaget_Description'] = 'Узнать карму игрока.'
lang['#Command_Karmaget_Syntax'] = '<имя>'
lang['#Command_Karmaadd_Description'] = 'Добавить карму игроку.'
lang['#Command_Karmaadd_Syntax'] = '<имя> <значение>'
lang['#Command_Karmatake_Description'] = 'Уменьшить карму игрока.'
lang['#Command_Karmatake_Syntax'] = '<имя> <значение>'
