--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

ITEM.isBaseItem = true
ITEM.name = "Weapon Base"
ITEM.useText = "Equip"
ITEM.useSound = false
ITEM.category = "Weapons"
ITEM.useInVehicle = false

local defaultWeapons = {
	["weapon_357"] = {"357", nil, true},
	["weapon_ar2"] = {"ar2", "ar2altfire", 30},
	["weapon_rpg"] = {"rpg_round", nil, 3},
	["weapon_smg1"] = {"smg1", "smg1_grenade", true},
	["weapon_slam"] = {"slam", nil, 2},
	["sxbase_he"] = {"grenade", nil, 1},
	["sxbase_fg"] = {"grenade", nil, 1},
	["sxbase_sg"] = {"grenade", nil, 1},
	["weapon_pistol"] = {"pistol", nil, true},
	["weapon_shotgun"] = {"buckshot", nil, true},
	["weapon_crossbow"] = {"xbowbolt", nil, 4},
}
ITEM:AddData("ClipOne", 0, true)
ITEM:AddData("ClipTwo", 0, true)

-- Called whent he item entity's menu options are needed.
function ITEM:GetEntityMenuOptions(entity, options)
	if (self:HasSecondaryClip() or self:HasPrimaryClip()) then
		local informationColor = cw.option:GetColor("information")
		local toolTip = cw.core:AddMarkupLine("", L"#AmmoTip", informationColor)
		local clipOne = self:GetData("ClipOne")
		local clipTwo = self:GetData("ClipTwo")

		if (clipOne > 0 or clipTwo > 0) then
			if (clipOne > 0) then
				toolTip = cw.core:AddMarkupLine(toolTip, L"Primary: "..clipOne)
			end

			if (clipTwo > 0) then
				toolTip = cw.core:AddMarkupLine(toolTip, L"Secondary: "..clipTwo)
			end

			options[L"Ammo"] = {
				isArgTable = true,
				arguments = "cw.itemAmmo",
				toolTip = toolTip
			}
		end
	end
end

function ITEM:GetWeaponClass()
	return self.weaponClass or self.uniqueID
end

-- Called to get whether a player has the item equipped.
function ITEM:HasPlayerEquipped(player, bIsValidWeapon)
	local weaponClass = self:GetWeaponClass()

	if (SERVER) then
		local weapon = player:GetWeapon(weaponClass)
		local itemTable = item.GetByWeapon(weapon)

		if (itemTable and itemTable:IsTheSameAs(self)) then
			return true
		end
	end

	--[[
		Just returning true here because there isn't
		a GetWeapon function client-side. Yet...
	--]]
	if (CLIENT and bIsValidWeapon) then
		return true
	end

	return false
end

-- Called when a player attempts to holster the weapon.
function ITEM:CanHolsterWeapon(player, forceHolster, bNoMsg)
	return true
end

-- Called when the unequip should be handled.
function ITEM:OnHandleUnequip(Callback)
	if (self.OnDrop) then
		local menu = DermaMenu()
			menu:SetMinimumWidth(100)
			menu:AddOption(L("Holster"), function()
				Callback()
			end)
			menu:AddOption(L("Drop"), function()
				Callback("drop")
			end)
		menu:Open()
	else
		Callback()
	end
end

-- Called when a player has unequipped the item.
function ITEM:OnPlayerUnequipped(player, extraData)
	local weapon = player:GetWeapon(self:GetWeaponClass())

	if (!IsValid(weapon)) then return end

	local itemTable = item.GetByWeapon(weapon)

	if (itemTable:IsTheSameAs(self)) then
		local class = weapon:GetClass()

		if (extraData != "drop") then
			if (hook.Run("PlayerCanHolsterWeapon", player, self, weapon)) then
				if (player:GiveItem(self)) then
					hook.Run("PlayerHolsterWeapon", player, self, weapon)
					player:StripWeapon(class)
					player:SelectWeapon("cw_hands")
				end
			end
		elseif (hook.Run("PlayerCanDropWeapon", player, self, weapon)) then
			local trace = player:GetEyeTraceNoCursor()

			if (player:GetShootPos():Distance(trace.HitPos) <= 192) then
				local entity = cw.entity:CreateItem(player, self, trace.HitPos)

				if (IsValid(entity)) then
					cw.entity:MakeFlushToGround(entity, trace.HitPos, trace.HitNormal)
					hook.Run("PlayerDropWeapon", player, self, entity, weapon)

					player:TakeItem(self, true)
					player:StripWeapon(class)
					player:SelectWeapon("cw_hands")
				end
			else
				cw.player:Notify(player, "#CantDropFar")
			end
		end
	end
end

-- A function to get whether the item has a secondary clip.
function ITEM:HasSecondaryClip()
	return !self.hasNoSecondaryClip
end

-- A function to get whether the item has a primary clip.
function ITEM:HasPrimaryClip()
	return !self.hasNoPrimaryClip
end

-- A function to get whether the item is a throwable weapon.
function ITEM:IsThrowableWeapon()
	return self.isThrowableWeapon
end

-- A function to get whether the item is a fake weapon.
function ITEM:IsFakeWeapon()
	return self.isFakeWeapon
end

-- A function to get whether the item is a melee weapon.
function ITEM:IsMeleeWeapon()
	return self.isMeleeWeapon
end

-- Called when the item is given to a player as a weapon.
function ITEM:OnWeaponGiven(player, weapon)
	cw.player:StripDefaultAmmo(
		player, weapon, self
	)

	local clipOne = self:GetData("ClipOne")
	local clipTwo = self:GetData("ClipTwo")

	if (clipOne > 0) then
		weapon:SetClip1(clipOne)
		self:SetData("ClipOne", 0)
	end

	if (clipTwo > 0) then
		weapon:SetClip2(clipTwo)
		self:SetData("ClipTwo", 0)
	end
end

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	local weaponClass = self:GetVar("weaponClass")

	if (!isstring(weaponClass) or weaponClass == "weapon_base") then
		weaponClass = self.uniqueID
	end

	if (!isstring(weaponClass)) then
		cw.player:Notify(player, "[Catwork:Error] This weapon is broken! Contact the developers. (type = "..type(weaponClass).." :: "..tostring(self)..")")

		return false
	end

	if (!player:HasWeapon(weaponClass)) then
		player:Give(weaponClass, self)

		local weapon = player:GetWeapon(weaponClass)

		if (IsValid(weapon)) then
			if (self.OnEquip) then
				self:OnEquip(player)
			end

			player:RebuildInventory()
		else
			return false
		end
	else
		local weapon = player:GetWeapon(weaponClass)

		if (IsValid(weapon) and self.OnAlreadyHas) then
			if (item.GetByWeapon(weapon) == self) then
				self:OnAlreadyHas(player)
			end
		end

		return false
	end
end

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end

-- Called when the item should be setup.
function ITEM:OnSetup()
	if (!self.weaponClass) then
		self.weaponClass = self.uniqueID
	end

	self.weaponClass = string.lower(self.weaponClass)

	timer.Simple(2, function()
		local weaponClass = self:GetWeaponClass()
		local weaponTable = weapons.GetStored(weaponClass)

		if (weaponTable) then
			if (!self.primaryAmmoClass) then
				if (weaponTable.Primary and weaponTable.Primary.Ammo) then
					self:Override("primaryAmmoClass", weaponTable.Primary.Ammo)
				end
			end

			if (!self.secondaryAmmoClass) then
				if (weaponTable.Secondary and weaponTable.Secondary.Ammo) then
					self:Override("secondaryAmmoClass", weaponTable.Secondary.Ammo)
				end
			end

			if (!self.primaryDefaultAmmo) then
				if (weaponTable.Primary and weaponTable.Primary.DefaultClip) then
					if (weaponTable.Primary.DefaultClip > 0) then
						if (weaponTable.Primary.ClipSize == -1) then
							self:Override("primaryDefaultAmmo", weaponTable.Primary.DefaultClip)
							self:Override("hasNoPrimaryClip", true)
						else
							self:Override("primaryDefaultAmmo", true)
						end
					end
				end
			end

			if (!self.secondaryDefaultAmmo) then
				if (weaponTable.Secondary and weaponTable.Secondary.DefaultClip) then
					if (weaponTable.Secondary.DefaultClip > 0) then
						if (weaponTable.Secondary.ClipSize == -1) then
							self:Override("secondaryDefaultAmmo", weaponTable.Secondary.DefaultClip)
							self:Override("hasNoSecondaryClip", true)
						else
							self:Override("secondaryDefaultAmmo", true)
						end
					end
				end
			end
		elseif (defaultWeapons[weaponClass]) then
			if (!self.primaryAmmoClass) then
				self:Override("primaryAmmoClass", defaultWeapons[weaponClass][1])
			end

			if (!self.secondaryAmmoClass) then
				self:Override("secondaryAmmoClass", defaultWeapons[weaponClass][2])
			end

			if (!self.primaryDefaultAmmo) then
				self:Override("primaryDefaultAmmo", defaultWeapons[weaponClass][3])
			end

			if (!self.secondaryDefaultAmmo) then
				self:Override("secondaryDefaultAmmo", defaultWeapons[weaponClass][4])
			end
		end
	end)
end

-- Called when a player holsters the item.
function ITEM:OnHolster(player, bForced) end

if (CLIENT) then
function ITEM:GetClientSideInfo()
		if (!self:IsInstance()) then
			return
		end

		local clientSideInfo = ""
		local clipOne = self:GetData("ClipOne")
		local clipTwo = self:GetData("ClipTwo")

		if (clipOne > 0) then
			clientSideInfo = cw.core:AddMarkupLine(clientSideInfo, L"Clip One: "..clipOne)
		end

		if (clipTwo > 0) then
			clientSideInfo = cw.core:AddMarkupLine(clientSideInfo, L"Clip Two: "..clipTwo)
		end

		return (clientSideInfo != "" and clientSideInfo)
	end
end
