--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

local lang = cw.lang:GetTable('ru')

-- Item menu functions (looked up without the leading # by the item menu)
lang['Swallow'] = 'Употребить'
lang['Apply'] = 'Применить'
lang['Give'] = 'Дать'
lang['Inject'] = 'Ввести'
lang['Use on...'] = 'Использовать на...'

-- Commands
lang['#Command_Chargetdisease_Description'] = 'Узнать болезнь игрока.'
lang['#Command_Chargetdisease_Syntax'] = '<имя>'
lang['#Command_Charsetdisease_Description'] = 'Установить болезнь игрока.'
lang['#Command_Charsetdisease_Syntax'] = '<имя> <болезнь>'
lang['#Diseases_SetByOther'] = '#1 установил вам болезнь: #2.'
lang['#Diseases_SetOther'] = 'Вы установили игроку #1 болезнь: #2.'
lang['#Diseases_SetSelf'] = 'Вы установили себе болезнь: #1.'

-- Symptoms
lang['#Diseases_Emote_PneumoniaCough'] = 'очень сильно кашляет, отхаркивая мокроту из легких.'
lang['#Diseases_Emote_Gasp'] = 'начинает задыхаться и жадно глотать воздух.'
lang['#Diseases_Emote_Cough'] = 'кашляет.'
lang['#Diseases_Emote_Fever'] = 'чувствует головокружение и жар.'
lang['#Diseases_Emote_Stomach'] = 'невольно сгибается из-за боли в животе.'
lang['#Diseases_Emote_Vomit'] = 'вырвало.'
lang['#Diseases_PermaKilled'] = 'Вы были перманентно убиты из-за интоксикации...'
lang['#Diseases_AllergyRash'] = 'Вы замечаете сыпь на Ваших руках.'
lang['#Diseases_StomachPain'] = 'Вы чувствуете боль в животе.'
lang['#Diseases_AllergyReaction'] = 'Вам стало плохо после употребления #1.'

-- Item notifications
lang['#Diseases_MustLookAtPerson'] = 'Вы должны смотреть на человека!'
lang['#Diseases_MustLookAtPatient'] = 'Вы должны смотреть на пациента!'
lang['#Diseases_Gave_ActivatedCoal'] = 'Вы дали персонажу активированного угля.'
lang['#Diseases_Gave_AllergyTablet'] = 'Вы дали персонажу таблетки от аллергии.'
lang['#Diseases_Gave_Antibiotics'] = 'Вы дали персонажу антибиотики.'
lang['#Diseases_Gave_CoughSyrup'] = 'Вы дали персонажу сироп от кашля.'
lang['#Diseases_Gave_Paracetamol'] = 'Вы дали персонажу парацетамол.'
lang['#Diseases_Gave_Probiotics'] = 'Вы дали персонажу пробиотики.'
lang['#Diseases_Gave_SleepingPills'] = 'Вы дали персонажу снотворное.'
lang['#Diseases_Gave_Sorbent'] = 'Вы дали персонажу сорбенты.'
lang['#Diseases_Fed'] = 'Вы покормили персонажа.'
lang['#Diseases_Used_Inhaler'] = 'Вы применили ингалятор на персонаже.'
lang['#Diseases_Surgery_Blindness'] = 'Вы использовали комплект для лечения слепоты.'
lang['#Diseases_Surgery_Colorblindness'] = 'Вы использовали комплект для лечения дальтонизма.'
lang['#Diseases_Surgery_Wasted'] = 'Вы просто так использовали комплект для лечения проблем со зрением.'
lang['#Diseases_Eyelight_Blind'] = 'Глаза человека едва реагируют на свет.'
lang['#Diseases_Eyelight_Colorblind'] = 'Глаза гражданина не реагируют на цветной свет.'
lang['#Diseases_Eyelight_Normal'] = 'Глаза человека хорошо реагируют на свет.'
lang['#Diseases_Injected_Self'] = 'Вы ввели зеленую жидкость себе в вену.'
lang['#Diseases_Injected_Other'] = 'Вы ввели зеленую жидкость персонажу.'
lang['#Diseases_Antidote_Self'] = 'Вы ввели в свои вены антидот...'
lang['#Diseases_Antidote_SelfNoEffect'] = 'Вы ввели в свои вены антидот, но лучше Вам не стало...'
lang['#Diseases_Antidote_Other'] = 'Вы ввели антидот человеку.'
lang['#Diseases_Antidote_OtherNoEffect'] = 'Вы ввели антидот персонажу. Не похоже, чтобы ему стало лучше.'
lang['#Diseases_Temperature'] = 'Температура: #1C'

-- Items
lang['#Item_ActivatedCoal_PrintName'] = 'Пачка активированного угля'
lang['#Item_ActivatedCoal_Description'] = "Коробка с надписью 'Активированный уголь'."
lang['#Item_AllergyTablet_PrintName'] = 'Пачка таблеток от аллергии'
lang['#Item_AllergyTablet_Description'] = "Коробочка с надписью 'Димедрол' и припиской 'Таблетки от аллергии'."
lang['#Item_Antibiotics_PrintName'] = 'Пачка антибиотиков'
lang['#Item_Antibiotics_Description'] = "Коробочка с надписью 'Амоксициллин' и припиской 'Антибиотики'."
lang['#Item_BlindnessSurgerykit_PrintName'] = 'Глазной хирургический набор'
lang['#Item_BlindnessSurgerykit_Description'] = 'Набор, в который входит все необходимое для проведения операции на глазу.'
lang['#Item_CoughSyrup_PrintName'] = 'Сироп от кашля'
lang['#Item_CoughSyrup_Description'] = 'Стеклянный пузырек с коричневой субстанцией внутри.'
lang['#Item_Eyelight_PrintName'] = 'Медицинский фонарик'
lang['#Item_Eyelight_Description'] = 'Маленький фонарик для проверки глаз.'
lang['#Item_FastGreenLiquid_PrintName'] = 'Цианид калия'
lang['#Item_FastGreenLiquid_Description'] = 'Ампула с жидкостью.'
lang['#Item_GreenAntidote_PrintName'] = 'Шприц с аломорфином'
lang['#Item_GreenAntidote_Description'] = "Шприц с зеленой жидкостью и надписью 'Антидот'."
lang['#Item_GreenLiquid_PrintName'] = 'Шприц стрихнина'
lang['#Item_GreenLiquid_Description'] = 'Неподписанный шприц с зеленой жидкостью.'
lang['#Item_Ingall_PrintName'] = 'Ингалятор'
lang['#Item_Ingall_Description'] = 'Небольшой приборчик, который нужно вставить в рот.'
lang['#Item_Paracetamol_PrintName'] = 'Парацетамол'
lang['#Item_Paracetamol_Description'] = 'Баночка с несколькими таблетками для лечения простуды.'
lang['#Item_Probiotics_PrintName'] = 'Пачка пробиотиков'
lang['#Item_Probiotics_Description'] = "Коробочка с надписью 'Бификол' и припиской 'Пробиотики'."
lang['#Item_Snot_PrintName'] = 'Снотворное (По рецепту)'
lang['#Item_Snot_Description'] = "Коробочка с надписью 'Мелаксен' и припиской 'Снотворное'."
lang['#Item_Snotbad_PrintName'] = 'Снотворное (Не по рецепту)'
lang['#Item_Snotbad_Description'] = "Коробочка, на которой написано 'Снотворное' обычной шариковой ручкой."
lang['#Item_Sorbent_PrintName'] = 'Пачка сорбентов'
lang['#Item_Sorbent_Description'] = "Коробочка с надписью 'Полифепан' и припиской 'Сорбенты'."
lang['#Item_SpecialRation_PrintName'] = 'Рацион специальной диеты'
lang['#Item_SpecialRation_Description'] = 'Пища, которую прописывают больным гастритом.'
lang['#Item_Thermometer_PrintName'] = 'Градусник'
lang['#Item_Thermometer_Description'] = 'Палочка, указывающая температуру носителя.'
