--- English (`en`) language strings of the Dynamic Adverts plugin, covering its notifications and the help text of
-- `/AdvertAdd` and `/AdvertRemove`.

local lang = cw.lang:GetTable('en')

lang['#DynamicAdverts_Added'] = 'You have added a dynamic advert.'
lang['#DynamicAdverts_RemovedOne'] = 'You have removed #1 dynamic advert.'
lang['#DynamicAdverts_RemovedMany'] = 'You have removed #1 dynamic adverts.'
lang['#DynamicAdverts_NoneNear'] = 'There were no dynamic adverts near this position.'
lang['#DynamicAdverts_InvalidURL'] = 'The URL must point to a png or jpg image.'

-- Commands
lang['#Command_Advertadd_Description'] = 'Add a dynamic advert.'
lang['#Command_Advertadd_Syntax'] = '<string URL> <number Width> <number Height> [number Scale]'
lang['#Command_Advertremove_Description'] = 'Remove a dynamic advert.'
