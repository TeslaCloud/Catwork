--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

ITEM.isBaseItem = true
ITEM.name = "Ammo Base"
ITEM.useText = "Load"
ITEM.useSound = false
ITEM.category = "Ammunition"
ITEM.ammoClass = "pistol"
ITEM.ammoAmount = 0
ITEM.roundsText = "Rounds"
ITEM:AddData("Rounds", -1, true)

-- A function to get the item's weight.
function ITEM:GetItemWeight()
	return (self.weight / self.ammoAmount) * self:GetData("Rounds")
end

-- A function to get the item's space.
function ITEM:GetItemSpace()
	return (self.space / self.ammoAmount) * self:GetData("Rounds")
end

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	local secondaryAmmoClass = self.secondaryAmmoClass
	local primaryAmmoClass = self.primaryAmmoClass
	local ammoAmount = self.ammoAmount
	local ammoClass = string.lower(self.ammoClass)

	for k, v in pairs(player:GetWeapons()) do
		local itemTable = item.GetByWeapon(v)

		if (itemTable and (string.lower(tostring(itemTable.primaryAmmoClass)) == ammoClass
		or string.lower(tostring(itemTable.secondaryAmmoClass)) == ammoClass
		or string.lower(tostring(v.Primary.Ammo)) == ammoClass
		or string.lower(tostring(v.Secondary.Ammo)) == ammoClass)) then
			player:GiveAmmo(ammoAmount, ammoClass)

			return
		end
	end

	cw.player:Notify(
		player, "#WeaponUsesAmmo"
	)

	return false
end

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end

if (SERVER) then
	function ITEM:OnInstantiated()
		self:SetData("Rounds", self.ammoCount)
	end
else
	function ITEM:GetClientSideInfo()
		return cw.core:AddMarkupLine(
			"", L(self.roundsText)..": "..self.ammoAmount
		)
	end
end
