--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

local lang = cw.lang:GetTable('ru')

-- Config.
lang['#Garbage_RespawnDelay'] = 'Задержка появления мусора'
lang['#Garbage_RespawnDelayDesc'] = 'Время, через которое точка появления мусора создаёт новый мусор (в секундах).'
lang['#Garbage_PickupTime'] = 'Время уборки мусора'
lang['#Garbage_PickupTimeDesc'] = 'Время, необходимое для уборки одной кучи мусора (в секундах).'
lang['#Garbage_ItemPercentage'] = 'Шанс найти предмет в мусоре'
lang['#Garbage_ItemPercentageDesc'] = 'Шанс того, что игрок найдёт что-нибудь в куче мусора (в процентах).'

-- Attributes.
lang['#Attribute_Scavenger'] = 'Мусорщик'
lang['#Attribute_Scavenger_Desc'] = 'Влияет на шанс найти что-то ценное в мусоре.'

-- Notifications.
lang['#Garbage_Jackpot'] = 'Динь динь динь, джекпот! 10x РПГ!'
lang['#Garbage_FoundRPG'] = 'Вы нашли РПГ. Надо же, что люди в мусор-то кидают.'
lang['#Garbage_Found'] = 'Вы нашли:'
lang['#Garbage_FoundNothing'] = 'Вы ничего не нашли.'
lang['#Garbage_MustCrouch'] = 'Вы должны присесть, чтобы начать сбор мусора.'
lang['#Garbage_ProgressHarvesting'] = 'Вы собираете урожай...'
lang['#Garbage_RemovedSpawn'] = 'Вы удалили #1 точку появления мусора.'
lang['#Garbage_RemovedSpawns'] = 'Вы удалили точки появления мусора (#1 шт.).'
lang['#Garbage_NoSpawnsNear'] = 'Рядом с этой позицией нет точек появления мусора.'
lang['#Garbage_AddedPoint'] = 'Вы добавили точку появления мусора.'

-- Commands.
lang['#Command_Garbageremove_Description'] = 'Удалить точку появления мусора, на которую Вы смотрите.'
lang['#Command_Garbageadd_Description'] = 'Создать мусор в месте, на которое Вы смотрите.'
