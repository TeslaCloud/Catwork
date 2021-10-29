--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

ITEM.isBaseItem = true
ITEM.name = "Clothes Base"
ITEM.model = "models/props_c17/suitcase_passenger_physics.mdl"
ITEM.weight = 2
ITEM.useText = "Wear"
ITEM.category = "Clothing"
ITEM.description = "A suitcase full of clothes."

-- A function to get the model name.
function ITEM:GetModelName(player, group)
	local modelName = nil

	if (!player) then
		player = cw.client
	end

	if (group) then
		modelName = string.gsub(string.lower(cw.player:GetDefaultModel(player)), "^.-/.-/", "")
	else
		modelName = string.gsub(string.lower(cw.player:GetDefaultModel(player)), "^.-/.-/.-/", "")
	end

	if (!string.find(modelName, "male") and !string.find(modelName, "female")) then
		if (group) then
			group = "group05/"
		else
			group = ""
		end

		if (SERVER) then
			if (player:GetGender() == GENDER_FEMALE) then
				return group.."female_04.mdl"
			else
				return group.."male_05.mdl"
			end
		elseif (player:GetGender() == GENDER_FEMALE) then
			return group.."female_04.mdl"
		else
			return group.."male_05.mdl"
		end
	else
		return modelName
	end
end

-- Called when the item's client side model is needed.
function ITEM:GetClientSideModel()
	local replacement = nil

	if (self.GetReplacement) then
		replacement = self:GetReplacement(cw.client)
	end

	if (isstring(replacement)) then
		return replacement
	elseif (self.replacement) then
		return self.replacement
	elseif (self.group) then
		return "models/humans/"..self.group.."/"..self:GetModelName()
	end
end

-- Called when a player changes clothes.
function ITEM:OnChangeClothes(player, bIsWearing)
	if (bIsWearing) then
		local replacement = nil

		if (self.GetReplacement) then
			replacement = self:GetReplacement(player)
		end

		if (isstring(replacement)) then
			player:SetModel(replacement)
		elseif (self.replacement) then
			player:SetModel(self.replacement)
		elseif (self.group) then
			player:SetModel("models/humans/"..self.group.."/"..self:GetModelName(player))
		end
	else
		cw.player:SetDefaultModel(player)
		cw.player:SetDefaultSkin(player)
	end

	if (self.OnChangedClothes) then
		self:OnChangedClothes(player, bIsWearing)
	end
end

-- Called to get whether a player has the item equipped.
function ITEM:HasPlayerEquipped(player, bIsValidWeapon)
	if (CLIENT) then
		return cw.player:IsWearingItem(self)
	else
		return player:IsWearingItem(self)
	end
end

-- Called when a player has unequipped the item.
function ITEM:OnPlayerUnequipped(player, extraData)
	player:RemoveClothes()
end

-- Called when a player drops the item.
function ITEM:OnDrop(player, position)
	if (player:IsWearingItem(self)) then
		cw.player:Notify(player, "#CantDropWhenWearing")
		return false
	end
end

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	if (self.whitelist and !table.HasValue(self.whitelist, player:GetFaction())) then
		cw.player:Notify(player, L"#FactionCantWear")
		return false
	end

	if (player:Alive() and !player:IsRagdolled()) then
		if (!self.CanPlayerWear or self:CanPlayerWear(player, itemEntity) != false) then
			player:SetClothesData(self)
			return true
		end
	else
		cw.player:Notify(player, L"#CantDoThisNow")
	end

	return false
end

if (CLIENT) then
	function ITEM:GetClientSideInfo()
		if (!self:IsInstance()) then return end

		if (cw.player:IsWearingItem(self)) then
			return L"#IsWearing_Yes"
		else
			return L"#IsWearing_No"
		end
	end
end
