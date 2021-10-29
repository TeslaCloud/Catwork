
ITEM.name = "ПДБ-6"
ITEM.uniqueID = "rad_checker"
ITEM.cost = 0
ITEM.model = "models/Items/car_battery01.mdl"
ITEM.useText = "Проверить"
ITEM.useSound = false
ITEM.weight = 2.5
ITEM.business = true
ITEM.description = "Прибор для определения дозы радиации организма."

function ITEM:OnUse(player, itemEntity)
	local medical = cw.attributes:Fraction(player, ATB_MEDICAL, 100)
	if medical >= 50 then
		local traceent = player:GetEyeTrace().Entity

		if IsValid(traceent) then
			local rad = "неизвестно."
			if traceent:IsPlayer() or traceent:IsNPC() or traceent:IsBot() then
				if traceent:Distance(player:GetPos()) < 55 then
					if traceent.GetCharacterData then
						rad = math.Round(traceent:GetCharacterData("radlevel", 0), 2) .. " рад."
					end
					cw.player:Notify(player, "Доза радиации объекта: "..rad)
				end
			end
		end
	else
		cw.player:Notify(player, "Ваших медицинских навыков недостаточно чтобы использовать этот прибор.")
	end

	return false
end
function ITEM:OnDrop(player, position) end

