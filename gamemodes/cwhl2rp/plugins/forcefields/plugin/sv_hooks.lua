function cwForceField:ClockworkInitPostEntity()
	self:LoadForceFields()
end

function cwForceField:PostSaveData()
	self:SaveForceFields()
end

function cwForceField:PlayerItemTaken(player, itemTable)
	if (itemTable.uniqueID == "combine_forcefield_card" and player:GetItemCountByID("combine_forcefield_card") < 2) then
		player:SetNetVar("ShouldForceFieldCollide", true)
	end
end

function cwForceField:PlayerItemGiven(player, itemTable, bForce)
	if (itemTable.uniqueID == "combine_forcefield_card") then
		player:SetNetVar("ShouldForceFieldCollide", false)
	end
end