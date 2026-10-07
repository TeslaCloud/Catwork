--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

local lang = cw.lang:GetTable('ru')

-- Config.
lang['#Hunger_Tick'] = 'Интервал голода'
lang['#Hunger_TickDesc'] = 'Как быстро убывает шкала голода (чем выше, тем медленнее).'
lang['#Hunger_DefaultRefill'] = 'Восполнение голода по умолчанию'
lang['#Hunger_DefaultRefillDesc'] = 'Количество голода, восполняемое по умолчанию, когда игрок ест пищу (в процентах).'
lang['#Hunger_ThirstTick'] = 'Интервал жажды'
lang['#Hunger_ThirstTickDesc'] = 'Как быстро жажда перекрывает шкалу голода (чем выше, тем медленнее).'
lang['#Hunger_ThirstDrainScale'] = 'Множитель расхода жажды'
lang['#Hunger_ThirstDrainScaleDesc'] = 'Как быстро убывает жажда, когда игрок бегает или прыгает (в процентах).'

-- Notifications.
lang['#Hunger_HungerSetBy'] = '#1 установил Ваш уровень голода на #2.'
lang['#Hunger_HungerSet'] = 'Вы установили уровень голода игрока #1 на #2.'
lang['#Hunger_HungerSetOwn'] = 'Вы установили свой уровень голода на #1.'
lang['#Hunger_ThirstSetBy'] = '#1 установил Ваш уровень жажды на #2.'
lang['#Hunger_ThirstSet'] = 'Вы установили уровень жажды игрока #1 на #2.'
lang['#Hunger_ThirstSetOwn'] = 'Вы установили свой уровень жажды на #1.'
lang['#Hunger_SleepSetBy'] = '#1 установил Ваш уровень сна на #2.'
lang['#Hunger_SleepSet'] = 'Вы установили уровень сна игрока #1 на #2.'
lang['#Hunger_SleepSetOwn'] = 'Вы установили свой уровень сна на #1.'
lang['#Hunger_NeedsSetBy'] = '#1 полностью восполнил Ваши потребности.'
lang['#Hunger_NeedsSet'] = 'Вы полностью восполнили потребности игрока #1.'
lang['#Hunger_NeedsSetOwn'] = 'Вы полностью восполнили свои потребности.'
lang['#Hunger_PlayerIsCombine'] = 'Этот игрок является сотрудником Альянса!'
lang['#Hunger_TooAwakeToSleep'] = 'Вы слишком бодры, чтобы спать!'

-- Commands.
lang['#Command_Charsethunger_Description'] = 'Установить уровень голода игрока.'
lang['#Command_Charsethunger_Syntax'] = '<имя> <количество>'
lang['#Command_Charsetthirst_Description'] = 'Установить уровень жажды игрока.'
lang['#Command_Charsetthirst_Syntax'] = '<имя> <количество>'
lang['#Command_Charsetfatigue_Description'] = 'Установить уровень сна игрока.'
lang['#Command_Charsetfatigue_Syntax'] = '<имя> <количество>'
lang['#Command_Charresetneeds_Description'] = 'Установить уровень потребностей игрока на 100.'
lang['#Command_Charresetneeds_Syntax'] = '<имя>'
lang['#Command_Sleep_Description'] = 'Спокойной ночи.'
