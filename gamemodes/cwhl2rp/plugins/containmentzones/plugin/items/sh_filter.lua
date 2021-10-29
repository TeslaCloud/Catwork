
ITEM.name = "Фильтр"
ITEM.uniqueID = "filter"
ITEM.cost = 0
ITEM.model = "models/Items/battery.mdl"
ITEM.useText = "Сменить фильтр"
ITEM.useSound = false
ITEM.weight = 0.1
ITEM.business = true
ITEM.description = "Фильтр для противогазов типа GP-5 и GCP-1."
ITEM:AddData("energy", 100, true)

if CLIENT then
function ITEM:GetClientSideDescription()
		local desc = self.description
		local filter = self:GetData("energy")

		if filter then
			desc = "Фильтр для противогазов типа GP-5 и GCP-1." .. "\nСостояние фильтра: " .. filter .. "%"
		end

		return (desc != "" and desc)
	end
end

function ITEM:OnUse(player, itemEntity)
	if player:GetFaction() == FACTION_MPF then
		local energy = self:GetData("energy", 0)
		local oldenergy = math.floor(player:GetCharacterData("cp_filter", 0))
		player:SetCharacterData("cp_filter", energy)

		if oldenergy > 0 then
			local oldfilter = player:GiveItem("filter", true)
			oldfilter:SetData("energy", oldenergy)
		end
	else
		local gasmasks = player:GetInventory()["gasmask"]
		if gasmasks then
			local gasmask_equipped
			for k, gasmask in pairs(gasmasks) do
				if !gasmask:GetData("equip") then continue end
				gasmask_equipped = gasmask
			end

			if gasmask_equipped then
				local energy = self:GetData("energy", 0)
				local oldenergy = math.floor(gasmask_equipped:GetData("energy", 0))
				gasmask_equipped:SetData("energy", energy)

				if oldenergy > 0 then
					local oldfilter = player:GiveItem("filter", true)
					oldfilter:SetData("energy", oldenergy)
				end
			else
				return false
			end
		else
			return false
		end
	end
end
function ITEM:OnDrop(player, position) end

