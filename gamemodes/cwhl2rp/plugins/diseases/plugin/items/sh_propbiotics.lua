ITEM.name = "Пачка пробиотиков"
ITEM.uniqueID = "probiotics"
ITEM.cost = 25
ITEM.model = "models/props_pipes/pipe01_connector01.mdl"
ITEM.weight = 0.2
ITEM.access = "q"
ITEM.useText = "Употребить"
ITEM.category = "Медицина"
ITEM.business = true
ITEM.description = "Коробочка с надписью 'Бификол' и припиской 'Пробиотики'."
ITEM.customFunctions = {"Дать"}

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	if (player:GetCharacterData("diseases") == "diarrhea") then
		player:SetCharacterData("diseases", "none")
	end

	hook.Run("PlayerHealed", player, player, self)
end

if (SERVER) then
	function ITEM:OnCustomFunction(player, name)
		if (name == "Дать") then
			local lookingPly = player:GetEyeTrace().Entity
			if (lookingPly:IsPlayer()) then
				if (lookingPly:GetCharacterData("diseases") == "diarrhea") then
					lookingPly:SetCharacterData("diseases", "none")
				end

				cw.player:Notify(player, "Вы дали персонажу пробиотики.")
				player:TakeItem(player:FindItemByID("probiotics"))

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