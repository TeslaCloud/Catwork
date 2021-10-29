ITEM.name = "Градусник"
ITEM.cost = 50
ITEM.model = "models/props_c17/TrapPropeller_Lever.mdl"
ITEM.weight = 0.2
ITEM.access = "q"
ITEM.useText = "Применить"
ITEM.category = "Медицина"
ITEM.business = true
ITEM.description = "Палочка, указывающая температуру носителя."

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	local lookingPly = player:GetEyeTrace().Entity
	
	if (lookingPly:IsPlayer()) then
		if (lookingPly:GetCharacterData("diseases") == "fever") then
			cw.player:Notify(player, "Температура: "..math.random(40.1, 43.6).."C")
		else
			cw.player:Notify(player, "Температура: "..math.random(36.5, 37.0).."C")
		end

		return false
	else
		cw.player:Notify(player, "Вы должны смотреть на человека!")

		return false
	end
end

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end