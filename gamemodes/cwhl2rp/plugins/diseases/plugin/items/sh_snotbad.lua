ITEM.name = "Снотворное (Не по рецепту)"
ITEM.uniqueID = "snotbad"
ITEM.cost = 0
ITEM.model = "models/props_lab/jar01a.mdl"
ITEM.weight = 0.2
ITEM.access = "q"
ITEM.useText = "Употребить"
ITEM.category = "Медицина"
ITEM.business = true
ITEM.description = "Коробочка, на которой написано 'Снотворное' обычной шариковой ручкой."
ITEM.customFunctions = {"Дать"}

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	if player:GetCharacterData("diseases") == "insomnia" then
		player:SetCharacterData("diseases", "none")

		timer.Simple(360, function()
			if (math.random(1, 2) == 1) then
				player:SetCharacterData("diseases", "insomnia")
			end
		end)
	end

	player:SetCharacterData("Fatigue", 100)

	hook.Run("PlayerHealed", player, player, self)
end

if (SERVER) then
	function ITEM:OnCustomFunction(player, name)
		if (name == "Дать") then
			local lookingPly = player:GetEyeTrace().Entity

			if (lookingPly:IsPlayer()) then
				if (lookingPly:GetCharacterData("diseases") == "insomnia") then
					lookingPly:SetCharacterData("diseases", "none")

					timer.Simple(360, function()
						if (math.random(1, 2) == 1) then
							lookingPly:SetCharacterData("diseases", "insomnia")
						end
					end)
				end

				lookingPly:SetCharacterData("Fatigue", 100)
				cw.player:Notify(player, "Вы дали персонажу снотворное.")
				player:TakeItem(player:FindItemByID("snotbad"))

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