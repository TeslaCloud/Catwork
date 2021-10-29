ITEM.name = "Шприц стрихнина"
ITEM.uniqueID = "green_liquid"
ITEM.cost = 50
ITEM.model = "models/healthvial.mdl"
ITEM.weight = 0.2
ITEM.factions = {FACTION_MPF}
ITEM.useText = "Использовать"
ITEM.category = "Медицина"
ITEM.business = true
ITEM.description = "Неподписанный шприц с зеленой жидкостью."
ITEM.customFunctions = {"Ввести"}

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	player:SetCharacterData("diseases", "slow_deathinjection")
	cw.player:Notify(player, "Вы ввели зеленую жидкость в свою вену.")
end

if (SERVER) then
	function ITEM:OnCustomFunction(player, name)
		if (name == "Ввести") then
			local lookingPly = player:GetEyeTrace().Entity

			if (lookingPly:IsPlayer()) then
				lookingPly:SetCharacterData("diseases", "slow_deathinjection")
				cw.player:Notify(player, "Вы ввели зеленую жидкость персонажу.")
				player:TakeItem(player:FindItemByID("green_liqud"))
			else
				cw.player:Notify(player, "Вы должны смотреть на человека!")

				return false
			end
		end
	end
end

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end