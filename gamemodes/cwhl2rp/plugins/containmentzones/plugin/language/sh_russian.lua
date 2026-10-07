--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

local lang = cw.lang:GetTable('ru')

-- Commands
lang['#Command_Containmentboxplace_Syntax'] = '<рад/сек>'
lang['#Command_Containmentremove_Syntax'] = '[радиус поиска]'
lang['#Command_Containmentsphereplace_Syntax'] = '<радиус> <рад/сек>'
lang['#Containment_NoStartPoint'] = 'Начальная точка не найдена.'
lang['#Containment_StartPointSet'] = 'Вы установили начальную точку. Теперь установите конечную.'
lang['#Containment_EndPointSet'] = 'Вы установили конечную точку.'
lang['#Containment_NoStartPos'] = 'Начальная точка не указана.'
lang['#Containment_NoEndPos'] = 'Конечная точка не указана.'
lang['#Containment_NoPos'] = 'Точки не указаны.'
lang['#Containment_BoxAdded'] = 'Вы добавили зону заражения с указанными параметрами: рад: #1.'
lang['#Containment_SphereAdded'] = 'Вы добавили зону заражения с указанными параметрами: радиус: #1, рад: #2.'
lang['#Containment_Removed'] = 'Удалено зон заражения: #1.'
lang['#Containment_NoneFound'] = 'Рядом с этой точкой нет зон заражения.'
lang['#Containment_Saved'] = 'Вы сохранили зоны заражения.'

-- Radiation
lang['#Containment_RadPerSecond'] = 'рад/с'
lang['#Containment_RadSickness_Stage1'] = 'Вас сильно тошнит. После того, как Вас вырвало, Вы чувствуете легкую усталость.'
lang['#Containment_RadSickness_Stage2'] = 'Вы чувствуете сильную усталость, рвота не прекращается, и время вашего выздоровления увеличивается.'
lang['#Containment_RadSickness_Stage3'] = 'У Вас очень сильное кровотечение. Вам ужасно плохо, и у Вас выпадают волосы.'
lang['#Containment_RadSickness_Stage4'] = 'У Вас сильное и продолжительное кровотечение. Вас рвет кровью.'
lang['#Containment_RadSickness_Stage5'] = 'У Вас внутреннее кровотечение. Кроме того, у Вас вздутие живота и жуткая агония.'

-- Items
lang['#Containment_UseText_ReplaceFilter'] = 'Сменить фильтр'
lang['#Containment_UseText_Read'] = 'Прочитать'
lang['#Containment_UseText_Check'] = 'Проверить'
lang['#Item_Filter_PrintName'] = 'Фильтр'
lang['#Item_Filter_Description'] = 'Фильтр для противогазов типа GP-5 и GCP-1.'
lang['#Item_Filter_Condition'] = 'Состояние фильтра: #1%'
lang['#Item_GeigerCounter_PrintName'] = 'Дозиметр'
lang['#Item_GeigerCounter_Description'] = 'Старый на вид прибор для измерения радиационного фона.'
lang['#Item_PdbBook_PrintName'] = 'Руководство по использованию ПДБ'
lang['#Item_PdbBook_Description'] = 'Довольно потрёпанного вида книга красного цвета.'
lang['#Item_RadChecker_PrintName'] = 'ПДБ-6'
lang['#Item_RadChecker_Description'] = 'Прибор для определения дозы радиации организма.'
lang['#Containment_Book_Learned'] = 'Прочитав книгу, вы повысили свои навыки в медицине.'
lang['#Containment_Book_AlreadyKnown'] = 'Вы уже знакомы с содержимым этой книги.'
lang['#Containment_RadDose'] = 'Доза радиации объекта:'
lang['#Containment_RadDose_Unknown'] = 'неизвестно.'
lang['#Containment_RadDose_Value'] = '#1 рад.'
lang['#Containment_RadChecker_NoSkill'] = 'Ваших медицинских навыков недостаточно, чтобы использовать этот прибор.'
