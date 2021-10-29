ITEM.name = "Ингалятор"
ITEM.uniqueID = "ingall"
ITEM.cost = 0
ITEM.model = "models/props_combine/breenlight.mdl"
ITEM.weight = 0.2
ITEM.access = "q"
ITEM.useText = "Использовать"
ITEM.category = "Медицина"
ITEM.business = true
ITEM.description = "Небольшой приборчик, который нужно вставить в рот."
ITEM.customFunctions = {"Использовать на..."}

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	if (player:GetCharacterData("diseases") == "pneumonia") then
		timer.Simple(math.random(60, 120), function()
			player:SetCharacterData("diseases", "none")
		end)	
	end

	hook.Run("PlayerHealed", player, player, self)
end

if (SERVER) then
	function ITEM:OnCustomFunction(player, name)
		if (name == "Дать") then
			local lookingPly = player:GetEyeTrace().Entity

			if (lookingPly:IsPlayer()) then
				if (lookingPly:GetCharacterData("diseases") == "pneumonia") then
					timer.Simple(math.random(60, 120), function()
						lookingPly:SetCharacterData("diseases", "none")
					end)
				end

				player:EmitSound("ambient/voices/cough1.wav", 100, 100)
				cw.player:Notify(player, "Вы применили ингаллятор на персонажа.")
				player:TakeItem(player:FindItemByID("ingall"))

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