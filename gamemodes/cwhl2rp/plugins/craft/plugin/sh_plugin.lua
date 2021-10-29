--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

PLUGIN:SetGlobalAlias("cwCraft")

util.Include("cl_hooks.lua")
util.Include("sv_hooks.lua")

function cwCraft:PlayerCanCraft(player, bpTable)
	if (!self:PlayerHasMaterials(player, bpTable)) then
		return false, "#Craft_Error_NoMaterials"
	end

	if (!self:PlayerHasTools(player, bpTable)) then
		return false, "#Craft_Error_NoTools"
	end

	if (!self:PlayerHasAttributes(player, bpTable)) then
		return false, "#Craft_Error_NoAttributes"
	end
	
	if (!self:PlayerMeetsRequirements(player, bpTable)) then
		return false, "#Craft_Error_NoRequirements"
	end

	if (player.cwNextCraftTime and player.cwNextCraftTime > CurTime()) then
		return false, "#Craft_Error_Cooldown"
	end

	return true 
end

function cwCraft:PlayerHasMaterials(player, bpTable)
	local materials = bpTable["recipe"]

	if (materials) then
		for k, v in pairs(materials) do
			local inventory = player:GetInventory()

			if (cw.inventory:GetItemCountByID(inventory, v[1]) < v[2]) then
				return false
			end
		end
	end

	return true
end

function cwCraft:PlayerHasTools(player, bpTable)
	local tools = bpTable["required"]

	if (tools) then
		for k, v in pairs(tools) do
			local inventory = player:GetInventory()

			if (cw.inventory:GetItemCountByID(inventory, v[1]) < v[2]) then
				return false
			end
		end
	end

	return true
end

function cwCraft:PlayerHasAttributes(player, bpTable)
	local attributes = bpTable["reqatt"]

	if (attributes) then
		for k, v in pairs(attributes) do
			if (cw.attributes:Get(player, v[1], nil, true) < v[2]) then
				return false
			end
		end
	end

	return true
end

function cwCraft:PlayerMeetsRequirements(player, bpTable)
	local requirements = bpTable["requirements"]

	if (requirements) then
		for k, v in pairs(requirements) do
			if (v) then
				local bSucc, text = v(player)

				if (!bSucc) then
					return false
				end
			end
		end
	end

	return true
end

netstream.Hook("Craft::CraftItem", function(player, bpTable)
	local bSucc, err = cwCraft:PlayerCanCraft(player, bpTable)

	if (!bSucc) then
		cw.player:Notify(player, err)

		return false
	end

	cw.core:PrintLog(LOGTYPE_MINOR, player:Name().." has crafted a "..bpTable["name"]..".")
	cwCraft:PlayerCraftItem(player, bpTable)
	player:EmitSound("plats/elevator_stop.wav")
	player.cwNextCraftTime = CurTime() + 1

	if (bpTable.OnCraft) then
		bpTable:OnCraft(player, bpTable)
	end
end)
