--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

local lang = cw.lang:GetTable('ru')

-- HUD
lang['#CTO_HUD_Lost'] = 'Потерян #1с'
lang['#CTO_HUD_Received'] = 'Получен #1с'
lang['#CTO_HUD_Removal'] = 'Удаление #1с'
lang['#CTO_HUD_Unconscious'] = 'Без сознания'
lang['#CTO_HUD_Request'] = 'Запрос помощи'
lang['#CTO_HUD_InView'] = '#1 в поле видимости'
lang['#CTO_HUD_ViolationsInView'] = 'Нарушения в поле видимости'
lang['#CTO_HUD_PossibleViolation'] = 'Возможное нарушение'
lang['#CTO_HUD_Violation_Running'] = 'Бег'
lang['#CTO_HUD_Violation_Jumping'] = 'Прыжок'
lang['#CTO_HUD_Violation_Crouching'] = 'Нахождение сидя'
lang['#CTO_HUD_Violation_FallenOver'] = 'Нахождение лёжа'
lang['#CTO_HUD_Disabled'] = 'Отключено'
lang['#CTO_HUD_SocioStatus'] = 'Социальный статус: #1'

-- Commands
lang['#Command_Cameradisable_Description'] = 'Дистанционно отключить камеру Альянса - идентификаторы показаны на HUD.'
lang['#Command_Cameradisable_Syntax'] = '<ID камеры>'
lang['#Command_Cameraenable_Description'] = 'Дистанционно включить камеру Альянса - идентификаторы показаны на HUD.'
lang['#Command_Cameraenable_Syntax'] = '<ID камеры>'
lang['#Command_Charsetbiosignalstatus_Description'] = 'Включить или отключить биосигнал персонажа.'
lang['#Command_Charsetbiosignalstatus_Syntax'] = '<имя> <включен: true/false>'
lang['#Command_Setbiosignalstatus_Description'] = 'Включить или отключить свой биосигнал. Все остальные юниты будут оповещены.'
lang['#Command_Setbiosignalstatus_Syntax'] = '<включен: true/false>'
lang['#Command_Setsociostatus_Description'] = 'Обновить социальный статус города.'
lang['#Command_Setsociostatus_Syntax'] = '<green|blue|yellow|red|black>'

lang['#CTO_NotCombine'] = 'Вы не являетесь сотрудником Альянса!'
lang['#CTO_RankTooLow'] = 'Ваш ранг слишком мал, чтобы использовать эту команду.'
lang['#CTO_NoCamera'] = 'Камеры Альянса с таким идентификатором не существует!'
lang['#CTO_CameraNotEnabled'] = 'Эта камера сейчас не включена.'
lang['#CTO_CameraNotDisabled'] = 'Эта камера сейчас не отключена.'
lang['#CTO_DisablingCamera'] = 'Отключение C-i#1.'
lang['#CTO_EnablingCamera'] = 'Включение C-i#1.'
lang['#CTO_CharNotCombine'] = 'Этот персонаж не является сотрудником Альянса!'
lang['#CTO_CharBiosignalAlreadyOn'] = 'Биосигнал этого персонажа уже включен!'
lang['#CTO_CharBiosignalAlreadyOff'] = 'Биосигнал этого персонажа уже отключен!'
lang['#CTO_BiosignalAlreadyOn'] = 'Ваш биосигнал уже включен!'
lang['#CTO_BiosignalAlreadyOff'] = 'Ваш биосигнал уже отключен!'
lang['#CTO_InvalidSocioStatus'] = 'Такого социального статуса не существует!'

-- Combine display lines
lang['#CTO_Display_DownloadingLostBiosignal'] = 'Загрузка потерянного биосигнала...'
lang['#CTO_Display_ConnectionRestored'] = 'Соединение восстановлено...'
lang['#CTO_Display_DownloadingFoundBiosignal'] = 'Загрузка обнаруженного биосигнала...'
lang['#CTO_Display_BiosignalFound'] = 'ТРЕВОГА! Обнаружен некомбинированный биосигнал юнита #1. Локация: #2...'
lang['#CTO_Display_ShuttingDown'] = 'ОШИБКА! Отключение...'
lang['#CTO_Display_DownloadingTrauma'] = 'Загрузка данных о травме...'
lang['#CTO_Display_UnitUnconscious'] = 'ВНИМАНИЕ! Юнит #1 потерял сознание. Локация: #2...'
lang['#CTO_Display_SocioStatusUpdated'] = 'ТРЕВОГА! Социальный статус обновлён до #1!'
