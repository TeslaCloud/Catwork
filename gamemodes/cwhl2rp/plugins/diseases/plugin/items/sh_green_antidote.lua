ITEM.name = "Шприц с аломорфином"
ITEM.cost = 50
ITEM.model = "models/healthvial.mdl"
ITEM.weight = 0.2
ITEM.factions = {FACTION_MPF}
ITEM.useText = "Использовать"
ITEM.category = "Медицина"
ITEM.business = true
ITEM.description = "Шприц с зеленой жидкостью и надписью 'Антидот'."
ITEM.customFunctions = {"Ввести"}

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	if (player:GetCharacterData("diseases") == "slow_deathinjection") then
		player:SetCharacterData( "diseases", "none" )
		cw.player:Notify(player, "Вы ввели в свои вены антидот...")
	elseif (player:GetCharacterData("diseases") == "fast_deathinjection") then
		cw.player:Notify(player, "Вы ввели в свои вены антидот, но лучше Вам не стало...")
	end
end

if (SERVER) then
	function ITEM:OnCustomFunction(player, name)
		if (name == "Ввести") then
			local lookingPly = player:GetEyeTrace().Entity

			if (lookingPly:IsPlayer()) then
				if (lookingPly:GetCharacterData("diseases") == "slow_deathinjection") then
					lookingPly:SetCharacterData( "diseases", "none" )
				elseif (lookingPly:GetCharacterData("diseases") == "fast_deathinjection") then
					cw.player:Notify(player, "Вы ввели антидот персонажу. Не похоже, чтобы ему стало лучше.")
				end

				cw.player:Notify(player, "Вы ввели антидот человеку.")

				return true
			else
				cw.player:Notify(player, "Вы должны смотреть на человека!")

				return false
			end
		end
	end
end

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end