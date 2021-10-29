ITEM.name = "Глазной хирургический набор"
ITEM.cost = 150
ITEM.model = "models/Items/BoxMRounds.mdl"
ITEM.weight = 0.2
ITEM.access = "Q"
ITEM.useText = "Применить"
ITEM.category = "Медицина"
ITEM.business = true
ITEM.description = "Набор, в который входит все необходимое для проведения операции на глазу."

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	local lookingPly = player:GetEyeTrace().Entity

	if (lookingPly:IsPlayer()) then
		if (lookingPly:GetCharacterData("diseases") == "blindness") then
			cw.player:Notify(player, "Вы использовали комплект для лечения слепоты.")
			lookingPly:SetCharacterData("diseases", "none")
		elseif (lookingPly:GetCharacterData("diseases") == "colorblindness") then
			cw.player:Notify(player, "Вы использовали комплект для лечения дальтонизма.")
			lookingPly:SetCharacterData("diseases", "none")
		else
			cw.player:Notify(player, "Вы просто так использовали комплект для лечения проблем со зрением.")
		end
	else
		cw.player:Notify(player, "Вы должны смотреть на пациента!")

		return false
	end
end

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end