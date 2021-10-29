ITEM.name = "Рацион специальной диеты"
ITEM.uniqueID = "special_ration"
ITEM.cost = 0
ITEM.model = "models/gibs/shield_scanner_gib2.mdl"
ITEM.weight = 0.2
ITEM.access = "q"
ITEM.useText = "Употребить"
ITEM.category = "Медицина"
ITEM.business = true
ITEM.description = "Пища, которую прописывают больным гастритом."
ITEM.hunger = 40
ITEM.customFunctions = {"Дать"}

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	if (player:GetCharacterData("diseases") == "gastrits") then
		player:SetCharacterData("diseases", "none")
	end

	player:SetHealth(math.Clamp(player:Health() + Schema:GetHealAmount(player, 1.5), 0, player:GetMaxHealth()))

	hook.Run("PlayerHealed", player, player, self)
end;

if (SERVER) then
	function ITEM:OnCustomFunction(player, name)
		if (name == "Дать") then
			local lookingPly = player:GetEyeTrace().Entity

			if (lookingPly:IsPlayer()) then
				if (lookingPly:GetCharacterData("diseases") == "gastrits") then
					lookingPly:SetCharacterData("diseases", "none")
				end

				cw.player:Notify(player, "Вы покормили персонажа.")
				player:TakeItem(player:FindItemByID("special_ration"))
				lookingPly:SetHealth(math.Clamp(player:Health() + Schema:GetHealAmount(player, 1.5), 0, player:GetMaxHealth()))

				hook.Run("PlayerHealed", lookingPly, player, self)
			else
				cw.player:Notify(player, "Вы должны смотреть на человека!")

				return false
			end
		end
	end
end

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end