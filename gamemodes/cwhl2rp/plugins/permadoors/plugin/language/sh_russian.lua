--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

local lang = cw.lang:GetTable('ru')

lang['#Door_Vacant'] = 'Свободно'

-- Notifications.
lang['#PermaDoors_Assigned'] = 'Эта дверь успешно закреплена за игроком #1.'
lang['#PermaDoors_OwnerRemoved'] = 'Владелец этой двери был удалён.'
lang['#PermaDoors_NotValidDoor'] = 'Это не является дверью!'

-- Commands.
lang['#Command_Doorsetplayer_Description'] = 'Закрепить дверь за определённым игроком.'
lang['#Command_Doorsetplayer_Syntax'] = '<имя> <название двери>'
lang['#Command_Doorresetplayer_Description'] = 'Открепить от двери закреплённого за ней игрока.'
lang['#Command_Doorresetplayer_Syntax'] = '<название двери>'
