--- Russian (`ru`) language strings of the Salesmen plugin, covering the salesman editor, the default responses, the
-- trade menu, notifications and the help text of the `/Salesman` commands.

local lang = cw.lang:GetTable('ru')

-- Salesman setup
lang['#Salesman_Name'] = 'Имя'
lang['#Salesman_NameRequest'] = 'Каким будет имя торговца?'
lang['#Salesman_NameEditRequest'] = 'Вы хотите изменить имя торговца?'
lang['#Salesman_ShowChatBubble'] = 'Отображать символ чата над головой.'
lang['#Salesman_BuyInShipments'] = 'Покупать / продавать предметы оптом (5 шт.).'
lang['#Salesman_PriceScale'] = 'Множитель цен.'
lang['#Salesman_Flags'] = "Флаги для доступа (введите '-' перед флагами, чтобы проверялись ТОЛЬКО они)."
lang['#Salesman_PhysDesc'] = 'Описание торговца.'
lang['#Salesman_BuyRate'] = 'Множитель продажи'
lang['#Salesman_BuyRateTip'] = 'На какое число будут умножаться цены при продаже.'
lang['#Salesman_Stock'] = 'Кол-во предметов по умолчанию'
lang['#Salesman_StockTip'] = 'Количество предметов в запасе (-1 - бесконечно).'
lang['#Salesman_Model'] = 'Модель торговца.'
lang['#Salesman_Cash'] = 'Стартовый капитал'
lang['#Salesman_CashTip'] = 'Количество денег торговца (-1 - бесконечно).'
lang['#Salesman_Factions'] = 'Фракции'
lang['#Salesman_FactionsHelp'] = 'Оставьте пустым, чтобы позволить всем фракциям торговать с этим торговцем.'
lang['#Salesman_ClassesHelp'] = 'Оставьте пустым, чтобы позволить всем классам торговать с этим торговцем.'
lang['#Salesman_ItemsTip'] = 'Предметы для торговли.'
lang['#Salesman_SettingsTip'] = 'Настройки торговца.'
lang['#Salesman_SellPriceRequest'] = 'За сколько этот предмет будет продаваться торговцем?'
lang['#Salesman_BuyPriceRequest'] = 'За сколько этот предмет будет покупаться торговцем?'

-- Salesman responses
lang['#Salesman_Responses'] = 'Ответы'
lang['#Salesman_Response_Start'] = 'При начале торговли.'
lang['#Salesman_Response_NoSale'] = 'Если игрок не может торговать с торговцем.'
lang['#Salesman_Response_NoStock'] = 'Если кончились предметы в запасе.'
lang['#Salesman_Response_NeedMore'] = 'При покупке предмета.'
lang['#Salesman_Response_CannotAfford'] = 'Если торговец не может приобрести предмет.'
lang['#Salesman_Response_DoneBusiness'] = 'При успешном обмене.'
lang['#Salesman_Response_Sound'] = 'Звук.'
lang['#Salesman_Response_HideName'] = 'Спрятать имя торговца.'
lang['#Salesman_Default_Start'] = 'Чем могу помочь?'
lang['#Salesman_Default_NoSale'] = 'Я не могу торговать с тобой!'
lang['#Salesman_Default_NoStock'] = 'Весь товар продан!'
lang['#Salesman_Default_CannotAfford'] = 'Я не могу купить это!'
lang['#Salesman_Default_DoneBusiness'] = 'Приходи еще.'
lang['#Salesman_Prefill_NoStock'] = 'Нет в наличии!'
lang['#Salesman_Prefill_NeedMore'] = 'У тебя не хватает денег!'
lang['#Salesman_Prefill_CannotAfford'] = 'Я не могу себе это позволить!'
lang['#Salesman_Prefill_DoneBusiness'] = 'Спасибо за покупку, увидимся!'

-- Salesman menu
lang['#Salesman_SellsTip'] = 'Предметы, которые #1 продает.'
lang['#Salesman_BuysTip'] = 'Предметы, которые #1 покупает.'
lang['#Salesman_CashInfo'] = 'У #1 в наличии #2.'

-- Notifications
lang['#Salesman_Says'] = 'говорит'
lang['#Salesman_CannotCarry'] = 'Ты это не унесешь.'
lang['#Salesman_YouReceived'] = 'Вы получили #1'
lang['#Salesman_From'] = 'от'
lang['#Salesman_YouSold'] = 'Вы продали 1 х'
lang['#Salesman_To'] = 'торговцу'
lang['#Salesman_NotSalesman'] = 'Этот объект не является торговцем!'
lang['#Salesman_LookAtValidEntity'] = 'Вы должны смотреть на объект!'
lang['#Salesman_Removed'] = 'Вы удалили торговца.'

-- Commands
lang['#Command_Salesmanadd_Description'] = 'Добавить торговца в место, на которое вы смотрите.'
lang['#Command_Salesmanadd_Syntax'] = '[номер анимации]'
lang['#Command_Salesmanedit_Description'] = 'Изменить торговца, на которого вы смотрите.'
lang['#Command_Salesmanedit_Syntax'] = '[номер анимации]'
lang['#Command_Salesmanremove_Description'] = 'Удалить торговца, на которого вы смотрите.'
