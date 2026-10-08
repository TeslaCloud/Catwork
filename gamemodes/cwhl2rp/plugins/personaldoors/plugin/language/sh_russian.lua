--- Russian language strings of the Personal Doors plugin: the door access notifications and the help text of
-- `/DoorSetAccess` and `/DoorUnsetAccess`.

local lang = cw.lang:GetTable('ru')

-- Notifications.
lang['#PersonalDoors_AccessGranted'] = "Вы выдали игроку '#1' доступ к этой двери."
lang['#PersonalDoors_AlreadyHasAccess'] = 'У этого игрока уже есть доступ к этой двери!'
lang['#PersonalDoors_AccessRemoved'] = "Вы забрали у игрока '#1' доступ к этой двери!"
lang['#PersonalDoors_AccessRemovedAll'] = 'Вы забрали у всех игроков доступ к этой двери!'
lang['#PersonalDoors_NotValidDoor'] = 'Это не является дверью!'

-- Commands.
lang['#Command_Doorsetaccess_Description'] = 'Выдать игроку доступ к двери.'
lang['#Command_Doorsetaccess_Syntax'] = '<имя> [bool заперта изначально]'
lang['#Command_Doorunsetaccess_Description'] = 'Забрать у игрока доступ к двери.'
lang['#Command_Doorunsetaccess_Syntax'] = '[имя]'
