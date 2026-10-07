ITEM.name = "Pack of Activated Charcoal"
ITEM.PrintName = "#Item_ActivatedCoal_PrintName"
ITEM.uniqueID = "activated_coal"
ITEM.cost = 0
ITEM.model = "models/props_lab/powerbox02c.mdl"
ITEM.weight = 0.2
ITEM.access = "q"
ITEM.useText = "Swallow"
ITEM.category = "Medical"
ITEM.business = true
ITEM.description = "#Item_ActivatedCoal_Description"
ITEM.customFunctions = {"Give"}

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	if (player:GetCharacterData("diseases") == "gastrits") then
		timer.Simple(math.random(30, 60), function()
			player:SetCharacterData( "diseases", "none" )
		end)		
	end

	hook.Run("PlayerHealed", player, player, self)
end

if (SERVER) then
	function ITEM:OnCustomFunction(player, name)
		if (name == "Give") then
			local lookingPly = player:GetEyeTrace().Entity

			if (lookingPly:IsPlayer()) then
				if (lookingPly:GetCharacterData("diseases") == "gastrits") then
					timer.Simple(math.random(30, 60), function()
						lookingPly:SetCharacterData("diseases", "none")
					end)
				end

				player:TakeItem(player:FindItemByID("activated_coal"))
				cw.player:Notify(player, L("Diseases_Gave_ActivatedCoal"))

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