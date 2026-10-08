--- Russian (`ru`) phrases of the Catwork framework, added to the table returned by `cw.lang:GetTable`.

local lang = cw.lang:GetTable('ru')

lang.name = 'Русский язык'

-- Genders
lang['#Gender_Female'] = 'Женщина'
lang['#Gender_Male'] = 'Мужчина'

-- Limbs
lang['Chest'] = 'Торс'
lang['Right Arm'] = 'Правая рука'
lang['Left Arm'] = 'Левая рука'
lang['Stomach'] = 'Живот'
lang['Left Leg'] = 'Левая нога'
lang['Right Leg'] = 'Правая нога'
lang['Head'] = 'Голова'

lang['#DeathScreen_YouDied'] = 'ВЫ МЕРТВЫ'
lang['#DeathScreen_SpawnPercentage'] = 'ВОЗРОЖДЕНИЕ: #1'

lang['#Err_CantUse_Tied'] = 'Вы не можете сделать это, пока связаны!'

-- Random
lang['#HookErrors'] = 'Обнаружены ошибки клиентской части сервера.'
lang['#PlayerDisconnected'] = ' отключился от сервера.'
lang['#PlayerConnected'] = ' подключился к серверу.'
lang['#CantTakeOthersCharactersItems'] = 'Вы не можете поднимать предметы другого Вашего персонажа.'
lang['#CantDeleteCharacterWithLowMoney'] = 'Вы не можете удалить персонажа, кол-во валюты которого менее чем #1.'
lang['#CantSwitchWhenDead'] = 'Вы не можете сменить персонажа, будучи мертвым.'
lang['#CantSwitchWhenUnc'] = 'Вы не можете сменить персонажа, будучи без сознания.'
lang['#CharIsBanned'] = ' заблокирован и не может быть использован.'
lang['#TooManyCharFaction'] = 'Слишком много персонажей данной фракции в сети.'
lang['#TooManyCharClass'] = 'Слишком много персонажей данного класса в сети.'
lang['#PropRefund'] = 'Удаление объекта'
lang['#GiveInvalidItem'] = 'ОШИБКА: Попытка выдачи недействительного предмета.'
lang['#NoSpace'] = 'Вам не хватает места в инвентаре.'
lang['#InvalidFaction'] = 'Фракция недействительна.'
lang['#InvalidClass'] = 'Класс недействителен.'
lang['#TooManyAtts'] = 'Вы распределили слишком много очков атрибутов.'
lang['#AttribError'] = 'Вы повысили недействительный атрибут.'
lang['#TooManyTraits'] = 'Сумма очков особенностей должна быть больше или равна 0.'
lang['You did not specify enough text!'] = 'Вы указали слишком короткое сообщение!'

-- Commands
lang['#RequestFrom'] = 'Запрос от #1: #2'
lang['#UseA'] = 'Вы администратор. Используйте /a.'

-- Salesman
lang['Buys'] = 'Продажа'
lang['Sells'] = 'Покупка'
lang['Items'] = 'Предметы'
lang['Settings'] = 'Настройки'
lang['Both'] = 'Покупка и продажа'
lang['Free'] = 'Бесплатно'

-- Storages
lang['Weight'] = 'Вес'
lang['#ShipmentWithRations'] = 'Ящик с рационами'

-- Character menu
lang['Use this character.'] = 'Использовать данного персонажа.'
lang['Delete this character.'] = 'Удалить данного персонажа.'
lang['Yes'] = 'Да'
lang['No'] = 'Нет'
lang['Delete'] = 'Удалить'
lang['Use'] = 'Использовать'
lang['Details'] = 'Описание'
lang['This character has no details to display.'] = 'У этого персонажа нет описания.'

-- Items functions
lang['Equip'] = 'Экипировать'
lang['Holster'] = 'Убрать'
lang['Drop'] = 'Выбросить'
lang['Drink'] = 'Выпить'
lang['Open'] = 'Открыть'
lang['Eat'] = 'Съесть'
lang['Load'] = 'Зарядить'
lang['Ammo'] = 'Разрядить'
lang['#AmmoTip'] = 'Изъять патроны из оружия.'
lang['Wear'] = 'Надеть'

lang['Primary: '] = 'Основное: '
lang['Secondary: '] = 'Дополнительное: '
lang['Clip One: '] = 'Осн. боезапас: '
lang['Clip Two: '] = 'Доп. боезапас: '
lang['Rounds'] = 'Боезапас'

lang['#IsWearing_Yes'] = 'Надето'
lang['#IsWearing_No'] = 'Не надето'

-- Notifies: Items
lang['#WeaponUsesAmmo'] = 'Вы должны экипировать оружие, использующее данный тип боеприпаса.'
lang['#CantDropFar'] = 'Вы не можете выбросить этот предмет так далеко.'
lang['#CantDropWhenWearing'] = 'Вы не можете выбросить предмет, который надет на Вас.'
lang['#CantDoThisNow'] = 'Вы не можете выполнить это действие сейчас.'
lang['#FactionCantWear'] = 'Представители Вашей фракции не могут носить этот предмет.'

lang['Other'] = 'Разное'

-- Items context menu
lang['#ItemContextMenu_Information'] = 'Информация'
lang['#ItemContextMenu_Category'] = 'Категория'
lang['#ItemContextMenu_Price'] = 'Цена'

-- Config Print
lang['#ConfigVariablesPrinted'] = 'Значения конфигурации были выведены в консоль.'

-- Various Error Messages
lang['#CannotPurchaseAnotherDoor'] = 'Вы не можете приобрести еще одну дверь!'
lang['#EntityOptionWaitTime'] = 'Вы не можете использовать это настолько быстро!'
lang['#YouNeedAnother'] = 'Вам необходимо еще #1!'
lang['#NotEnoughText'] = 'Вы не ввели достаточное количество текста!'
lang['#NotValidMap'] = 'На сервере нет карты #1!'
lang['#CannotChangeClassFor'] = 'Вы не можете сменить класс еще #1 секунд!'
lang['#CannotActionRightNow'] = 'Вы не можете сделать это сейчас!'
lang['#DroppedItemsOtherChar'] = 'Нельзя подбирать предметы, принадлежащие другому вашему персонажу!'
lang['#DroppedCashOtherChar'] = 'Нельзя подобрать #1, принадлежащий другому вашему персонажу!'
lang['#NotValidCharacter'] = "Персонажа '#1' не существует!"
lang['#NotValidPlayer'] = "Игрока '#1' не существует!"
lang['#NotValidAmount'] = 'Введенное вами количество не подходит!'

-- Roll Message
lang['#HasRolled'] = '#1 выпало #2 из #3.'
lang['#LogHasRolled'] = '#1 выпало #2 из #3!'

-- Cash Set Messages
lang ['#CashSetTarget'] = '#3 установил ваши #1 на #2.'
lang ['#CashSetPlayer'] = 'Вы установили #2 #1 на #3.'

-- Storage Error Messages
lang['#StorageNoInstance'] = 'Данного предмета нет в этом хранилище!'
lang['#StorageNotOpen'] = 'У вас нет открытого хранилища!'
lang['#StorageCannotGive'] = 'Вы не можете хранить предметы здесь!'
lang['#StoragePlayerNoInstance'] = 'У вас нет данного предмета!'

-- Class Error Messages
lang['#ClassNoAccess'] = 'Игрок не имеет доступа к этому классу!'
lang['#ClassTooMany'] = 'Слишком много персонажей с этим классом!'
lang['#ClassNotValid'] = 'Такого класса не существует!'
lang['#ClassSetTarget'] = '#2 изменил Ваш класс на #1.'
lang['#ClassSetPlayer'] = 'Вы изменили класс #2 на #1.'

-- Voicemail Notifies
lang['#VoicemailRemoved'] = 'Вы удалили свою голосовую почту.'
lang['#VoicemailSet'] = "Вы установили свою голосовую почту на '#1'."

-- Weapon Error Messages
lang['#CannotHolsterWeapon'] = 'Вы не можете опустить это оружие!'
lang['#CannotDropWeapon'] = 'Вы не можете выкинуть это оружие!'
lang['#CannotUseWeapon'] = 'Вы не можете использовать это оружие!'

-- Config Error Messages
lang['#ConfigUnableToSet'] = "Невозможно установить значение конфигурации '#1'!"
lang['#ConfigIsStaticKey'] = '#1 является статическим значением конфигурации!'
lang['#ConfigKeyNotValid'] = "Значение конфигурации '#1' не существует!"

-- Settings Categories
lang['#Framework'] = 'Игровой режим'
lang['#ChatBox'] = 'Чат'
lang['#Theme'] = 'Оформление'
lang['#AdminESP'] = 'ESP Администратора'

-- Settings Info Text
lang['#SettingsInfoText'] = "Данные настройки позволяют вам персонализировать внешний вид Clockwork'а."
lang['#NoSettingsInfoText'] = 'К сожалению, у вас нету доступа к каким-либо настройкам!'

-- Settings Descriptions
lang['#ThemeDesc'] = 'Выбранное оформление для интерфейса пользователя.'
lang['#EnableAdminESPDesc'] = 'Включить/выключить радар (ESP).'
lang['#DrawESPBarsDesc'] = 'Отрисовывать полоски прогресса для некоторых значений.'
lang['#ShowSpawnPointsDesc'] = 'Показывать точки спавна на радаре (ESP).'
lang['#ShowItemEntitiesDesc'] = 'Показывать предметы на радаре.'
lang['#ShowSalesmenEntitiesDesc'] = 'Показывать NPC продавцов на радаре.'
lang['#ShowAreasDesc'] = 'Показывать названия территорий, в которые вы входите.'
lang['#ESPIntervalDesc'] = 'Интервал между обновлениями радара.'
lang['#TwelveHourClockDesc'] = 'Показывать время в 12-часовом формате.'
lang['#ShowBarsDesc'] = 'Показывать полоски в верхнем углу экрана.'
lang['#EnableHintsDesc'] = 'Показывать подсказки.'
lang['#LangDesc'] = 'Выбранный язык.'
lang['#EnableVignetteDesc'] = 'Отрисовывать виньетку по краям экрана.'
lang['#ShowTimestampsDesc'] = 'Показывать время возле сообщений в чате.'
lang['#ShowCWMessagesDesc'] = 'Показывать сообщения игрового режима.'
lang['#ShowServerMessagesDesc'] = 'Показывать сообщения сервера.'
lang['#ShowOOCMessagesDesc'] = 'Показывать глобальные (OOC) сообщения.'
lang['#ShowICMessagesDesc'] = 'Показывать сообщения персонажей (IC чат).'
lang['#HeadbobAmountDesc'] = 'Множитель качки (пошатывания) головы.'
lang['#ChatLinesDesc'] = 'Количество строк чата, которые можно увидеть за раз.'
lang['#EnableConsoleLogDesc'] = 'Показывать логи администратора.'
lang['#TextColorDesc'] = 'Цвет, используемый по большей части для текстов оформления.'
lang['#BGColorDesc'] = 'Цвет фона.'
lang['#TabMenuXDesc'] = 'Позиция TAB-меню по оси X.'
lang['#TabMenuYDesc'] = 'Позиция TAB-меню по оси Y.'
lang['#BackMenuXDesc'] = 'Позиция фона по оси X.'
lang['#BackMenuYDesc'] = 'Позиция фона по оси Y.'
lang['#BackMenuWDesc'] = 'Ширина фона.'
lang['#BackMenuHDesc'] = 'Высота фона.'
lang['#FadePanelsDesc'] = 'Использовать переливание панелей из одной в другую при смене вкладок TAB-меню.'
lang['#ShowMaterialDesc'] = 'Отрисовывать материал на фоне меню.'
lang['#ShowGradientDesc'] = 'Отрисовывать градиент (блюр) на фоне меню.'
lang['#MenuMaterialDesc'] = 'Материал, используемый как фон для TAB-меню.'

-- Settings Names
lang['#EnableAdminESP'] = 'Включить Админ ESP.'
lang['#DrawESPBars'] = 'Показывать полоски.'
lang['#ShowSpawnPoints'] = 'Показывать точки возрождения.'
lang['#ShowStaticEnts'] = 'Показывать статичные объекты.'
lang['#ShowItemEntities'] = 'Показывать предметы.'
lang['#ShowAreas'] = 'Включить отображение территорий.'
lang['#ShowSalesmenEntities'] = 'Показывать продавцов.'
lang['#ESPInterval'] = 'Интервал обновления радара:'
lang['#TwelveHourClock'] = 'Включить 12-часовой формат времени.'
lang['#ShowBars'] = 'Показывать полоски в верхней части экрана.'
lang['#EnableHints'] = 'Включить подсказки.'
lang['#Language'] = 'Язык'
lang['#EnableVignette'] = 'Показывать виньетку'
lang['#ShowTimestamps'] = 'Показывать время сообщений в чате.'
lang['#ShowCWMessages'] = 'Показывать сообщения игрового режима.'
lang['#ShowServerMessages'] = 'Показывать сообщения от сервера.'
lang['#ShowOOCMessages'] = 'Показывать OOC чат.'
lang['#ShowICMessages'] = 'Показывать IC чат.'
lang['#HeadbobAmount'] = 'Амплитуда пошатывания головы:'
lang['#ChatLines'] = 'Количество строк чата:'
lang['#EnableConsoleLog'] = 'Включить логи администратора.'
lang['#TextColor'] = 'Цвет текста:'
lang['#BGColor'] = 'Цвет фона:'
lang['#TabMenuX'] = 'Позиция TAB-меню по оси X:'
lang['#TabMenuY'] = 'Позиция TAB-меню по оси Y:'
lang['#BackMenuX'] = 'Позиция фона по оси X:'
lang['#BackMenuY'] = 'Позиция фона по оси Y:'
lang['#BackMenuW'] = 'Ширина фона:'
lang['#BackMenuH'] = 'Высота фона:'
lang['#FadePanels'] = 'Переливать панели:'
lang['#ShowMaterial'] = 'Показывать материал:'
lang['#ShowGradient'] = 'Показывать блюр-фон:'
lang['#MenuMaterial'] = 'Материал:'

-- Settings Descriptions
lang['#ThemeDesc'] = 'Выбранное оформление для интерфейса пользователя.'
lang['#EnableAdminESPDesc'] = 'Включить/выключить радар администратора.'
lang['#DrawESPBarsDesc'] = 'Отрисовывать полоски прогресса для некоторых значений.'
lang['#ShowItemEntitiesDesc'] = 'Показывать предметы на радаре.'
lang['#ShowSalesmenEntitiesDesc'] = 'Показывать NPC-продавцов на радаре.'
lang['#ESPIntervalDesc'] = 'Интервал между обновлениями радара.'
lang['#TwelveHourClockDesc'] = 'Использовать 12-часовые часы.'
lang['#ShowBarsDesc'] = 'Показывать полоски в верхнем углу экрана.'
lang['#EnableHintsDesc'] = 'Показывать подсказки.'
lang['#LangDesc'] = 'Выбранный язык.'
lang['#EnableVignetteDesc'] = 'Отрисовывать виньетку по краям экрана.'
lang['#ShowTimestampsDesc'] = 'Показывать время возле сообщений в чате.'
lang['#ShowCWMessagesDesc'] = 'Показывать сообщения игрового режима.'
lang['#ShowServerMessagesDesc'] = 'Показывать сообщения сервера.'
lang['#ShowOOCMessagesDesc'] = 'Показывать глобальные (OOC) сообщения.'
lang['#ShowICMessagesDesc'] = 'Показывать сообщения персонажей (IC чат).'
lang['#HeadbobAmountDesc'] = 'Множитель качки (шатания) головы.'
lang['#ChatLinesDesc'] = 'Количество строк чата, которые можно увидеть за раз.'
lang['#EnableConsoleLogDesc'] = 'Показывать логи администратора.'
lang['#TextColorDesc'] = 'Цвет, используемый по большей части для текстов оформления.'
lang['#BGColorDesc'] = 'Цвет фона.'
lang['#TabMenuXDesc'] = 'Позиция TAB-меню по оси X.'
lang['#TabMenuYDesc'] = 'Позиция TAB-меню по оси Y.'
lang['#BackMenuXDesc'] = 'Позиция фона по оси X.'
lang['#BackMenuYDesc'] = 'Позиция фона по оси Y.'
lang['#BackMenuWDesc'] = 'Ширина фона.'
lang['#BackMenuHDesc'] = 'Высота фона.'
lang['#FadePanelsDesc'] = 'Использовать переливание панелей из одной в другую при смене вкладок TAB-меню.'
lang['#ShowMaterialDesc'] = 'Отрисовывать материал на фоне меню.'
lang['#ShowGradientDesc'] = 'Отрисовывать градиент (блюр) на фоне меню.'
lang['#MenuMaterialDesc'] = 'Материал, используемый как фон для TAB-меню.'

-- Settings Names
lang['#EnableAdminESP'] = 'Включить радар администратора.'
lang['#DrawESPBars'] = 'Показывать полоски.'
lang['#ShowSpawnPoints'] = 'Показывать точки возрождения.'
lang['#ShowStaticEnts'] = 'Показывать статичные объекты.'
lang['#ShowItemEntities'] = 'Показывать предметы.'
lang['#ShowSalesmenEntities'] = 'Показывать продавцов.'
lang['#ESPInterval'] = 'Интервал обновления радара:'
lang['#TwelveHourClock'] = 'Включить 12-часовые часы.'
lang['#ShowBars'] = 'Показывать полоски в верхней части экрана.'
lang['#EnableHints'] = 'Включить подсказки.'
lang['#Language'] = 'Язык'
lang['#EnableVignette'] = 'Показывать виньетку'
lang['#ShowTimestamps'] = 'Показывать время сообщений в чате.'
lang['#ShowCWMessages'] = 'Показывать сообщения игрового режима.'
lang['#ShowServerMessages'] = 'Показывать сообщения от сервера.'
lang['#ShowOOCMessages'] = 'Показывать OOC чат.'
lang['#ShowICMessages'] = 'Показывать IC чат.'
lang['#HeadbobAmount'] = 'Амплитуда шатания головы:'
lang['#ChatLines'] = 'Количество строк чата:'
lang['#EnableConsoleLog'] = 'Включить логи администратора.'
lang['#TextColor'] = 'Цвет текста:'
lang['#BGColor'] = 'Цвет фона:'
lang['#TabMenuX'] = 'Позиция TAB-меню по оси X:'
lang['#TabMenuY'] = 'Позиция TAB-меню по оси Y:'
lang['#BackMenuX'] = 'Позиция фона по оси X:'
lang['#BackMenuY'] = 'Позиция фона по оси Y:'
lang['#BackMenuW'] = 'Ширина фона:'
lang['#BackMenuH'] = 'Высота фона:'
lang['#FadePanels'] = 'Переливать панели:'
lang['#ShowMaterial'] = 'Показывать материал:'
lang['#ShowGradient'] = 'Показывать блюр-фон:'
lang['#MenuMaterial'] = 'Материал:'

--[[
  You don't HAVE to translate the config, but I feel like it'd be
  easier for server owners / SAs who have trouble with English.
--]]

-- Config Descriptions
lang['#AttributeProgressionScaleDesc'] = 'Множитель прогресса атрибутов.'
lang['#MessagesMustSeePlayerDesc'] = 'Должен ли говорящий игрок находиться в поле зрения другого игрока, чтобы быть услышанным.'
lang['#StartingAttributePointsDesc'] = 'Количество очков атрибутов, которые игрок имеет сначала.'
lang['#ClockworkIntroEnabledDesc'] = 'Включить заставку при первоначальном заходе на сервер.'
lang['#HealthRegenerationEnabledDesc'] = 'Включить постепенную регенерацию здоровья.'
lang['#PropProtectionEnabledDesc'] = 'Включить защиту объектов (пропов).'
lang['#UseLocalMachineDateDesc'] = 'Использовать дату сервера при загрузке карты.'
lang['#UseLocalMachineTimeDesc'] = 'Использовать время сервера при загрузке карты.'
lang['#UseKeyOpensEntityMenusDesc'] = "Открывает ли клавиша 'использовать' контекстные меню объектов."
lang['#ShootAfterRaiseDelayDesc'] = "При приведении оружия в боевую готовность, сколько времени должен ждать игрок\nпрежде чем он сможет начать стрельбу.\nЗначение '0' убирает эту задержку."
lang['#UseClockworkAdminSystemDesc'] = 'Используется ли на сервере какая-либо другая админка, чем встроенная в Catwork.'
lang['#SavedRecognisedNamesDesc'] = 'Включить сохранение знакомых имён персонажей.'
lang['#SaveAttributeBoostsDesc'] = 'Включить сохранение увеличения атрибутов.'
lang['#RagdollDamageImmunityTimeDesc'] = 'Время в секундах, пока рэгдолл игрока не получает никакого урона.'
lang['#AdditionalCharacterCountDesc'] = 'Количество дополнительных персонажей, которое игрок может создать.'
lang['#ClassChangingIntervalDesc'] = 'Время, которое игрок должен подождать между сменами классов (в секундах).'
lang['#SprintingLowersWeaponDesc'] = 'Опускается ли оружие при беге.'
lang['#WeaponRaisingSystemDesc'] = 'Включить систему опускания оружия.'
lang['#PropKillProtectionDesc'] = 'Включить защиту от убийства объектами.'
lang['#GeneratorIntervalDesc'] = 'Сколько времени требуется генератору, чтобы произвести деньги (в секундах).'
lang['#GravityGunPuntDesc'] = 'Включить возможность гравипушки толкать предметы.'
lang['#DefaultInventoryWeightDesc'] = 'Вес, который игрок может переносить в инвентаре (килограммы).'
lang['#DefaultInventorySpaceDesc'] = 'Объем, который игрок может переносить в инвентаре (литры).'
lang['#DataSaveIntervalDesc'] = 'Интервал сохранения данных сервером в секундах.'
lang['#ViewPunchOnDamageDesc'] = 'Искажается ли экран при ударе в игрока.'
lang['#UnrecognisedNameDesc'] = 'Описание неизвестных личностей.'
lang['#LimbDamageSystemDesc'] = 'Включена ли система урона по конечностям.'
lang['#FallDamageScaleDesc'] = 'Множитель урона от падения.'
lang['#StartingCurrencyDesc'] = 'Сумма по умолчанию, с которой начинает игрок.'
lang['#ArmorAffectsChestDesc'] = 'Влияет ли броня только на район груди.'
lang['#MinimumPhysicalDescriptionDesc'] = 'Минимальное количество символов в описании.'
lang['#WoodBreaksFallDesc'] = 'Ломаются ли деревянные пропы при взаимодействии с игроком.'
lang['#VignetteEnabledDesc'] = 'Использовать виньетку.'
lang['#HeartbeatSoundsDesc'] = 'Использовать сердцебиение.'
lang['#CrosshairEnabledDesc'] = 'Использовать прицел.'
lang['#FreeAimingDesc'] = 'Использовать свободное прицеливание.'
lang['#RecogniseSystemDesc'] = 'Использовать систему знакомств.'
lang['#CurrencyEnabledDesc'] = 'Использовать денежную систему.'
lang['#DefaultPhysicalDescriptionDesc'] = 'Физическое описание по умолчанию.'
lang['#ChestDamageScaleDesc'] = 'Множитель урона в грудь.'
lang['#CorpseDecayTimeDesc'] = 'Время, за которое растворяется рэгдолл игрока.'
lang['#BannedDisconnectMessageDesc'] = 'Сообщение, показывающееся заблокированным пользователям.\n!t для оставшегося времени, !f для формата времени.'
lang['#WagesIntervalDesc'] = 'Промежуток времени между зарплатами (секунды).'
lang['#PropCostScaleDesc'] = 'Множитель цен на пропы.\n0 - бесплатные пропы.'
lang['#FadeNPCCorpsesDesc'] = 'Растворять рэгдоллы мертвых НПЦ.'
lang['#CashWeightDesc'] = 'Вес валюты (кг).'
lang['#CashSpaceDesc'] = 'Объем валюты (литры).'
lang['#HeadDamageScaleDesc'] = 'Множитель урона в голову.'
lang['#BlockInventoryBindsDesc'] = 'Заблокировать бинды инвентаря.'
lang['#LimbDamageScaleDesc'] = 'Множитель урона в конечности.'
lang['#TargetIDDelayDesc'] = 'Задержка перед выводом информации об энтити.'
lang['#HeadbobEnabledDesc'] = 'Использовать качание головы.'
lang['#ChatCommandPrefixDesc'] = 'Префикс для чат-команд.'
lang['#CrouchWalkSpeedDesc'] = 'Скорость ползка по умолчанию.'
lang['#MaximumChatLengthDesc'] = 'Максимальное количество символов, разрешенное для написания в чат.'
lang['#StartingFlagsDesc'] = 'Стартовые флаги по умолчанию.'
lang['#PlayerSprayDesc'] = 'Могут ли игроки использовать спрей.'
lang['#HintIntervalDesc'] = 'Промежуток времени между подсказками.'
lang['#OOCChatIntervalDesc'] = 'Промежуток времени между сообщениями в чат OOC.'
lang['#MinuteTimeDesc'] = 'Сколько длится минута на сервере (в секундах).'
lang['#DoorUnlockIntervalDesc'] = 'Сколько секунд открывается дверь.'
lang['#VoiceChatEnabledDesc'] = 'Использовать голосовой чат.'
lang['#LocalVoiceChatDesc'] = 'Использовать локальный голосовой чат.'
lang['#TalkRadiusDesc'] = 'Радиус разговора по умолчанию.'
lang['#GiveHandsDesc'] = 'Давать ли кулаки игрокам по умолчанию.'
lang['#CustomWeaponColorDesc'] = 'Использовать кастомизированные цвета вещей.'
lang['#GiveKeysDesc'] = 'Давать ли ключи игрокам по умолчанию.'
lang['#WagesNameDesc'] = 'Название зарплаты по умолчанию.'
lang['#JumpPowerDesc'] = 'Высота прыжка по умолчанию.'
lang['#RespawnDelayDesc'] = 'Длительность воскрешения игрока.'
lang['#MaximumWalkSpeedDesc'] = 'Скорость ходьбы по умолчанию.'
lang['#MaximumRunSpeedDesc'] = 'Скорость бега по умолчанию.'
lang['#DoorPriceDesc'] = 'Стоимость двери по умолчанию.'
lang['#DoorLockIntervalDesc'] = 'Сколько секунд закрывается дверь.'
lang['#MaximumOwnableDoorsDesc'] = 'Максимальное количество дверей, которыми может владеть один игрок.'
lang['#EnableSpaceSystemDesc'] = 'Использовать ли объемную систему инвентаря.'
lang['#DrawIntroBarsDesc'] = 'Использовать кинематографичные полоски при заходе в игру.'
lang['#EnableLOOCIconsDesc'] = 'Разрешить иконки в LOOC чате.'
lang['#ShowBusinessMenuDesc'] = 'Включить бизнес меню.'
lang['#EnableChatMultiplierDesc'] = 'Менять ли размер текста в зависимости от использованной команды (крик, шепот).'
lang['#SteamAPIKeyDesc'] = 'Некоторые функции могут требовать Steam API.\nhttp://steamcommunity.com/dev/apikey'
lang['#MapPropsPhysgrabDesc'] = 'Разрешить игрокам манипулировать пропами карты, используя физган.'
lang['#EntityUseCooldownDesc'] = 'Промежуток времени между использованием энтити.'
lang['#EnableSmoothSprintDesc'] = 'Использование плавного перехода в бег.'
lang['#EnableQuickRaiseDesc'] = 'Могут ли игроки быстро поднимать оружие.'
lang['#PlayersChangeThemesDesc'] = 'Могут ли игроки самостоятельно менять тему схемы.'
lang['#DefaultThemeDesc'] = 'Тема по умолчанию.'

-- Config Names
lang['#AttributeProgressionScale'] = 'Attribute Progression Scale'
lang['#MessagesMustSeePlayer'] = 'Messages Must See Player'
lang['#StartingAttributePoints'] = 'Starting Attribute Points'
lang['#ClockworkIntroEnabled'] = 'Clockwork Introduction Enabled'
lang['#HealthRegenerationEnabled'] = 'Health Regeneration Enabled'
lang['#PropProtectionEnabled'] = 'Prop Protection Enabled'
lang['#UseLocalMachineDate'] = 'Use Local Machine Date'
lang['#UseLocalMachineTime'] = 'Use Local Machine Time'
lang['#UseKeyOpensEntityMenus'] = 'Use Key Opens Entity Menus'
lang['#ShootAfterRaiseDelay'] = 'Shoot After Raise Delay'
lang['#UseClockworkAdminSystem'] = "Use Clockwork's Admin System"
lang['#SavedRecognisedNames'] = 'Saved Recognised Names'
lang['#SaveAttributeBoosts'] = 'Save Attribute Boosts'
lang['#RagdollDamageImmunityTime'] = 'Ragdoll Damage Immunity Time'
lang['#AdditionalCharacterCount'] = 'Additional Character Count'
lang['#ClassChangingInterval'] = 'Class Changing Interval'
lang['#SprintingLowersWeapon'] = 'Sprinting Lowers Weapon'
lang['#WeaponRaisingSystem'] = 'Weapon Raising System Enabled'
lang['#PropKillProtection'] = 'Prop Kill Protection Enabled'
lang['#SmoothServerRates'] = 'Use Smooth Server Rates'
lang['#MediumServerRates'] = 'Use Medium Performance Server Rates'
lang['#LagFreeServerRates'] = 'Use Lag Free Server Rates'
lang['#GeneratorInterval'] = 'Generator Interval'
lang['#GravityGunPunt'] = 'Gravity Gun Punt Enabled'
lang['#DefaultInventoryWeight'] = 'Default Inventory Weight'
lang['#DefaultInventorySpace'] = 'Default Inventory Space'
lang['#DataSaveInterval'] = 'Data Save Interval'
lang['#ViewPunchOnDamage'] = 'View Punch On Damage'
lang['#UnrecognisedName'] = 'Unrecognised Name'
lang['#LimbDamageSystem'] = 'Limb Damage System Enabled'
lang['#FallDamageScale'] = 'Fall Damage Scale'
lang['#StartingCurrency'] = 'Starting Currency'
lang['#ArmorAffectsChest'] = 'Armor Affects Chest Only'
lang['#MinimumPhysicalDescription'] = 'Minimum Physical Description Length'
lang['#WoodBreaksFall'] = 'Wood Breaks Fall'
lang['#VignetteEnabled'] = 'Vignette Enabled'
lang['#HeartbeatSounds'] = 'Heartbeat Sounds Enabled' // Day 132. Still converting strings..
lang['#CrosshairEnabled'] = 'Crosshair Enabled'
lang['#FreeAiming'] = 'Free Aiming Enabled'
lang['#RecogniseSystem'] = 'Recognise System Enabled'
lang['#CurrencyEnabled'] = 'Currency Enabled'
lang['#DefaultPhysicalDescription'] = 'Default Physical Description'
lang['#ChestDamageScale'] = 'Chest Damage Scale'
lang['#CorpseDecayTime'] = 'Corpse Decay Time'
lang['#BannedDisconnectMessage'] = 'Banned Disconnect Message'
lang['#WagesInterval'] = 'Wages Interval'
lang['#PropCostScale'] = 'Prop Cost Scale'
lang['#FadeNPCCorpses'] = 'Fade NPC Corpses'
lang['#CashWeight'] = 'Cash Weight'
lang['#CashSpace'] = 'Cash Space'
lang['#HeadDamageScale'] = 'Head Damage Scale'
lang['#BlockInventoryBinds'] = 'Block Inventory Binds'
lang['#LimbDamageScale'] = 'Limb Damage Scale'
lang['#TargetIDDelay'] = 'Target ID Delay'
lang['#HeadbobEnabled'] = 'Headbob Enabled'
lang['#ChatCommandPrefix'] = 'Chat Command Prefix'
lang['#CrouchWalkSpeed'] = 'Crouch Walk Speed'
lang['#MaximumChatLength'] = 'Maximum Chat Length'
lang['#StartingFlags'] = 'Starting Flags'
lang['#PlayerSpray'] = 'Player Spray Enabled'
lang['#HintInterval'] = 'Hint Interval'
lang['#OOCChatInterval'] = 'Out-Of-Character Chat Interval'
lang['#MinuteTime'] = 'Minute Time'
lang['#DoorUnlockInterval'] = 'Door Unlock Interval'
lang['#VoiceChatEnabled'] = 'Voice Chat Enabled'
lang['#LocalVoiceChat'] = 'Local Voice Chat'
lang['#TalkRadius'] = 'Talk Radius'
lang['#GiveHands'] = 'Give Hands'
lang['#CustomWeaponColor'] = 'Custom Weapon Color'
lang['#GiveKeys'] = 'Give Keys'
lang['#WagesName'] = 'Wages Name'
lang['#JumpPower'] = 'Jump Power'
lang['#RespawnDelay'] = 'Respawn Delay' // Send help...
lang['#MaximumWalkSpeed'] = 'Maximum Walk Speed'
lang['#MaximumRunSpeed'] = 'Maximum Run Speed'
lang['#DoorPrice'] = 'Door Price'
lang['#DoorLockInterval'] = 'Door Lock Interval'
lang['#MaximumOwnableDoors'] = 'Maximum Ownable Doors'
lang['#EnableSpaceSystem'] = 'Enable Space System'
lang['#DrawIntroBars'] = 'Draw Intro Bars'
lang['#EnableLOOCIcons'] = 'Enable LOOC Icons'
lang['#ShowBusinessMenu'] = 'Show Business Menu'
lang['#EnableChatMultiplier'] = 'Enable Chat Multiplier'
lang['#SteamAPIKey'] = 'Steam API Key'
lang['#MapPropsPhysgrab'] = 'Enable Map Props Physgrab'
lang['#EntityUseCooldown'] = 'Entity Use Cooldown'
lang['#EnableSmoothSprint'] = 'Enable Smooth Sprint'
lang['#EnableQuickRaise'] = 'Enable Quick Raise'
lang['#PlayersChangeThemes'] = 'Players Change Themes'
lang['#DefaultTheme'] = 'Default Theme'

-- Days
lang['#Monday'] = 'Понедельник'
lang['#Tuesday'] = 'Вторник'
lang['#Wednesday'] = 'Среда'
lang['#Thursday'] = 'Четверг'
lang['#Friday'] = 'Пятница'
lang['#Saturday'] = 'Суббота'
lang['#Sunday'] = 'Воскресенье'

-- Tab Menu Descriptions
lang['#BusinessDesc'] = 'Покупайте предметы для вашего бизнеса.'
lang['#InventoryDesc'] = 'Управление предметами в вашем инвентаре.'
lang['#DirectoryDesc'] = 'Документация команд, а также различная информация.'
lang['#SystemDesc'] = 'Доступ к различным настройкам сервера.'
lang['#ScoreboardDesc'] = 'Список игроков на сервере.'
lang['#AttributesDesc'] = 'Статус ваших атрибутов.'
lang['#SettingsDesc'] = 'Настройте то, как Catwork работает у вас.'
lang['#ClassesDesc'] = 'Выбор класса вашего персонажа.'
lang['#CharactersDesc'] = 'Нажмите эту кнопку, чтобы перейти в меню выбора персонажей.'
lang['#CloseMenuDesc'] = 'Нажмите эту кнопку, чтобы закрыть это меню.'

-- Tab Menu Names
lang['#Attributes'] = 'Атрибуты'
lang['#Attribute'] = 'Атрибут'
lang['#System'] = 'Админ'
lang['#Settings'] = 'Настройки'
lang['#Classes'] = 'Классы'
lang['#Scoreboard'] = 'Игроки'
lang['#Directory'] = 'Помощь'
lang['#Inventory'] = 'Инвентарь'
lang['#Business'] = 'Бизнес'
lang['#Traits'] = 'Особенности'
lang['#Characters'] = 'ПЕРСОНАЖИ'
lang['#CloseMenu'] = 'ЗАКРЫТЬ'

-- MainMenu
lang['#MainMenu_New'] = 'СОЗДАТЬ'
lang['#MainMenu_Load'] = 'ЗАГРУЗИТЬ'
lang['#MainMenu_Leave'] = 'ОТКЛЮЧИТЬСЯ'
lang['#MainMenu_DevelopedBy'] = 'АВТОР: #1'
lang['#MainMenu_Loading'] = 'Загрузка...'

-- Quiz panel
lang['#QuizPanel_Continue'] = 'ПРОДОЛЖИТЬ'
lang['#QuizPanel_Disconnect'] = 'ОТКЛЮЧИТЬСЯ'
lang['#QuizPanel_Language'] = 'Язык'
lang['#QuizPanel_Questions'] = 'Вопросы'
lang['#QuizPanel_KickReason'] = 'Вы ответили на один или несколько вопросов неправильно!'
lang['#QuizPanel_Warning'] = 'Если вы дадите неверные ответы - вас может отключить с сервера.'

-- Character Creation
lang['#CharCreation_Previous'] = 'НАЗАД'
lang['#CharCreation_Next'] = 'ДАЛЕЕ'
lang['#CharCreation_Cancel'] = 'ОТМЕНА'
lang['#CharCreation_CannotCreateMoreChars'] = 'Вы не можете создать еще одного персонажа!'

lang['#CharCreation_Persuasion'] = 'Фракция/Пол'
lang['#CharCreation_FactionHelp'] = 'Фракция определяет общий характер персонажа и, скорее всего, в дальнейшем не может быть изменена.'
lang['#CharCreation_Faction'] = 'Фракция'
lang['#CharCreation_Gender'] = 'Пол'

lang['#CharCreation_Description'] = 'Описание'
lang['#CharCreation_Name'] = 'Имя'
lang['#CharCreation_FullName'] = 'Полное Имя'
lang['#CharCreation_Forename'] = 'Имя'
lang['#CharCreation_Surname'] = 'Фамилия'
lang['#CharCreation_Appearance'] = 'Внешность'
lang['#CharCreation_AppearanceHelp1'] = 'Напишите физическое описание для вашего персонажа на русском языке и выберите подходящую игровую модель.'
lang['#CharCreation_AppearanceHelp2'] = 'Напишите физическое описание для вашего персонажа на русском языке.'

lang['#CharCreation_Classes'] = 'Классы'
lang['#CharCreation_DefaultClass'] = 'Класс'
lang['#CharCreation_ClassesHelp'] = 'Выберите эту опцию, чтобы сделать её классом вашего персонажа по умолчанию.'

lang['#CharCreation_AttributesHelp'] = 'Доступное количество очков умений: #1.'

lang['#CharCreation_Persuasion_ErrorMessage'] = 'Вы не выбрали фракцию или фракция, которую вы выбрали, не существует!'
lang['#CharCreation_Appearance_ErrorMessage1'] = 'Вы не выбрали имя или имя, которое вы выбрали, не является допустимым!'
lang['#CharCreation_Appearance_ErrorMessage2'] = 'Ваше имя и фамилия не должны содержать знаки пунктуации, пробелы или цифры!'
lang['#CharCreation_Appearance_ErrorMessage3'] = 'Ваше имя и фамилия должны содержать по крайней мере один гласный!'
lang['#CharCreation_Appearance_ErrorMessage4'] = 'Ваше имя и фамилия должны содержать хотя бы 2 символа!'
lang['#CharCreation_Appearance_ErrorMessage5'] = 'Ваше имя и фамилия не должны быть длиннее 16 символов!'
lang['#CharCreation_Appearance_ErrorMessage6'] = 'Вы не выбрали игровую модель или модель, которую вы выбрали, не является допустимой!'
lang['#CharCreation_Appearance_ErrorMessage7'] = 'Физическое описание должно быть как минимум #1 символов длиной!'
lang['#CharCreation_Classes_ErrorMessage'] = 'Вы не выбрали класс или класс, который вы выбрали, не является допустимым!'

lang['#CharCreation_DidntFill'] = 'Вы не заполнили #1.'
lang['#CharCreation_DidntFillWithNumber'] = 'Вы не заполнили #1 числовым значением.'
lang['#CharCreation_CantGoHigh'] = 'Вы превысили лимит в #1 символов в #2 текстовом поле.'
lang['#CharCreation_CantGoLow'] = 'Минимум символов в #2 равно #1.'

-- Business Menu
lang['#BusinessMenu_NoAccess'] = 'У вас нет доступа к #1 меню!'
lang['#BusinessMenu_Free'] = 'Бесплатно'

-- Attributes Menu
lang['#AttributesMenu_NoAccess'] = 'У вас нет доступа ни к каким атрибутам!' -- i assume #1 here is 'attributes'

-- Classes Menu
lang['#ClassesMenu_NoStay'] = 'Выбранные вами классы не будут прикреплены к вашему персонажу.'
lang['#ClassesMenu_NoAccess'] = 'У вас нет доступа ни к каким классам!'
lang['#ClassesMenu_CurrentPlayers'] = 'В данном классе #1 из #2 персонажей.'

-- Scoreboard
lang['#Scoreboard_Tip'] = 'Нажатие на модельку игрока открывает меню действий.'

-- Donations Menu
lang['#DonationsMenu_Title'] = 'Пожертвования'
lang['#DonationsMenu_SomeSubsExpire'] = 'Некоторые подписки истекают, и их необходимо будет продлить.'
lang['#DonationsMenu_NoActiveSubs'] = 'У вас нет ни одной активной подписки!'
lang['#DonationsMenu_NoExpire'] = 'Эта подписка не истекает.'
lang['#DonationsMenu_Expired'] = 'Эта подписка истекла!'
lang['#DonationsMenu_ExpiresIn'] = 'Подписка истекает через #1 секунд.'

-- Command syntax highlighter.
lang['#CMDDesc_Aliases'] = 'Другие написания:'
lang['#CMDDesc_Usage'] = 'Синтаксис:'

-- F1 Menu
lang['#InfoMenu_Title'] = 'ИНФОРМАЦИЯ О ПЕРСОНАЖЕ'
lang['#InfoMenu_SelectOption'] = 'БЫСТРЫЕ ДЕЙСТВИЯ'

-- Command Descriptions,
lang['#Commands_RollDesc'] = 'Выдает случайное число между 0 и вашим числом.'
lang['#Commands_MeDesc'] = 'Описывает ваше действие в третьем лице.'
lang['#Commands_YDesc'] = 'Крик персонажам вокруг вас.'
lang['#Commands_WDesc'] = 'Шепот персонажам вокруг вас.'
lang['#Commands_PMDesc'] = 'Написать приватное сообщение.'
lang['#Commands_RDesc'] = 'Отправить радиосообщение.'
lang['#Commands_FDesc'] = 'Упасть на землю.'

-- Chat suffixes and prefixes.
lang['#Suffix_Whisper'] = 'шепчет:'
lang['#Suffix_Yell'] = 'кричит:'

-- Typing display.
lang['#TD_Yelling'] = 'Кричит...'
lang['#TD_Whispering'] = 'Шепчет...'
lang['#TD_Typing'] = 'Печатает...'
lang['#TD_Talking'] = 'Говорит...'
lang['#TD_Radioing'] = 'Говорит по рации...'
lang['#TD_Performing'] = 'Выполняет действие...'

-- Hints.
lang['#Hints_OOC'] = 'Введите // перед вашим сообщением, чтобы написать в общий чат (ООС).'
lang['#Hints_LOOC'] = 'Введите .// или [[ перед вашим сообщением, чтобы писать в локальный чат (LOOC).'
lang['#Hints_Ducking'] = 'Зажмите :+speed: и нажмите :+walk:, пока стоите на месте, чтобы пригнуться.'
lang['#Hints_Directory'] = 'Нажмите :+showscores: и кликните на кнопку «Помощь» для получения необходимой информации.'
lang['#Hints_F1_Hotkey'] = 'Нажмите :gm_showhelp:, чтобы посмотреть информацию о вашем персонаже.'
lang['#Hints_F2_Hotkey'] = 'Нажмите :gm_showteam:, пока смотрите на дверь, чтобы открыть меню двери.'
lang['#Hints_Tab_Hotkey'] = 'Нажмите или зажмите :+showscores:, чтобы открыть главное меню.'

lang['#Hints_Context_Menu'] = 'Зажмите :+menu_context: и нажмите на предмет правой кнопкой мыши, чтобы открыть меню действий над предметом.'
lang['#Hints_Entity_Menu'] = 'Нажмите :+use:, смотря на предмет, чтобы открыть меню действий над предметом.'
lang['#Hints_Phys_Desc'] = 'Изменить физическое описание вашего персонажа можно с помощью команды $command_prefix$CharPhysDesc.'
lang['#Hints_Give_Name'] = 'Нажмите :gm_showteam:, чтобы разрешить персонажам в определённом радиусе узнавать вас.'
lang['#Hint_Raise_Weapon'] = 'Зажмите :+reload:, чтобы поднять или опустить ваше оружие.'
lang['#Hint_Target_Recognises'] = 'Имя персонажа будет мигать белым цветом, если он не узнаёт вас.'

-- Misc Terms
lang['#Destroy'] = 'Уничтожить'
lang['#Cash'] = 'Деньги'
lang['#Drop'] = 'Выбросить'
lang['#Use'] = 'Использовать'
lang['#hl2rp_cashname'] = 'Деньги'

lang['#Bars_Health'] = 'ЗДОРОВЬЕ'
lang['#Bars_Armor'] = 'БРОНЯ'
lang['#Bars_Stamina'] = 'ВЫНОСЛИВОСТЬ'
lang['#Bars_Hunger'] = 'ГОЛОД'
lang['#Bars_Thirst'] = 'ЖАЖДА'

-- Sweps.
lang['#SWEPS_Author'] = 'Автор:'
lang['#SWEPS_Contact'] = 'Контакты:'
lang['#SWEPS_Purpose'] = 'Назначение:'
lang['#SWEPS_Instructions'] = 'Инструкция:'
lang['#SWEPS_Description'] = 'Описание:'
lang['#SWEPS_Ammunition'] = 'Боеприпасы:'

lang['#SWEPS_Hands'] = 'Руки'
lang['#SWEPS_Hands_Instructions'] = 'Первичный Огонь: Ударить.\nВторичный Огонь: Постучать в дверь или взять предмет.\nR: Уронить предмет.'
lang['#SWEPS_Hands_Purpose'] = 'Нанесение урона другим персонажам и возможность стучать в двери.'

lang['#SWEPS_Keys'] = 'Ключи'
lang['#SWEPS_Keys_Instructions'] = 'Первичный Огонь: Закрыть.\nВторичный Огонь: Открыть.'
lang['#SWEPS_Keys_Purpose'] = 'Открыть или закрыть на ключ предметы, к которым вы имеете доступ.'

-- Other.
lang['#Console'] = 'Консоль'

lang['#Schema_Credits'] = 'Ролевая игра предоставлена #1.'

lang['#MainMenu_Loading'] = 'Загрузка...'

lang['#Commands_cwLua_accessDenied'] = 'Вы не имеете доступа к этой команде, #1.'

lang['#Doors_Name'] = 'Дверь'
lang['#Doors_Unownable'] = 'Этой дверью нельзя владеть.'
lang['#Doors_CanBePurchased'] = 'Эта дверь может быть приобретена.'
lang['#Doors_CanBeOwned'] = 'Этой дверью можно владеть.'
lang['#Doors_HasBeenPurchased'] = 'Эта дверь была приобретена.'
lang['#Doors_HasBeenOwned'] = 'Этой дверью завладели.'

lang['#StatusInfo_lock'] = '[Закрывает]'
lang['#StatusInfo_unlock'] = '[Открывает]'
lang['#StatusInfo_unragdoll'] = '[Без сознания]'
lang['#StatusInfo_unragdoll_fallenover'] = '[Поднимается]'
lang['#StatusInfo_Dead'] = '[Мёртв]'
lang['#StatusInfo_Performing'] = "[Выполняет '#1']"
lang['#StatusInfo_fallenover'] = '[Упавший]'

lang['#CharacterPanelToolTip_PlayersWithThisFaction'] = 'Всего #1/#2 персонажей этой фракции.'

lang['#AdminESPInfo_Salesman'] = '[Продавец]'
lang['#AdminESPInfo_Item'] = '[Предмет]'
lang['#PlayerESPInfo_Health'] = 'Здоровье'
lang['#PlayerESPInfo_Armor'] = 'Броня'

lang['#ProgressBarInfo_spawn'] = 'Возрождение...'
lang['#ProgressBarInfo_lock'] = 'Объект закрывается.'
lang['#ProgressBarInfo_unlock'] = 'Объект открывается.'
lang['#ProgressBarInfo_unragdoll'] = 'Вы приходите в сознание.'
lang['#ProgressBarInfo_unragdoll_fallenover'] = 'Вы поднимаетесь на ноги.'
lang['#ProgressBarInfo_PlayerCanGetUp'] = "Нажмите 'прыжок', чтобы подняться."

lang['#RecogniseMenu_whisper'] = 'Все персонажи в радиусе шепота.'
lang['#RecogniseMenu_yell'] = 'Все персонажи в радиусе крика.'
lang['#RecogniseMenu_talk'] = 'Все персонажи в радиусе разговора.'
lang['#RecogniseMenu_look'] = 'Персонаж, на которого вы смотрите.'

lang['#EntityMenuOptions_useText'] = 'Использовать'
lang['#EntityMenuOptions_Take'] = 'Взять'
lang['#EntityMenuOptions_Examine'] = 'Изучить'
lang['#EntityMenuOptions_Open'] = 'Открыть'

lang['#ScreenTextInfo_CharBanned_title'] = 'ЭТОТ ПЕРСОНАЖ ЗАБЛОКИРОВАН'
lang['#ScreenTextInfo_CharBanned_text'] = 'Перейдите в главное меню, чтобы сделать нового.'

lang['#HUDTargetID_Weapon_DrawInfo1'] = 'Неизвестное оружие'
lang['#HUDTargetID_Weapon_DrawInfo2'] = "Нажмите 'использовать', чтобы экипировать"

lang['#TargetPlayerStatus_Female'] = 'неё'
lang['#TargetPlayerStatus_Male'] = 'него'
lang['#TargetPlayerStatus_deceased'] = 'У #1 отсутствует пульс.'

lang['#Scoreboard_TargetPlayerText'] = 'Вы не знакомы с #1.'
lang['#Scoreboard_TargetPlayerText_him'] = 'ним'
lang['#Scoreboard_TargetPlayerText_her'] = 'ней'

lang['#Scoreboard_ScoreboardText'] = 'Вы не знакомы с #1.'
lang['#Scoreboard_ScoreboardText_him'] = 'ним'
lang['#Scoreboard_ScoreboardText_her'] = 'ней'

lang['#ScoreboardOptions_CharBan'] = 'Заблокировать Персонажа'
lang['#ScoreboardOptions_PlyKick'] = 'Кикнуть игрока'
lang['#ScoreboardOptions_PlyKick_StringRequest'] = 'С какой причиной вы хотите кикнуть игрока с сервера?'
lang['#ScoreboardOptions_PlyBan'] = 'Заблокировать Игрока'
lang['#ScoreboardOptions_PlyBan_StringRequest_Minutes'] = 'На сколько минут вы хотите заблокировать игрока?'
lang['#ScoreboardOptions_PlyBan_StringRequest_Reason'] = 'С какой причиной вы хотите заблокировать игрока?'
lang['#ScoreboardOptions_CharGiveFlags'] = 'Выдать Флаги'
lang['#ScoreboardOptions_CharGiveFlags_StringRequest'] = 'Какие флаги вы хотите выдать персонажу?'
lang['#ScoreboardOptions_CharTakeFlags'] = 'Забрать Флаги'
lang['#ScoreboardOptions_CharTakeFlags_StringRequest'] = 'Какие флаги вы хотите забрать у персонажа?'
lang['#ScoreboardOptions_CharSetName'] = 'Выставить Имя Персонажа'
lang['#ScoreboardOptions_CharSetName_StringRequest'] = 'Какое имя вы хотите выставить для этого персонажа?'
lang['#ScoreboardOptions_CharGiveItem'] = 'Дать Предмет'
lang['#ScoreboardOptions_CharGiveItem_StringRequest'] = 'Какой предмет вы хотите выдать этому персонажу?'
lang['#ScoreboardOptions_PlySetGroup'] = 'Назначить Группу'
lang['#ScoreboardOptions_PlySetGroup_SuperAdmin'] = 'Супер Админ'
lang['#ScoreboardOptions_PlySetGroup_Admin'] = 'Админ'
lang['#ScoreboardOptions_PlySetGroup_Operator'] = 'Оператор'
lang['#ScoreboardOptions_PlyDemote'] = 'Снять с группы'
lang['#ScoreboardOptions_PlyWhitelist'] = 'Выдать Вайтлист'
lang['#ScoreboardOptions_PlyUnWhitelist'] = 'Забрать Вайтлист'

lang['#DermaRequest_confirmQuery_Confirm'] = 'Подтвердить'
lang['#DermaRequest_confirmQuery_Cancel'] = 'Отмена'

lang['#QuickMenu_FallOver'] = 'Упасть'
lang['#QuickMenu_Description'] = 'Описание'

lang['#Emotes'] = 'Действия'
lang['#Emotes_animATW'] = 'Лицом к стене'
lang['#Emotes_animCheer'] = 'Одобрительные возгласы'
lang['#Emotes_animDeny'] = 'Отказывать'
lang['#Emotes_animIdle'] = 'Бездействие'
lang['#Emotes_animIdle_CrossHands'] = 'Скрестить руки'
lang['#Emotes_animIdle_HandsInPockets'] = 'Спрятать руки в карманы'
lang['#Emotes_animLean'] = 'Опереться о стену'
lang['#Emotes_animLean_ArmsBack'] = 'Без рук'
lang['#Emotes_animLean_ArmsDown'] = 'Руками за спиной'
lang['#Emotes_animLean_Normal'] = 'Нормально'
lang['#Emotes_animMotion'] = 'Оглянуться'
lang['#Emotes_animMotion_Left'] = 'Влево'
lang['#Emotes_animMotion_Right'] = 'Вправо'
lang['#Emotes_animMotion_Behind'] = 'Позади'
lang['#Emotes_animPant'] = 'Одышка'
lang['#Emotes_animPantWall'] = 'Одышка у стены'
lang['#Emotes_animSit'] = 'Сесть'
lang['#Emotes_animSitWall'] = 'Сесть у стены'
lang['#Emotes_animThreat'] = 'Угроза'
lang['#Emotes_animWave'] = 'Подозвать'
lang['#Emotes_animWave_Close'] = 'Спокойно'
lang['#Emotes_animWave_Normal'] = 'Оживлённо'
lang['#Emotes_animWindow'] = 'Взглянуть в окно'

lang['#Equipment'] = 'Экипировка'
lang['#Inventory'] = 'Инвентарь'
lang['#Weight'] = 'Вес'
lang['#Space'] = 'Место'

lang['#RecogniseMenu'] = 'ВЫБЕРИТЕ, КТО СМОЖЕТ УЗНАВАТЬ ВАС'

lang['#Command_A_Description'] = 'Отправить приватное сообщение администрации.'
lang['#Command_A_Syntax'] = '<текст>'
lang['#Command_Announce_Description'] = 'Отправить уведомление всем игрокам.'
lang['#Command_Announce_Syntax'] = '<текст>'
lang['#Command_Arequest_Description'] = 'Отправить запрос администрации.'
lang['#Command_Arequest_Syntax'] = '<текст>'
lang['#Command_Cfglistvars_Description'] = 'Список переменных конфигурации Catwork.'
lang['#Command_Cfglistvars_Syntax'] = '[код переменной]'
lang['#Command_Cfgsetvar_Description'] = 'Установить переменную Catwork.'
lang['#Command_Cfgsetvar_Syntax'] = '<текстовый код> [значение] [название карты]'
lang['#Command_Charban_Description'] = 'Заблокировать персонажа.'
lang['#Command_Charban_Syntax'] = '<имя>'
lang['#Command_Charcheckatts_Description'] = 'Проверка атрибутов персонажа.'
lang['#Command_Charcheckatts_Syntax'] = '<имя>'
lang['#Command_Charcheckflags_Description'] = 'Проверка флагов персонажа.'
lang['#Command_Charcheckflags_Syntax'] = '<имя>'
lang['#Command_Charfallover_Description'] = 'Упасть на пол.'
lang['#Command_Charfallover_Syntax'] = '[число секунд]'
lang['#Command_Chargetup_Description'] = 'Подняться на ноги.'
lang['#Command_Chargiveflags_Description'] = 'Выдать флаги персонажу.'
lang['#Command_Chargiveflags_Syntax'] = '<имя> <флаги>'
lang['#Command_Chargiveitem_Description'] = 'Выдать предмет персонажу.'
lang['#Command_Chargiveitem_Syntax'] = '<имя> <ID предмета> [количество]'
lang['#Command_Charphysdesc_Description'] = 'Изменить описание Вашего персонажа.'
lang['#Command_Charphysdesc_Syntax'] = '[текст]'
lang['#Command_Charsetdesc_Description'] = 'Изменить описание персонажа.'
lang['#Command_Charsetdesc_Syntax'] = '<имя> <описание>'
lang['#Command_Charsetflags_Description'] = 'Установить флаги персонажу.'
lang['#Command_Charsetflags_Syntax'] = '<имя> <флаги>'
lang['#Command_Charsetmodel_Description'] = 'Установить модель персонажу.'
lang['#Command_Charsetmodel_Syntax'] = '<имя> <модель>'
lang['#Command_Charsetname_Description'] = 'Установить имя персонажа.'
lang['#Command_Charsetname_Syntax'] = '<имя> <новое имя>'
lang['#Command_Chartakeflags_Description'] = 'Изъять флаги персонажа.'
lang['#Command_Chartakeflags_Syntax'] = '<имя> <флаги>'
lang['#Command_Chartie_Description'] = 'Связать / развязать игрока.'
lang['#Command_Chartie_Syntax'] = '<имя>'
lang['#Command_Chartransfer_Description'] = 'Переместить персонажа во фракцию.'
lang['#Command_Chartransfer_Syntax'] = '<имя> <фракция> [доп. данные]'
lang['#Command_Charunban_Description'] = 'Разблокировать персонажа (указать полное имя).'
lang['#Command_Charunban_Syntax'] = '<имя>'
lang['#Command_Dropcash_Description'] = 'Выбросить '
lang['#Command_Dropcash_Syntax'] = '<количество '
lang['#Command_Dropweapon_Description'] = 'Выбросить оружие перед собой.'
lang['#Command_Event_Description'] = 'Описать какое-либо событие всем персонажам.'
lang['#Command_Event_Syntax'] = '<текст>'
lang['#Command_Eventlocal_Description'] = 'Описать какое-либо событие всем персонажам рядом с Вами.'
lang['#Command_Eventlocal_Syntax'] = '<текст>'
lang['#Command_Forcefallover_Description'] = 'Заставить персонажа упасть на пол.'
lang['#Command_Forcefallover_Syntax'] = '<имя> [число секунд]'
lang['#Command_Givecash_Description'] = 'Дать денег персонажу.'
lang['#Command_Givecash_Syntax'] = '<количество денег>'
lang['#Command_Invaction_Description'] = 'Использовать тот или иной предмет в своем инвентаре.'
lang['#Command_Invaction_Syntax'] = '<действие> <UniqueID> [ItemID]'
lang['#Command_It_Description'] = 'Описать безличное действие.'
lang['#Command_It_Syntax'] = '<текст>'
lang['#Command_Mapchange_Description'] = 'Изменить карту.'
lang['#Command_Mapchange_Syntax'] = '<название карты> [задержка]'
lang['#Command_Maprestart_Description'] = 'Перезапустить карту.'
lang['#Command_Maprestart_Syntax'] = '[задержка]'
lang['#Command_Me_Syntax'] = '<текст>'
lang['#Command_Ordershipment_Description'] = 'Приобрести торговый груз.'
lang['#Command_Ordershipment_Syntax'] = '<UniqueID>'
lang['#Command_Pluginload_Description'] = 'Включить плагин.'
lang['#Command_Pluginload_Syntax'] = '<название>'
lang['#Command_Pluginunload_Description'] = 'Отключить плагин.'
lang['#Command_Pluginunload_Syntax'] = '<название>'
lang['#Command_Plyban_Description'] = 'Заблокировать игрока.'
lang['#Command_Plyban_Syntax'] = '<имя|SteamID|IP адрес> <количество минут> [причина]'
lang['#Command_Plybring_Description'] = 'Телепортировать игрока туда, куда Вы смотрите.'
lang['#Command_Plybring_Syntax'] = '<имя> <bool без оповещения>'
lang['#Command_Plydemote_Description'] = 'Понизить игрока.'
lang['#Command_Plydemote_Syntax'] = '<имя>'
lang['#Command_Plygiveaccess_Description'] = 'Выдать игроку доступ к команде.'
lang['#Command_Plygiveaccess_Syntax'] = '<имя> <команда>'
lang['#Command_Plygiveflags_Description'] = 'Выдать флаги игроку.'
lang['#Command_Plygiveflags_Syntax'] = '<имя> <флаги>'
lang['#Command_Plygoto_Description'] = 'Телепортироваться к игроку.'
lang['#Command_Plygoto_Syntax'] = '<имя>'
lang['#Command_Plykick_Description'] = 'Отключить игрока от сервера.'
lang['#Command_Plykick_Syntax'] = '<имя> <причина>'
lang['#Command_Plymute_Description'] = 'Заблокировать игроку доступ к LOOC и ООС чатам.'
lang['#Command_Plymute_Syntax'] = '<имя> <число минут>'
lang['#Command_Plyrespawnstay_Description'] = 'Возродить игрока на месте смерти.'
lang['#Command_Plyrespawnstay_Syntax'] = '<имя>'
lang['#Command_Plyrespawntp_Description'] = 'Возродить игрока и телепортировать его к Вам.'
lang['#Command_Plyrespawntp_Syntax'] = '<имя> <bool без оповещения>'
lang['#Command_Plysearch_Description'] = 'Осмотреть инвентарь игрока.'
lang['#Command_Plysearch_Syntax'] = '<имя>'
lang['#Command_Plysetflags_Description'] = 'Установить флаги игрока.'
lang['#Command_Plysetflags_Syntax'] = '<имя> <флаги>'
lang['#Command_Plysetgroup_Description'] = 'Установить группу игрока.'
lang['#Command_Plysetgroup_Syntax'] = '<имя> <группа>'
lang['#Command_Plysethealth_Description'] = 'Установить HP игроку.'
lang['#Command_Plysethealth_Syntax'] = '<имя> <количество>'
lang['#Command_Plyslay_Description'] = 'Убить игрока.'
lang['#Command_Plyslay_Syntax'] = '<имя> <bool без оповещения>'
lang['#Command_Plytakeaccess_Description'] = 'Изъять у игрока доступ к команде.'
lang['#Command_Plytakeaccess_Syntax'] = '<имя> <команда>'
lang['#Command_Plytakeflags_Description'] = 'Изъять флаги у игрока.'
lang['#Command_Plytakeflags_Syntax'] = '<имя> <флаги>'
lang['#Command_Plytp_Description'] = 'Телепортировать игрока к Вам.'
lang['#Command_Plytp_Syntax'] = '<имя>'
lang['#Command_Plytpto_Description'] = 'Телепортировать игрока к другому игроку.'
lang['#Command_Plytpto_Syntax'] = '<имя телепортируемого> <имя цели> <bool без оповещения>'
lang['#Command_Plyunban_Description'] = 'Разблокировать определенный Steam ID.'
lang['#Command_Plyunban_Syntax'] = '<SteamID|IP Адрес>'
lang['#Command_Plyunwhitelist_Description'] = 'Удалить игрока из белого списка фракции.'
lang['#Command_Plyunwhitelist_Syntax'] = '<имя> <фракция>'
lang['#Command_Plyvoiceban_Description'] = 'Заблокировать голосовой чат игроку.'
lang['#Command_Plyvoiceban_Syntax'] = '<имя|SteamID|IP Адрес>'
lang['#Command_Plyvoiceunban_Description'] = 'Разблокировать голосовой чат игроку.'
lang['#Command_Plyvoiceunban_Syntax'] = '<имя|SteamID|IP Адрес>'
lang['#Command_Plywhitelist_Description'] = 'Добавить игрока в белый лист фракции.'
lang['#Command_Plywhitelist_Syntax'] = '<имя> <фракция>'
lang['#Command_Pm_Syntax'] = '<имя> <текст>'
lang['#Command_Radio_Syntax'] = '<текст>'
lang['#Command_Roll_Syntax'] = '[диапазон]'
lang['#Command_Setcash_Description'] = 'Установить деньги персонажа.'
lang['#Command_Setcash_Syntax'] = '<имя> <количество денег>'
lang['#Command_Setclass_Description'] = 'Установить класс персонажу.'
lang['#Command_Setclass_Syntax'] = '<имя> <класс>'
lang['#Command_Setvoicemail_Description'] = 'Установить голосовую почту.'
lang['#Command_Setvoicemail_Syntax'] = '[текст]'
lang['#Command_Storageclose_Description'] = 'Закрыть активный контейнер.'
lang['#Command_Storagegivecash_Description'] = 'Поместить деньги в контейнер.'
lang['#Command_Storagegivecash_Syntax'] = '<количество>'
lang['#Command_Storagegiveitem_Description'] = 'Поместить предмет в контейнер.'
lang['#Command_Storagegiveitem_Syntax'] = '<UniqueID> <ItemID>'
lang['#Command_Storagetakecash_Description'] = 'Забрать деньги из контейнера.'
lang['#Command_Storagetakecash_Syntax'] = '<количество>'
lang['#Command_Storagetakeitem_Description'] = 'Забрать предмет из контейнера.'
lang['#Command_Storagetakeitem_Syntax'] = '<uniqueID> <ItemID>'
lang['#Command_Su_Description'] = 'Отправить приватное сообщение суперадминистраторам.'
lang['#Command_Su_Syntax'] = '<текст сообщения>'
lang['#Command_W_Syntax'] = '<текст>'
lang['#Command_Y_Syntax'] = '<текст>'

-- Added: missing translations
lang['CashSetTarget'] = '#3 установил ваши #1 на #2.'
lang['CashSetPlayer'] = 'Вы установили #2 #1 на #3.'
lang['#SmoothServerRatesDesc'] = 'Использовать плавные серверные рейты Clockwork.'
lang['#MediumServerRatesDesc'] = 'Использовать рейты средней производительности Clockwork (полоски будут менее плавными).'
lang['#LagFreeServerRatesDesc'] = 'Использовать рейты максимальной производительности Clockwork (убирает все лаги, ломает полоски).'

-- Added: strings moved out of code
-- core-client: character creation
lang['#CharCreation_Attributes'] = 'Характеристики'

-- core-client: door menu
lang['#DoorMenu_ParentInfo'] = 'Родительская дверь является главной дверью в блоке помещений.'
lang['#DoorMenu_DoorText'] = 'Текст, отображаемый на двери.'
lang['#DoorMenu_ParentAccess'] = 'Какие настройки доступа родительской двери использовать.'
lang['#DoorMenu_ShareAccess'] = 'Общий доступ со всеми дочерними дверьми.'
lang['#DoorMenu_SeparateAccess'] = 'Раздельный доступ для дочерних дверей.'
lang['#DoorMenu_ParentText'] = 'Какие настройки текста родительской двери использовать.'
lang['#DoorMenu_ShareText'] = 'Общий текст со всеми дочерними дверьми.'
lang['#DoorMenu_SeparateText'] = 'Раздельный текст для дочерних дверей.'
lang['#DoorMenu_Sell'] = 'Продать'
lang['#DoorMenu_Unown'] = 'Отказаться от двери'
lang['#DoorMenu_SellQuery'] = 'Вы уверены, что хотите продать эту дверь?'
lang['#DoorMenu_SellTitle'] = 'Продать дверь.'
lang['#DoorMenu_UnownQuery'] = 'Вы уверены, что хотите отказаться от этой двери?'
lang['#DoorMenu_UnownTitle'] = 'Отказаться от двери.'
lang['#DoorMenu_Players'] = 'Игроки'
lang['#DoorMenu_PlayersTip'] = 'Настройте, кто имеет доступ к этой двери.'
lang['#DoorMenu_SettingsTip'] = 'Просмотр настроек этой двери.'
lang['#DoorMenu_TakeCompleteAccess'] = 'Забрать полный доступ.'
lang['#DoorMenu_TakeBasicAccess'] = 'Забрать базовый доступ.'
lang['#DoorMenu_GiveCompleteAccess'] = 'Выдать полный доступ.'
lang['#DoorMenu_GiveBasicAccess'] = 'Выдать базовый доступ.'
lang['#DoorMenu_CompleteAccessList'] = 'Персонажи с полным доступом.'
lang['#DoorMenu_BasicAccessList'] = 'Персонажи с базовым доступом.'
lang['#DoorMenu_NoAccessList'] = 'Персонажи без доступа.'
lang['#DoorMenu_PurchaseQuery'] = 'Вы хотите приобрести эту дверь за #1?'
lang['#DoorMenu_PurchaseTitle'] = 'Приобрести эту дверь.'
lang['#DoorMenu_OwnQuery'] = 'Вы хотите завладеть этой дверью?'
lang['#DoorMenu_OwnTitle'] = 'Завладеть этой дверью.'

-- core-client: system menu
lang['#SystemMenu_Navigation'] = 'Навигация'
lang['#SystemMenu_BackToNavigation'] = 'Назад к навигации'
lang['#SystemMenu_Info'] = 'Это меню предоставляет вам различные инструменты администрирования Clockwork.'
lang['#SystemMenu_Open'] = 'Открыть'
lang['#SystemMenu_OpenTip'] = 'Нажмите здесь, чтобы открыть эту панель.'
lang['#SystemMenu_NoAccessTip'] = 'У вас нет доступа к этой панели.'

-- core-client: scoreboard
lang['#Scoreboard_PlayersOnline'] = 'Игроков онлайн: #1 / #2'
lang['#Scoreboard_NoPlayers'] = 'Нет игроков для отображения.'
lang['#Scoreboard_SteamNameIs'] = 'Имя этого игрока:'
lang['#Scoreboard_SteamIDIs'] = 'Steam ID этого игрока:'
lang['#Scoreboard_Ping'] = 'Пинг этого игрока: #1.'

-- core-client: storage and inventory
lang['#Storage_TransferCash'] = 'Переместить'
lang['#Unit_Kilograms'] = 'кг'
lang['#Unit_Litres'] = 'л'

-- core-client: directory
lang['#DirectoryMenu_SelectCategory'] = 'Выберите категорию'
lang['#DirectoryMenu_SelectCategoryHelp'] = 'Некоторые категории могут быть доступны только пользователям с особыми привилегиями.'

-- core-client: entity menu, admin ESP, requests
lang['#EntityMenu_Title'] = 'ВЗАИМОДЕЙСТВИЕ'
lang['#AdminESPInfo_NoWeapon'] = '[Без оружия]'
lang['#AdminESPInfo_StaticEntLabel'] = 'Статичный объект'
lang['#AdminESPInfo_ItemLabel'] = 'Предмет'
lang['#AdminESPInfo_SalesmanLabel'] = 'Продавец'
lang['#DermaRequest_OK'] = 'ОК'

-- Gamemode hooks (hooks/cl_hooks.lua, hooks/sv_hooks.lua, hooks/sv_nethooks.lua)
lang['#Directory_ClockworkTip'] = 'Содержит разделы, посвященные фреймворку Clockwork.'
lang['#Directory_CommandsTip'] = 'Содержит список команд и их синтаксис.'
lang['#ProgressBarInfo_Default'] = 'Прогресс'
lang['#CharFault_QuizFailed'] = 'Вы допустили ошибки в тесте!'
lang['#CharFault_QuizNotCompleted'] = 'Вы не прошли тестирование!'
lang['#CharFault_CannotInteract'] = 'Вы не можете взаимодействовать с этим персонажем!'
lang['#Storage_Belongings'] = 'Вещи'
lang['#Storage_Shipment'] = 'Груз'
lang['#PropCost_Name'] = 'Объект'

-- core-libs-shcl: commands (libraries/sh_command.lua)
lang['#Command_Cooldown'] = 'Вы не сможете использовать эту команду еще #1 секунд.'
lang['#Command_NotValid'] = 'Такой команды или псевдонима не существует!'
lang['#Command_CannotUseYet'] = 'Вы пока не можете использовать команды!'
lang['#Command_NoSyntax'] = '<нет>'

-- core-libs-shcl: attributes (libraries/sh_attributes.lua)
lang['#Attribute_NotValid'] = 'Такого атрибута не существует!'
lang['#Attribute_MaximumReached'] = 'Вы достигли максимального значения атрибута!'

-- core-libs-shcl: chat box (libraries/cl_chatbox.lua)
lang['#Chatbox_AdminPrefix'] = '* [Админ-чат]'
lang['#Chatbox_UnknownPlayer'] = 'Неизвестный игрок'

-- core-libs-shcl: settings (libraries/cl_setting.lua)
lang['#MusicVolume'] = 'Громкость музыки'
lang['#MusicVolumeDesc'] = 'Громкость фоновой и боевой музыки.'
lang['#ShowStaticProps'] = 'Показывать статичные пропы'
lang['#ShowStaticPropsDesc'] = 'Показывать все статичные пропы на радаре.'

-- core-libs-shcl: items (libraries/sh_item.lua)
lang['#Item_NoDescription'] = 'Предмет без описания.'
lang['#Item_UnknownItem'] = 'Неизвестный предмет'

-- core-libs-shcl: config system (libraries/sh_config.lua)
lang['#ConfigNoHelp'] = 'Для этого параметра нет описания.'

-- core-libs-shcl: selector (libraries/sh_selector.lua)
lang['#Selector_Back'] = 'Назад'
lang['#Selector_Next'] = 'Далее'
lang['#Selector_Exit'] = 'Выход'

-- core-libs-shcl: date and time (libraries/sh_datetime.lua)
lang['#UnknownDay'] = 'Неизвестно'

-- core-libs-shcl: physical description (libraries/cl_player.lua)
lang['#PhysDesc_MatchesModel'] = 'Описание соответствует модели.'

-- core-libs-shcl: directory (libraries/cl_directory.lua, libraries/sh_plugin.lua)
lang['#Directory_Plugins'] = 'Плагины'
lang['#Directory_Flags'] = 'Флаги'
lang['#Directory_VoiceCommands'] = 'Голосовые команды'
lang['#Directory_PluginDevelopedBy'] = 'автор:'

-- core-libs-shcl: flags (libraries/sh_flag.lua)
lang['#Flag_SpawnVehicles_Details'] = 'Доступ к спавну транспорта.'
lang['#Flag_SpawnRagdolls_Details'] = 'Доступ к спавну рэгдоллов.'
lang['#Flag_SpawnChairs_Details'] = 'Доступ к спавну стульев.'
lang['#Flag_SpawnProps_Details'] = 'Доступ к спавну пропов.'
lang['#Flag_PhysicsGun_Details'] = 'Доступ к физгану.'
lang['#Flag_SpawnNPCs_Details'] = 'Доступ к спавну NPC.'
lang['#Flag_ToolGun_Details'] = 'Доступ к тулгану.'
lang['#Flag_GiveItem_Details'] = 'Доступ к выдаче предметов.'
lang['#Flag_DoorAccess_Details'] = 'Доступ к управлению всеми дверьми.'
lang['#Flag_VoiceAccess_Details'] = 'Доступ к голосовому чату.'

-- Server libraries: character faults (core/libraries/sv_player.lua)
lang['#CharFault_NoPhysDesc'] = 'Вы не ввели текст описания.'
lang['#CharFault_InvalidGender'] = 'Вы не выбрали пол или выбранный пол оказался недействительным.'
lang['#CharFault_NotWhitelisted'] = "У Вас нет вайтлиста фракции '#1'."
lang['#CharFault_FactionCharLimit'] = 'Вы не можете создать больше персонажей данной фракции.'
lang['#CharFault_CreationError'] = 'Ошибка создания персонажа!'
lang['#CharFault_NameOwned'] = 'У Вас уже имеется персонаж с именем'
lang['#CharFault_NameTaken'] = 'Уже существует персонаж с именем'
lang['#CharFault_Unknown'] = 'Неизвестная ошибка. Свяжитесь с администрацией.'
lang['#CharFault_CannotCreate'] = 'Вы не можете создать этого персонажа!'
lang['#CharFault_CannotDelete'] = 'Вы не можете удалить этого персонажа!'
lang['#CharFault_CannotDeleteActive'] = 'Вы не можете удалить персонажа, которого используете.'
lang['#CharFault_InvalidCharacter'] = 'Данный персонаж недействителен.'
lang['#CharFault_FactionFull'] = "Фракция '#1' переполнена (#2/#3)!"
lang['#CharFault_CannotSwitch'] = 'Вы не можете выбрать этого персонажа.'
lang['#CharFault_CannotUse'] = 'Вы не можете использовать этого персонажа.'
lang['#CharFault_AlreadyUsing'] = 'Вы уже используете этого персонажа.'
lang['#CharScreen_Banned'] = 'Этот персонаж заблокирован.'

-- Server libraries: cash hints (core/libraries/sv_player.lua)
lang['#CashHint_Gained'] = 'Ваш персонаж получил #1'
lang['#CashHint_Lost'] = 'Ваш персонаж потерял #1'
lang['#CashReason_DoorSale'] = 'продажа двери'

-- Server libraries: chat (core/libraries/sv_player.lua, core/libraries/sv_chatbox.lua)
lang['#Suffix_Radio'] = 'говорит по рации:'
lang['#Chat_Someone'] = 'Кто-то'
lang['#Chat_SlanderKick'] = 'Фреймворк Catwork кикнул #1 с сервера.'
lang['#Chat_NotValidCommand'] = 'Такой команды или псевдонима не существует!'
lang['#Chat_OOCWait'] = 'Вы не сможете говорить в OOC чат еще #1 секунд!'
lang['#Chat_LOOCWait'] = 'Вы не сможете говорить в LOOC чат еще #1 секунд!'

-- Server libraries: storage (core/libraries/sv_storage.lua)
lang['#Storage_Default'] = 'Хранилище'

-- core-server: commands, shared messages (core/commands)
lang['#Command_PlayerProtected'] = '#1 находится под защитой!'
lang['#Command_ThisPlayerProtected'] = 'Этот игрок находится под защитой!'
lang['#Command_CannotGiveAdminFlags'] = "Вы не можете выдавать флаги 'o', 'a' и 's'!"
lang['#Command_CannotTakeAdminFlags'] = "Вы не можете изымать флаги 'o', 'a' и 's'!"
lang['#Command_NotValidFaction'] = "Фракции '#1' не существует!"
lang['#Command_NotValidCommandOrAlias'] = "Команды '#1' не существует!"
lang['#Command_MustEnterPermission'] = 'Вы должны указать название команды!'
lang['#Command_Whitelist_NoWhitelist'] = 'У фракции #1 нет белого списка!'

-- core-server: commands (core/commands)
lang['#Command_Arequest_From'] = 'Запрос от #1:'
lang['#Command_Charban_Banned'] = "#1 заблокировал персонажа '#2'."
lang['#Command_Charunban_Unbanned'] = "#1 разблокировал персонажа '#2'."
lang['#Command_Charcheckatts_Header'] = 'Навыки #1:'
lang['#Command_Charcheckflags_Result'] = 'Флаги этого персонажа: #1'
lang['#Command_Chargiveflags_Gave'] = "#1 выдал флаги '#3' персонажу #2."
lang['#Command_Charsetflags_Set'] = "#1 установил персонажу #2 флаги '#3'."
lang['#Command_Chartakeflags_Took'] = "#1 изъял флаги '#3' у персонажа #2."
lang['#Command_Chargiveitem_Gave'] = 'Вы выдали #1 #2.'
lang['#Command_Chargiveitem_GaveAmount'] = 'Вы выдали #1 #2 х #3.'
lang['#Command_Chargiveitem_Received'] = '#1 выдал Вам #2.'
lang['#Command_Chargiveitem_ReceivedAmount'] = '#1 выдал Вам #2 х #3.'
lang['#Command_Chargiveitem_AmountRange'] = 'Вы должны ввести число в диапазоне 1-10!'
lang['#Command_Charphysdesc_RequestTitle'] = 'Изменение физического описания'
lang['#Command_Charphysdesc_RequestText'] = 'На что Вы хотите изменить свое физическое описание?'
lang['#Command_Charsetdesc_RequestText'] = 'На что Вы хотите изменить физическое описание этого игрока?'
lang['#Command_Charsetdesc_Changed'] = 'Физическое описание персонажа #1 изменено на:'
lang['#Command_Charsetmodel_Set'] = '#1 установил персонажу #2 модель #3.'
lang['#Command_Charsetname_Set'] = '#1 изменил имя персонажа #2 на #3.'
lang['#Command_Chartie_NotSupported'] = 'Эта схема не поддерживает связывание.'
lang['#Command_Chartie_Untied'] = 'Вы развязали #1.'
lang['#Command_Chartie_UntiedBy'] = '#1 развязал Вас.'
lang['#Command_Chartie_Tied'] = 'Вы связали #1.'
lang['#Command_Chartie_TiedBy'] = '#1 связал Вас.'
lang['#Command_Chartransfer_AlreadyFaction'] = '#1 уже состоит во фракции #2!'
lang['#Command_Chartransfer_WrongGender'] = 'Пол персонажа #1 не подходит для фракции #2!'
lang['#Command_Chartransfer_CannotTransfer'] = '#1 не может быть перемещен во фракцию #2!'
lang['#Command_Chartransfer_Transferred'] = '#1 переместил персонажа #2 во фракцию #3.'
lang['#Command_Dropcash_Tip'] = 'Выбросить деньги перед собой.'
lang['#Command_Dropcash_Reason'] = 'выбрасывание денег'
lang['#Command_Dropcash_TooFar'] = 'Вы не можете выбросить деньги так далеко!'
lang['#Command_Dropweapon_NotValidWeapon'] = 'Это оружие недействительно!'
lang['#Command_Dropweapon_TooFar'] = 'Вы не можете выбросить оружие так далеко!'
lang['#Command_Givecash_Gave'] = 'Вы передали #2 персонажу #1.'
lang['#Command_Givecash_Received'] = '#1 передал Вам #2.'
lang['#Command_Givecash_TooFar'] = 'Этот персонаж слишком далеко!'
lang['#Command_Givecash_MustLook'] = 'Вы должны смотреть на персонажа!'
lang['#Command_Invaction_NoVehicle'] = 'Вы не можете использовать этот предмет в транспорте!'
lang['#Command_Mapchange_Changing'] = '#1 сменит карту на #2 через #3 сек.!'
lang['#Command_Maprestart_Restarting'] = '#1 перезапустит карту через #2 сек.!'
lang['#Command_Plyban_Hours'] = "#1 заблокировал '#2' на #3 ч. Причина:"
lang['#Command_Plyban_Minutes'] = "#1 заблокировал '#2' на #3 мин. Причина:"
lang['#Command_Plyban_Permanent'] = "#1 заблокировал '#2' навсегда. Причина:"
lang['#Command_Plyban_InvalidIdentifier'] = 'Это недействительный идентификатор!'
lang['#Command_Plyban_InvalidDuration'] = 'Это недействительная длительность!'
lang['#Command_Plybring_Brought'] = '#1 телепортировал игрока #2 в указанное им место.'
lang['#Command_Plydemote_Demoted'] = '#1 понизил игрока #2 с #3 до user.'
lang['#Command_Plydemote_OnlyUser'] = 'Этот игрок - обычный пользователь и не может быть понижен!'
lang['#Command_Plygiveaccess_Granted'] = 'Вы выдали игроку #1 доступ к команде #2.'
lang['#Command_Plygiveaccess_GrantedTarget'] = '#1 выдал Вам доступ к команде #2.'
lang['#Command_Plytakeaccess_Removed'] = 'Вы изъяли у игрока #1 доступ к команде #2.'
lang['#Command_Plytakeaccess_RemovedTarget'] = '#1 изъял у Вас доступ к команде #2.'
lang['#Command_Plygiveflags_Gave'] = "#1 выдал флаги '#3' игроку #2."
lang['#Command_Plysetflags_Set'] = "#1 установил игроку #2 флаги '#3'."
lang['#Command_Plytakeflags_Took'] = "#1 изъял флаги '#3' у игрока #2."
lang['#Command_Plygoto_Gone'] = '#1 телепортировался к игроку #2.'
lang['#Command_Plykick_Kicked'] = "#1 отключил игрока '#2' от сервера. Причина:"
lang['#Command_Plymute_Muted'] = "#1 заблокировал игроку '#2' доступ к OOC чату на #3 мин."
lang['#Command_Plyrespawnstay_Respawned'] = '#1 возрожден на месте смерти.'
lang['#Command_Plyrespawntp_Respawned'] = '#1 возрожден и телепортирован в указанное Вами место.'
lang['#Command_Plysearch_AlreadySearching'] = 'Вы уже осматриваете инвентарь другого персонажа!'
lang['#Command_Plysearch_BeingSearched'] = 'Инвентарь персонажа #1 уже осматривают!'
lang['#Command_Plysetgroup_InvalidGroup'] = 'Группа должна быть superadmin, admin или operator!'
lang['#Command_Plysetgroup_Set'] = '#1 установил игроку #2 группу #3.'
lang['#Command_Plysethealth_Set'] = 'Здоровье игрока #1 установлено на #2.'
lang['#Command_Plysethealth_SetTarget'] = '#2 установил Ваше здоровье на #1.'
lang['#Command_Plyslay_Slain'] = '#1 был убит игроком #2.'
lang['#Command_Plytp_Teleported'] = '#1 телепортировал игрока #2 в указанное им место.'
lang['#Command_Plytpto_Teleported'] = '#1 телепортировал игрока #2 к игроку #3.'
lang['#Command_Plyunban_Unbanned'] = "#1 разблокировал '#2'."
lang['#Command_Plyunban_NotFound'] = "Нет заблокированных игроков с идентификатором '#1'!"
lang['#Command_Plyunwhitelist_Removed'] = '#1 удалил игрока #2 из белого списка фракции #3.'
lang['#Command_Plyunwhitelist_NotOnWhitelist'] = '#1 отсутствует в белом списке фракции #2!'
lang['#Command_Plywhitelist_Added'] = '#1 добавил игрока #2 в белый список фракции #3.'
lang['#Command_Plywhitelist_AlreadyOn'] = '#1 уже находится в белом списке фракции #2!'
lang['#Command_Plyvoiceban_AlreadyBanned'] = 'Голосовой чат игрока #1 уже заблокирован!'
lang['#Command_Plyvoiceunban_NotBanned'] = 'Голосовой чат игрока #1 не заблокирован!'
lang['#Command_Su_Prefix'] = '* [Суперадминистраторы]'
lang['#CashSet_Cash'] = 'деньги'

-- core-server: config changes (core/commands/sh_cfgsetvar.lua, core/system/sh_manage_config.lua)
lang['#Config_ValueSet'] = '#1 установил значение конфигурации #2:'
lang['#Config_ValueSetRestart'] = '#1 установил значение конфигурации #2 (вступит в силу после перезапуска):'

-- core-server: plugin loading (core/commands/sh_pluginload.lua, sh_pluginunload.lua, core/system/sh_manage_plugins.lua)
lang['#PluginManage_NotValid'] = 'Этот плагин недействителен!'
lang['#PluginManage_Loaded'] = '#1 включил плагин #2 (вступит в силу после перезапуска).'
lang['#PluginManage_Unloaded'] = '#1 отключил плагин #2 (вступит в силу после перезапуска).'
lang['#PluginManage_CouldNotLoad'] = 'Не удалось включить этот плагин!'
lang['#PluginManage_CouldNotUnload'] = 'Не удалось отключить этот плагин!'
lang['#PluginManage_Depends'] = 'Этот плагин зависит от другого плагина!'

-- core-server: server console commands (core/sv_kernel.lua)
lang['#Console_SetGroup'] = 'Консоль установила игроку #1 группу #2.'
lang['#Console_Demoted'] = 'Консоль понизила игрока #1 с #2 до user.'
lang['#Console_SetCash'] = 'Консоль установила Ваши деньги на #1.'
lang['#Console_WhitelistAdded'] = 'Консоль добавила игрока #1 в белый список фракции #2.'
lang['#Console_WhitelistRemoved'] = 'Консоль удалила игрока #1 из белого списка фракции #2.'
lang['#Console_BannedHours'] = "Консоль заблокировала '#1' на #2 ч. Причина:"
lang['#Console_BannedMinutes'] = "Консоль заблокировала '#1' на #2 мин. Причина:"
lang['#Console_BannedPermanently'] = "Консоль заблокировала '#1' навсегда. Причина:"
lang['#Console_Kicked'] = "Консоль отключила игрока '#1' от сервера. Причина:"
lang['#Console_SetName'] = 'Консоль изменила имя персонажа #1 на #2.'
lang['#Console_SetModel'] = 'Консоль установила персонажу #1 модель #2.'
lang['#Console_MapRestart'] = 'Консоль перезапустит карту через #1 сек.!'
lang['#Console_GaveFlags'] = "Консоль выдала флаги '#2' персонажу #1."
lang['#Console_TookFlags'] = "Консоль изъяла флаги '#2' у персонажа #1."
lang['#Console_NotAllowed'] = 'Вам запрещено использовать серверные команды!'

-- core-server: config names and descriptions (core/config/cl_config.lua)
lang['#LOOCChatInterval'] = 'Интервал сообщений в LOOC чате'
lang['#LOOCChatIntervalDesc'] = 'Промежуток времени между сообщениями в чат LOOC.'
lang['#EnableMouthMove'] = 'Анимация рта при разговоре'
lang['#EnableMouthMoveDesc'] = 'Включить анимацию рта при разговоре. Включите, если на сервере разрешен голосовой чат, иначе отключите.'
lang['#BlockCashBinds'] = 'Блокировка биндов денежных команд'
lang['#BlockCashBindsDesc'] = 'Заблокировать бинды денежных команд.'
lang['#BlockFalloverBinds'] = 'Блокировка биндов падения'
lang['#BlockFalloverBindsDesc'] = 'Заблокировать бинды команды CharFallOver.'

-- core-server: base items (core/items)
lang['Accessories'] = 'Аксессуары'
lang['#Item_AccessoryBase_Description'] = 'Аксессуар, который можно надеть.'
lang['#Item_ClothesBase_Description'] = 'Чемодан, полный одежды.'
lang['#Item_ContainerBase_Description'] = 'Простой контейнер для хранения других предметов.'
lang['#Item_WeaponBase_Broken'] = '[Catwork:Error] Это оружие сломано! Свяжитесь с разработчиками.'

-- core-server: entities (core/entities)
lang['#Belongings_TargetHint'] = 'Возможно, внутри что-то есть.'

-- core-server: system menu, shared (core/system)
lang['#System_Enabled'] = 'Включено'
lang['#System_Page'] = 'Страница #1/#2'
lang['#System_Next'] = 'Далее'
lang['#System_Back'] = 'Назад'

-- core-server: system menu, manage players (core/system/cl_manage_players.lua)
lang['#System_ManagePlayers_ToolTip'] = 'Набор полезных команд для управления игроками.'
lang['#System_ManagePlayers_Info'] = 'Нажмите на игрока, чтобы открыть список доступных команд.'

-- core-server: system menu, color modify (core/system/sh_color_modify.lua)
lang['#System_ColorModify_ToolTip'] = 'Настройка глобальной цветокоррекции схемы.'
lang['#System_ColorModify_Info'] = 'Изменение этих значений повлияет на цвета у всех игроков.'
lang['#System_ColorModify_Warning'] = 'Обратите внимание: эти настройки предназначены только для опытных пользователей.'
lang['#System_ColorModify_Brightness'] = 'Яркость'
lang['#System_ColorModify_Contrast'] = 'Контрастность'
lang['#System_ColorModify_Color'] = 'Цвет'
lang['#System_ColorModify_AddRed'] = 'Добавить красный'
lang['#System_ColorModify_AddGreen'] = 'Добавить зеленый'
lang['#System_ColorModify_AddBlue'] = 'Добавить синий'
lang['#System_ColorModify_MulRed'] = 'Умножить красный'
lang['#System_ColorModify_MulGreen'] = 'Умножить зеленый'
lang['#System_ColorModify_MulBlue'] = 'Умножить синий'

-- core-server: system menu, manage bans (core/system/sh_manage_bans.lua)
lang['#System_ManageBans_ToolTip'] = 'Графический способ разблокировки игроков.'
lang['#System_ManageBans_Permanent'] = 'Этот игрок заблокирован навсегда.'
lang['#System_ManageBans_UnbannedHours'] = 'Будет разблокирован через #1 ч.'
lang['#System_ManageBans_UnbannedMinutes'] = 'Будет разблокирован через #1 мин.'
lang['#System_ManageBans_UnbannedSeconds'] = 'Будет разблокирован через #1 сек.'
lang['#System_ManageBans_Reason'] = 'Причина блокировки:'
lang['#System_ManageBans_UnbanConfirm'] = 'Вы уверены, что хотите разблокировать этого игрока?'
lang['#System_ManageBans_Empty'] = 'Нет заблокированных игроков.'
lang['#System_ManageBans_Loading'] = 'Подождите, идет получение списка заблокированных игроков...'

-- core-server: system menu, manage config (core/system/sh_manage_config.lua)
lang['#System_ManageConfig_ToolTip'] = 'Удобный способ редактирования конфигурации Clockwork.'
lang['#System_ManageConfig_Info'] = 'Нажмите на ключ конфигурации, чтобы начать редактирование его значения.'
lang['#System_ManageConfig_InfoEditing'] = 'Теперь Вы можете изменить значение или выбрать другой ключ конфигурации.'
lang['#System_ManageConfig_Config'] = 'Конфигурация'
lang['#System_ManageConfig_Name'] = 'Название'
lang['#System_ManageConfig_Key'] = 'Ключ'
lang['#System_ManageConfig_AddedBy'] = 'Добавлено'
lang['#System_ManageConfig_Map'] = 'Карта'
lang['#System_ManageConfig_Value'] = 'Значение'
lang['#System_ManageConfig_Okay'] = 'ОК'
lang['#System_ManageConfig_On'] = 'Вкл.'

-- core-server: system menu, manage groups (core/system/sh_manage_groups.lua)
lang['#System_ManageGroups_ToolTip'] = 'Управление всеми административными группами.'
lang['#System_ManageGroups_Info'] = 'Выберите группу, чтобы открыть список ее пользователей.'
lang['#System_ManageGroups_UserGroups'] = 'Группы пользователей'
lang['#System_ManageGroups_SuperAdmins'] = 'Суперадминистраторы'
lang['#System_ManageGroups_Administrators'] = 'Администраторы'
lang['#System_ManageGroups_Operators'] = 'Операторы'
lang['#System_ManageGroups_GroupTip'] = "Управление пользователями группы '#1'."
lang['#System_ManageGroups_Back'] = 'Назад к группам пользователей'
lang['#System_ManageGroups_DemoteConfirm'] = 'Вы уверены, что хотите понизить этого игрока?'
lang['#System_ManageGroups_Empty'] = 'В этой группе нет пользователей.'
lang['#System_ManageGroups_Loading'] = 'Подождите, идет получение списка пользователей группы...'

-- core-server: system menu, manage plugins (core/system/sh_manage_plugins.lua)
lang['#System_ManagePlugins_ToolTip'] = 'Здесь можно включать и отключать плагины.'
lang['#System_ManagePlugins_Info'] = 'Красные плагины отключены, зеленые включены, а оранжевые недоступны.'
lang['#System_ManagePlugins_Empty'] = 'На сервере не установлено ни одного плагина.'

-- Weapon selector plugin
lang['#WeaponSelect_UnknownWeapon'] = 'Неизвестное оружие'

-- Directory (used by framework code)
lang['#Directory_Commands'] = 'Команды'
