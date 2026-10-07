ITEM.name = "Pack of Sorbents"
ITEM.PrintName = "#Item_Sorbent_PrintName"
ITEM.uniqueID = "sorbent"
ITEM.cost = 0
ITEM.model = "models/props_junk/garbage_bag001a.mdl"
ITEM.weight = 0.2
ITEM.access = "q"
ITEM.useText = "Swallow"
ITEM.category = "Medical"
ITEM.business = true
ITEM.description = "#Item_Sorbent_Description"
ITEM.customFunctions = { "Give" }

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	if (player:GetCharacterData("diseases") == "diarrhea") then
		player:SetCharacterData("diseases", "none")
	end

	player:SetHealth(math.Clamp(player:Health() + Schema:GetHealAmount(player, 1.5), 0, player:GetMaxHealth()))

	hook.Run("PlayerHealed", player, player, self)
end

if (SERVER) then
	function ITEM:OnCustomFunction(player, name)
		if (name == "Give") then
			local lookingPly = player:GetEyeTrace().Entity

			if (lookingPly:IsPlayer()) then
				if (lookingPly:GetCharacterData("diseases") == "diarrhea") then
					lookingPly:SetCharacterData("diseases", "none")
				end

				cw.player:Notify(player, L("Diseases_Gave_Sorbent"))
				player:TakeItem(player:FindItemByID("sorbent"))
				lookingPly:SetHealth(math.Clamp(player:Health() + Schema:GetHealAmount(player, 1.5), 0, player:GetMaxHealth()))

				hook.Run("PlayerHealed", lookingPly, player, self)
			else
				cw.player:Notify(player, L("Diseases_MustLookAtPerson"))

				return false
			end
		end
	end
end

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end
