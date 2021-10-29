ITEM.name = "Медицинский фонарик"
ITEM.cost = 50
ITEM.model = "models/lagmite/lagmite.mdl"
ITEM.weight = 0.2
ITEM.access = "q"
ITEM.useText = "Применить"
ITEM.category = "Медицина"
ITEM.business = true;
ITEM.description = "Маленький фонарик для проверки глаз."

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	local lookingPly = player:GetEyeTrace().Entity

	if (lookingPly:IsPlayer()) then
		if (lookingPly:GetCharacterData("diseases") == "blindness") then
			cw.player:Notify(player, "Глаза человека едва реагируют на свет.")
		elseif (lookingPly:GetCharacterData("diseases") == "colorblindness") then
			cw.player:Notify(player, "Глаза гражданина не реагируют на цветной свет.")
		else
			cw.player:Notify(player, "Глаза человека хорошо реагируют на свет.")
		end

		return false
	else
		cw.player:Notify(player, "Вы должны смотреть на человека!")

		return false
	end
end

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end