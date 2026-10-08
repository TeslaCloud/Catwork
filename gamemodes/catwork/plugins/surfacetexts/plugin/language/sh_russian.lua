--- Russian language strings for the Surface Texts plugin: its `texts` tool, its notifications and the descriptions of
-- `/TextAdd` and `/TextRemove`.
--
-- Backported from the [Flux](https://github.com/TeslaCloud/flux-ce) project.

local lang = cw.lang:GetTable('ru')

lang['#tool.texts.name'] = 'Редактор Текстов'
lang['#tool.texts.desc'] = 'Добавляет 3D тексты на поверхности.'
lang['#tool.texts.0'] = 'ЛКМ: Добавить текст. ПКМ: Удалить текст.'
lang['#tool.texts.text'] = 'Текст'
lang['#tool.texts.style'] = 'Стиль'
lang['#tool.texts.color'] = 'Цвет'
lang['#tool.texts.extraColor'] = 'Доп. Цвет'
lang['#tool.texts.scale'] = 'Размер Текста'
lang['#tool.texts.fade'] = 'Дистанция Отрисовки'
lang['#tool.texts.opt1'] = 'Обычный Текст'
lang['#tool.texts.opt2'] = 'Текст с Дальней Тенью'
lang['#tool.texts.opt3'] = 'Текст с Черной Тенью'
lang['#tool.texts.opt4'] = 'Текст с Двумя Тенями'
lang['#tool.texts.opt5'] = 'Текст в Табличке'
lang['#tool.texts.opt6'] = 'Текст в Мигающей Табличке'

lang['#tool.texts.choose'] = 'Выберите стиль'
lang['#SurfaceTexts_Added'] = 'Вы добавили 3D текст.'
lang['#SurfaceTexts_Removed'] = 'Вы удалили 3D текст.'
lang['#Command_Textadd_Description'] = 'Добавить текст на поверхность.'
lang['#Command_Textadd_Syntax'] = '<текст> [размер] [стиль] [цвет] [доп. цвет]'
lang['#Command_Textremove_Description'] = 'Удалить текст с поверхности.'
