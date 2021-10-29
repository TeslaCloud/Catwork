--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

-- Called when Clockwork has loaded all of the entities.
function PLUGIN:ClockworkInitPostEntity()
	self:LoadPlants()
end

-- Called just after data should be saved.
function PLUGIN:PostSaveData()
	self:SavePlants()
end

function PLUGIN:PlayerHarvest(player, uniqueID)
	local itemTable = item.FindByID(uniqueID)
	local chance = math.random(1, 100) + math.Round(cw.attributes:Fraction(player, ATB_FARM, 50))

	if (chance >= 40) then
		local seed = itemTable.Harvest[1]
		local harvest = itemTable.Harvest[2]

		player:FastGiveItem(seed)

		if (chance > 100) then
			player:FastGiveItem(seed)
		end

		if (chance >= 50) then
			for i = 1, math.Clamp(math.Round((chance - 50) / 25), 1, 4) do
				player:FastGiveItem(harvest)
			end
		end
		cw.player:Notify(player, "Вы успешно собрали урожай.")
	else
		cw.player:Notify(player, "Вам не удалось собрать урожай.")
	end

	player:ProgressAttribute(ATB_FARM, 10, true)
end
