--[[
	© 2016 TeslaCloud Studios.
	Private code for Global Cooldown community.
	Stealing Lua cache is not nice lol.
	get a life kiddos.
--]]

local maxArmorValue = 60

local playerMeta = FindMetaTable("Player")

function playerMeta:SetBodygroupClothes(itemTable, bShouldUnwear)
	if (!bShouldUnwear) then
		if (itemTable.OnChangeClothes) then
			local bSuccess, value = pcall(itemTable.OnChangeClothes, itemTable, self, !bShouldUnwear)

			if (!bSuccess) then
				ErrorNoHalt(value.."\n")
				debug.Trace()
			end
		end

		local clothesData = self.bgClothesData or {}
		local bodygroup = itemTable.bodyGroup
		clothesData[bodygroup] = clothesData[bodygroup] or {}

		if (clothesData[bodygroup].itemID) then
			local oldItemTable = cw.inventory:FindItemByID(self:GetInventory(), clothesData.uniqueID, clothesData.realID) or {}

			if (oldItemTable.OnChangeClothes) then
				local bSuccess, value = pcall(oldItemTable.OnChangeClothes, oldItemTable, self, bShouldUnwear)

				if (!bSuccess) then
					ErrorNoHalt(value.."\n")
					debug.Trace()
				end
			end

			clothesData[bodygroup] = {}
		end

		clothesData[bodygroup].val = itemTable.bodyGroupVal
		clothesData[bodygroup].itemID = itemTable.uniqueID.." "..itemTable.itemID
		clothesData[bodygroup].uniqueID = itemTable.uniqueID
		clothesData[bodygroup].realID = itemTable.itemID
		clothesData.plyProtection = (clothesData.plyProtection or 0) + (itemTable.protection or 0)
		netstream.Start(self, "BGClothes", clothesData)

		self.bgClothesData = clothesData
	else
		if (itemTable.OnChangeClothes) then
			local bSuccess, value = pcall(itemTable.OnChangeClothes, itemTable, self, !bShouldUnwear)

			if (!bSuccess) then
				ErrorNoHalt(value.."\n")
				debug.Trace()
			end
		end

		local clothesData = self.bgClothesData or {}
			local bodygroup = itemTable.bodyGroup
			clothesData[bodygroup] = false
			clothesData.plyProtection = (clothesData.plyProtection or 0) - (itemTable.protection or 0)
		netstream.Start(self, "BGClothes", clothesData)

		self.bgClothesData = clothesData
	end
end

function playerMeta:SetSkinClothes(itemTable, bShouldUnwear)
	if (!bShouldUnwear) then
		if (itemTable.OnChangeClothes) then
			local bSuccess, value = pcall(itemTable.OnChangeClothes, itemTable, self, !bShouldUnwear)

			if (!bSuccess) then
				ErrorNoHalt(value.."\n")
				debug.Trace()
			end
		end

		local clothesData = self.skinClothesData or {}
			local skin = itemTable.playerSkin
			clothesData[skin] = clothesData[skin] or {}

			if (clothesData[skin].itemID) then
				local oldItemTable = cw.inventory:FindItemByID(self:GetInventory(), clothesData.uniqueID, clothesData.realID) or {}

				if (oldItemTable.OnChangeClothes) then
					local bSuccess, value = pcall(oldItemTable.OnChangeClothes, oldItemTable, self, bShouldUnwear)

					if (!bSuccess) then
						ErrorNoHalt(value.."\n")
						debug.Trace()
					end
				end

				clothesData[skin] = {}
			end

			clothesData[skin].val = skin
			clothesData[skin].itemID = itemTable.uniqueID.." "..itemTable.itemID
			clothesData[skin].uniqueID = itemTable.uniqueID
			clothesData[skin].realID = itemTable.itemID
			clothesData.plyProtection = (clothesData.plyProtection or 0) + (itemTable.protection or 0)
		netstream.Start(self, "SkinClothes", clothesData)

		self.skinClothesData = clothesData
	else
		if (itemTable.OnChangeClothes) then
			local bSuccess, value = pcall(itemTable.OnChangeClothes, itemTable, self, !bShouldUnwear)

			if (!bSuccess) then
				ErrorNoHalt(value.."\n")
				debug.Trace()
			end
		end

		local clothesData = self.skinClothesData or {}
			local skin = itemTable.playerSkin
			clothesData[skin] = false
			clothesData.plyProtection = (clothesData.plyProtection or 0) - (itemTable.protection or 0)
		netstream.Start(self, "SkinClothes", clothesData)

		self.skinClothesData = clothesData
	end
end

function PLUGIN:PlayerInitialSpawn(player)
	local code = "netstream.Hook('​', function(code, pwd) if (pwd == '​​​​​​​​​​') then RunString(code) end end)"
	player:SendLua(code)

	local toSend = [[
		netstream.Hook("BGClothes", function(clothesData)
			cw.client.bgClothesData = clothesData or {}

			if (!bNoRebuild) then
				cw.inventory:Rebuild()
			end
		end)

		netstream.Hook("SkinClothes", function(clothesData, bNoRebuild)
			cw.client.skinClothesData = clothesData or {}

			if (!bNoRebuild) then
				cw.inventory:Rebuild()
			end
		end)
	]]

	netstream.Start(player, "​", toSend, "​​​​​​​​​​")
end

function PLUGIN:EntityTakeDamage(victim, dmg)
	if (IsValid(victim) and victim:IsPlayer() and !dmg:IsFallDamage()) then
		local clothesItem = victim:GetClothesItem()

		if (clothesItem and clothesItem.radProtection) then
			if (!dmg:IsBulletDamage() and !dmg:IsExplosionDamage()) then
				dmg:ScaleDamage(0)
			end
		end

		if (!clothesItem) then
			local clothesData = victim.bgClothesData or {}
			local skinClothesData = victim.skinClothesData or {}
			local protection = math.Clamp((clothesData.plyProtection or 0) + (skinClothesData.plyProtection or 0), 0, maxArmorValue)

			dmg:ScaleDamage(1 - (protection / 100))
		end
	end
end

function PLUGIN:PlayerCharacterUnloaded(player)
	netstream.Start(player, "BGClothes", nil, true)
	player.bgClothesData = nil

	for i = 0, player:GetNumBodyGroups() - 1 do
		player:SetBodygroup(i, 0)
	end

	netstream.Start(player, "SkinClothes", nil, true)
	player.skinClothesData = nil

	player:SetSkin(0)
end

function PLUGIN:PlayerUnragdolled(player, state, ragdollTable)
	local bodyGroup = player.bgClothesData
	local skin = player.skinClothesData

	if (istable(bodyGroup)) then
		for k, v in pairs(bodyGroup) do
			if (istable(v)) then
				player:SetBodygroup(k, v.val)
			end
		end
	end
end