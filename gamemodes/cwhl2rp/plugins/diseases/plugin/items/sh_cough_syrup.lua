ITEM.name = "Сироп от кашля"
ITEM.uniqueID = "cough_syrup"
ITEM.cost = 25
ITEM.model = "models/props_junk/glassjug01.mdl"
ITEM.weight = 0.2
ITEM.access = "q"
ITEM.useText = "Выпить"
ITEM.category = "Медицина"
ITEM.business = true;
ITEM.description = "Стеклянный пузырек с коричневой субстанцией внутри."
ITEM.customFunctions = {"Дать"}

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	if (player:GetCharacterData("diseases") == "cough") then
		player:SetCharacterData("diseases", "none")
	end
end;

if (SERVER) then
	function ITEM:OnCustomFunction(player, name)
		if (name == "Дать") then
			local lookingPly = player:GetEyeTrace().Entity

			if (lookingPly:IsPlayer()) then
				if (lookingPly:GetCharacterData("diseases") == "cough") then
					lookingPly:SetCharacterData("diseases", "none")
				end

				cw.player:Notify(player, "Вы дали персонажу сироп от кашля.")
				player:TakeItem(player:FindItemByID("cough_syrup"))
			else
				cw.player:Notify(player, "Вы должны смотреть на человека!");

				return false
			end
		end
	end
end

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end