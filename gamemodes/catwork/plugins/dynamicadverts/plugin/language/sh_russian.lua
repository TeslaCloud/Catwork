--- Russian (`ru`) language strings of the Dynamic Adverts plugin, covering its notifications and the help text of
-- `/AdvertAdd` and `/AdvertRemove`.

local lang = cw.lang:GetTable('ru')

lang['#DynamicAdverts_Added'] = 'Вы добавили динамическую рекламу.'
lang['#DynamicAdverts_RemovedOne'] = 'Вы удалили #1 динамическую рекламу.'
lang['#DynamicAdverts_RemovedMany'] = 'Вы удалили динамическую рекламу (#1 шт.).'
lang['#DynamicAdverts_NoneNear'] = 'Рядом с этим местом нет динамической рекламы.'

-- Commands
lang['#Command_Advertadd_Description'] = 'Добавить динамическую рекламу.'
lang['#Command_Advertadd_Syntax'] = '<URL> <ширина> <высота> [масштаб]'
lang['#Command_Advertremove_Description'] = 'Удалить динамическую рекламу.'
