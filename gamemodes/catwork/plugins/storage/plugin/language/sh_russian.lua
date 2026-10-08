--- Russian strings of the Storage plugin: container labels, the names of the container types, notifications and the
-- descriptions and syntax of the `/Cont` commands.

local lang = cw.lang:GetTable('ru')

-- Containers
lang['#Container_Name'] = 'Контейнер'
lang['#Container_TargetID'] = 'Вы можете положить сюда что-нибудь.'
lang['#Container_Message'] = 'Сообщение'
lang['#Container_Password'] = 'Пароль'
lang['#Container_PasswordRequest'] = 'Какой пароль к этому контейнеру?'

-- Container names
lang['#Container_Closet'] = 'Шкаф'
lang['#Container_FileCabinet'] = 'Картотечный шкаф'
lang['#Container_Suitcase'] = 'Кейс'
lang['#Container_WoodenCrate'] = 'Деревянный ящик'
lang['#Container_Desk'] = 'Письменный стол'
lang['#Container_Refrigerator'] = 'Холодильник'
lang['#Container_Dumpster'] = 'Мусорный ящик'
lang['#Container_LargeCrate'] = 'Большой ящик'
lang['#Container_TrashBin'] = 'Мусорка'
lang['#Container_Crate'] = 'Ящик'
lang['#Container_Barrel'] = 'Бочка'
lang['#Container_Box'] = 'Коробка'
lang['#Container_IndustrialRefrigerator'] = 'Промышленный холодильник'
lang['#Container_Mailbox'] = 'Почтовый ящик'
lang['#Container_LargeFileCabinet'] = 'Большой картотечный шкаф'
lang['#Container_Chest'] = 'Сундук'
lang['#Container_WashingMachine'] = 'Стиральная машина'
lang['#Container_Stove'] = 'Плита'
lang['#Container_Locker'] = 'Шкафчик'
lang['#Container_CargoContainer'] = 'Грузовой контейнер'
lang['#Container_Briefcase'] = 'Чемодан'
lang['#Container_Table'] = 'Стол'
lang['#Container_Dryer'] = 'Сушилка'
lang['#Container_Cupboard'] = 'Буфет'
lang['#Container_KitchenCounter'] = 'Кухонный стол'
lang['#Container_PaintCan'] = 'Банка из-под краски'
lang['#Container_AmmoBox'] = 'Коробка от патронов'
lang['#Container_Boxes'] = 'Коробки'
lang['#Container_Lockers'] = 'Шкафчики'

-- Notifications
lang['#Container_NotValid'] = 'Это не контейнер!'
lang['#Container_NotValidScale'] = 'Недопустимое значение плотности!'
lang['#Container_CategoryNotExist'] = 'Такой категории не существует!'
lang['#Container_Filled'] = 'Этот контейнер был заполнен случайными предметами.'
lang['#Container_MessageSet'] = 'Вы установили сообщение этого контейнера.'
lang['#Container_PasswordSet'] = 'Пароль этого контейнера установлен на'
lang['#Container_PasswordRemoved'] = 'Пароль этого контейнера был убран.'
lang['#Container_WrongPassword'] = 'Вы ввели неверный пароль!'

-- Commands
lang['#Command_Contfill_Description'] = 'Заполнить контейнер случайными предметами.'
lang['#Command_Contfill_Syntax'] = '<плотность: 1-5> [категория]'
lang['#Command_Contsetmessage_Description'] = 'Установить сообщение контейнера.'
lang['#Command_Contsetmessage_Syntax'] = '<сообщение>'
lang['#Command_Contsetname_Description'] = 'Установить название контейнера.'
lang['#Command_Contsetname_Syntax'] = '[название]'
lang['#Command_Contsetpassword_Description'] = 'Установить пароль контейнера.'
lang['#Command_Contsetpassword_Syntax'] = '<пароль>'
lang['#Command_Conttakename_Description'] = 'Убрать название контейнера.'
lang['#Command_Conttakepassword_Description'] = 'Убрать пароль контейнера.'
