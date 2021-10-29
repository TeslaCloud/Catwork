ITEM.name = "Парацетамол"
ITEM.uniqueID = "paracetamol"
ITEM.cost = 25
ITEM.model = "models/props_junk/garbage_metalcan001a.mdl"
ITEM.weight = 0.2
ITEM.access = "q"
ITEM.useText = "Употребить"
ITEM.category = "Медицина"
ITEM.business = true
ITEM.description = "Баночка с несколькими таблетками для лечения простуды."
ITEM.customFunctions = {"Дать"}

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	if (player:GetCharacterData("diseases") == "fever") then
		player:SetCharacterData("diseases", "none")
	end
end

if (SERVER) then
	function ITEM:OnCustomFunction(player, name)
		if (name == "Дать") then
			local lookingPly = player:GetEyeTrace().Entity

			if (lookingPly:IsPlayer()) then
				if (lookingPly:GetCharacterData("diseases") == "fever") then
					lookingPly:SetCharacterData("diseases", "none")
				end

				cw.player:Notify(player, "Вы дали персонажу парацетамол.")
				player:TakeItem(player:FindItemByID("paracetamol"))
			else
				cw.player:Notify(player, "Вы должны смотреть на человека!")

				return false
			end
		end
	end
end

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end