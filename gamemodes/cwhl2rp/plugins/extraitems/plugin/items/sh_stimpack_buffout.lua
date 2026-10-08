--- Defines the `Buffout` stimpack item (`stimpack_buffout`), an injection that clears fatigue and boosts strength by
-- 100 for 600 seconds, together with its English and Russian strings.

ITEM.name = 'Buffout'
ITEM.PrintName = '#ITEM_Buff'
ITEM.cost = 250
ITEM.model = 'models/props_c17/trappropeller_lever.mdl'
ITEM.weight = 0.2
ITEM.access = 'V'
ITEM.useText = '#ITEM_Adrenaline_UseText'
ITEM.business = true
ITEM.category = '#ITEM_Category_Stimpacks'
ITEM.uniqueID = 'stimpack_buffout'
ITEM.description = '#ITEM_Buff_Desc'

--- Clears fatigue and boosts strength by 100 for 600 seconds.
function ITEM:OnUse(player, itemEntity)
  player:SetCharacterData('Fatigue', 0)
  player:BoostAttribute(self.name, ATB_STRENGTH, 100, 600)

  cw.player:Notify(player, '#ITEM_Buff_Effect')
end

--- Lets the item be dropped without any extra effect.
function ITEM:OnDrop(player, position) end

local eng = cw.lang:GetTable('en')
local ru = cw.lang:GetTable('ru')

eng['#ITEM_Buff'] = 'Buff'
eng['#ITEM_Buff_Desc'] = "A syringe filled with dark red liquid. It's labeled as 'Buff'."
eng['#ITEM_Buff_Effect'] = 'You feel your muscles tense and get stronger.'

ru['#ITEM_Buff'] = 'Бафф'
ru['#ITEM_Buff_Desc'] = 'Шприц, наполненный тёмно-красной жидкостью. На нем приклеена картинка мускулистой руки.'
ru['#ITEM_Buff_Effect'] = 'Вы чувствуете, что ваши мышцы сильно напряглись и стали сильнее.'
