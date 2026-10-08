--- Russian language strings for the Area Displays plugin.

local lang = cw.lang:GetTable('ru')

lang['#AreaDisplays_MinimumAdded'] = 'Вы добавили минимальную точку. Теперь добавьте максимальную точку.'
lang['#AreaDisplays_MaximumAdded'] = 'Вы добавили максимальную точку. Теперь укажите место, где будет отображаться текст.'
lang['#AreaDisplays_Added'] = 'Вы добавили отображение территории'
lang['#AreaDisplays_RemovedOne'] = 'Вы удалили #1 отображение территории.'
lang['#AreaDisplays_RemovedMany'] = 'Вы удалили отображения территорий (#1 шт.).'
lang['#AreaDisplays_NoneFound'] = 'Отображений территорий с таким названием не найдено.'

-- Commands
lang['#Command_Areaadd_Description'] = 'Добавить территорию. Классы: 3D, Scrolling или Cinematic. Используйте %t в названии, чтобы показать время.'
lang['#Command_Areaadd_Syntax'] = '<название> [масштаб] [bool исчезает] [класс]'
lang['#Command_Arearemove_Description'] = 'Удалить территорию, смотря рядом с ней.'
lang['#Command_Arearemove_Syntax'] = '<название>'
