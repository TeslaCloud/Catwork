--- Russian language strings of the Gathering plugin: the `nodes_respawn_delay` config key, notifications and the
-- descriptions of `/WoodAdd` and `/WoodRemove`.

local lang = cw.lang:GetTable('ru')

-- Config.
lang['#Gathering_NodesRespawnDelay'] = 'Задержка появления ресурсов'
lang['#Gathering_NodesRespawnDelayDesc'] = 'Время, через которое точка появления ресурсов создаёт новый ресурс (в секундах).'

-- Notifications.
lang['#Gathering_RemovedPoint'] = 'Вы удалили #1 точку появления мебели.'
lang['#Gathering_RemovedPoints'] = 'Вы удалили #1 точек появления мебели.'
lang['#Gathering_NoPointsFound'] = 'Точки появления не найдены.'
lang['#Gathering_AddedWoodPoint'] = 'Вы добавили точку появления деревянной мебели.'
lang['#Gathering_MustCrouch'] = 'Вы должны присесть, чтобы начать сбор мусора.'

-- Commands.
lang['#Command_Woodadd_Description'] = 'Установить точку появления деревянной мебели для добычи.'
lang['#Command_Woodremove_Description'] = 'Удалить точку появления деревянной мебели.'
