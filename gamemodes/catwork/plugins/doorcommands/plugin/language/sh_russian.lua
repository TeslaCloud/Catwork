--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local lang = cw.lang:GetTable("ru")

-- Tools
lang["#tool.doortool.name"] = "Инструмент дверей"
lang["#tool.doortool.desc"] = "Выполняет различные действия с дверьми."
lang["#tool.doortool.0"] = "ЛКМ: Выполнить действие | ПКМ: Выполнить действие (если применимо)"
lang["#tool.doortool.mode"] = "Режим инструмента"
lang["#tool.doortool.mode1"] = "Запереть/отпереть дверь"
lang["#tool.doortool.mode1desc"] = "Запирайте и отпирайте двери!"
lang["#tool.doortool.mode2"] = "Сделать дверь доступной для владения"
lang["#tool.doortool.mode3"] = "Сделать дверь недоступной для владения"
lang["#tool.doortool.doorname"] = "Название двери"
lang["#tool.doortool.doordesc"] = "Описание двери"
lang["#tool.doorparent.name"] = "Менеджер родительских дверей"
lang["#tool.doorparent.desc"] = "Управление родительскими дверьми."
lang["#tool.doorparent.0"] = "ЛКМ: Назначить родительскую/дочернюю дверь | R: Сбросить активную родительскую дверь | ПКМ: Отвязать дверь от родительской"
lang["#tool.doorparent.header"] = "Привязка дверей"
lang["#tool.doorparent.helpTitle"] = "Справка"
lang["#tool.doorparent.help"] = "Привязка дверей позволяет назначить родительскую дверь: когда игрок приобретает её, он получает доступ и к её 'дочерним' дверям. Благодаря этому не нужно делать доступной для владения каждую дверь.\n\nКак пользоваться привязкой дверей:\n\n1. Сначала выберите родительскую дверь левой кнопкой мыши. Обычно это 'входная' дверь.\n\n2. Затем нажмите левой кнопкой мыши на все двери внутри помещения.\n\n3. Теперь можно сделать входную дверь доступной для владения. Остальные двери можно сделать недоступными для владения, чтобы задать им текст.\n\n*Не забудьте сбросить родительскую дверь, когда закончите."

-- Config
lang["#DoorsDefaultHidden"] = "Двери скрыты по умолчанию"
lang["#DoorsDefaultHiddenDesc"] = "Скрыты ли двери и недоступны ли они для владения по умолчанию."
lang["#DoorsSaveState"] = "Сохранять состояние дверей"
lang["#DoorsSaveStateDesc"] = "Сохранять ли состояние дверей: открыты они, закрыты или заперты."

-- Notifications
lang["#DoorCmds_NotValidDoor"] = "Это не дверь!"
lang["#DoorCmds_ChildAdded"] = "Вы добавили эту дверь как дочернюю к активной родительской двери."
lang["#DoorCmds_CannotParentToItself"] = "Нельзя привязать активную родительскую дверь к самой себе!"
lang["#DoorCmds_AlreadyChild"] = "Эта дверь уже является дочерней для активной родительской двери!"
lang["#DoorCmds_NoValidParent"] = "Вы не выбрали родительскую дверь!"
lang["#DoorCmds_Locked"] = "Вы заперли эту дверь."
lang["#DoorCmds_Unlocked"] = "Вы отперли эту дверь."
lang["#DoorCmds_MadeFalse"] = "Вы сделали эту дверь фальшивой."
lang["#DoorCmds_MadeNotFalse"] = "Эта дверь больше не фальшивая."
lang["#DoorCmds_AllSetUnownable"] = "Дверей сделано недоступными для владения: #1."
lang["#DoorCmds_AllSetOwnable"] = "Дверей сделано доступными для владения: #1."
lang["#DoorCmds_AllDoorsReminder"] = "Помните: это ВСЕ двери!"
lang["#DoorCmds_ParentSet"] = "Вы сделали эту дверь активной родительской. Родительская дверь подсвечена оранжевым, а её дочерние двери - синим."
lang["#DoorCmds_ParentCleared"] = "Вы сбросили активную родительскую дверь."
lang["#DoorCmds_NoActiveParent"] = "У вас нет активной родительской двери."
lang["#DoorCmds_SetOwnable"] = "Вы сделали дверь доступной для владения."
lang["#DoorCmds_SetUnownable"] = "Вы сделали дверь недоступной для владения."
lang["#DoorCmds_Unparented"] = "Вы отвязали эту дверь от родительской."
lang["#DoorCmds_Hidden"] = "Вы скрыли эту дверь."
lang["#DoorCmds_Unhidden"] = "Вы сделали эту дверь видимой."

-- Commands
lang["#Command_Doorlock_Description"] = "Запереть дверь."
lang["#Command_Doorresetparent_Description"] = "Сбросить активную родительскую дверь игрока."
lang["#Command_Doorsetallownable_Description"] = "Сделать все двери доступными для владения."
lang["#Command_Doorsetallownable_Syntax"] = "<название>"
lang["#Command_Doorsetallunownable_Description"] = "Сделать все двери недоступными для владения."
lang["#Command_Doorsetallunownable_Syntax"] = "<название>"
lang["#Command_Doorsetchild_Description"] = "Добавить дочернюю дверь к активной родительской двери."
lang["#Command_Doorsetfalse_Description"] = "Установить, является ли дверь фальшивой."
lang["#Command_Doorsetfalse_Syntax"] = "<bool фальшивая>"
lang["#Command_Doorsethidden_Description"] = "Установить, является ли дверь скрытой."
lang["#Command_Doorsethidden_Syntax"] = "<bool скрытая>"
lang["#Command_Doorsetownable_Description"] = "Сделать дверь доступной для владения."
lang["#Command_Doorsetownable_Syntax"] = "<название>"
lang["#Command_Doorsetparent_Description"] = "Сделать дверь, на которую вы смотрите, активной родительской дверью."
lang["#Command_Doorsetunownable_Description"] = "Сделать дверь недоступной для владения."
lang["#Command_Doorsetunownable_Syntax"] = "<название> [текст]"
lang["#Command_Doorunlock_Description"] = "Отпереть дверь."
lang["#Command_Doorunparent_Description"] = "Отвязать дверь, на которую вы смотрите, от родительской."
