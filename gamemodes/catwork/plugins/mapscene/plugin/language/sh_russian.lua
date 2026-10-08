--- Russian (`ru`) language strings of the Map Scenes plugin, covering its notifications and the help text of
-- `/MapSceneAdd` and `/MapSceneRemove`.

local lang = cw.lang:GetTable('ru')

lang['#MapScene_Added'] = 'Вы добавили сцену карты.'
lang['#MapScene_RemovedOne'] = 'Вы удалили #1 сцену карты.'
lang['#MapScene_RemovedMany'] = 'Вы удалили сцены карты (#1 шт.).'
lang['#MapScene_NoneNear'] = 'Рядом с этим местом нет сцен карты.'
lang['#MapScene_None'] = 'Сцен карты нет.'

-- Commands
lang['#Command_Mapsceneadd_Description'] = 'Добавить сцену карты в вашей текущей позиции.'
lang['#Command_Mapsceneadd_Syntax'] = '<bool вращение>'
lang['#Command_Mapsceneremove_Description'] = 'Удалить сцены карты в вашей текущей позиции.'
