
ITEM.name = "Руководство по использованию ПДБ"
ITEM.uniqueID = "pdb_book"
ITEM.cost = 0
ITEM.model = "models/props_lab/binderredlabel.mdl"
ITEM.useText = "Прочитать"
ITEM.category = "Literature"
ITEM.useSound = false
ITEM.weight = 0.5
ITEM.business = true
ITEM.description = "Довольно потрёпанного вида книга красного цвета."

function ITEM:OnUse(player, itemEntity)
	local atrs = player:GetAttributes()
	local medical = atrs[ATB_MEDICAL]
	if player:GetFaction() != FACTION_OTA then
		if medical then
			if tonumber(medical.amount) < 50 then
				player:UpdateAttribute(ATB_MEDICAL, 50 - tonumber(medical.amount))
				cw.player:Notify(player, "Прочитав книгу, вы повысили свои навыки в медицине.")
			else
				cw.player:Notify(player, "Вы уже знакомы с содержимым этой книги.")
			end
		end
	end
	return false
end
function ITEM:OnDrop(player, position) end

