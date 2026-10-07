ITEM.name = "Cough Syrup"
ITEM.PrintName = "#Item_CoughSyrup_PrintName"
ITEM.uniqueID = "cough_syrup"
ITEM.cost = 25
ITEM.model = "models/props_junk/glassjug01.mdl"
ITEM.weight = 0.2
ITEM.access = "q"
ITEM.useText = "Drink"
ITEM.category = "Medical"
ITEM.business = true;
ITEM.description = "#Item_CoughSyrup_Description"
ITEM.customFunctions = {"Give"}

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	if (player:GetCharacterData("diseases") == "cough") then
		player:SetCharacterData("diseases", "none")
	end
end;

if (SERVER) then
	function ITEM:OnCustomFunction(player, name)
		if (name == "Give") then
			local lookingPly = player:GetEyeTrace().Entity

			if (lookingPly:IsPlayer()) then
				if (lookingPly:GetCharacterData("diseases") == "cough") then
					lookingPly:SetCharacterData("diseases", "none")
				end

				cw.player:Notify(player, L("Diseases_Gave_CoughSyrup"))
				player:TakeItem(player:FindItemByID("cough_syrup"))
			else
				cw.player:Notify(player, L("Diseases_MustLookAtPerson"));

				return false
			end
		end
	end
end

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end