--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

library.New("attributes", cw)

if (SERVER) then
	function cw.attributes:Progress(player, attribute, amount, gradual)
		local attributeTable = cw.attribute:FindByID(attribute)
		local attributes = player:GetAttributes()

		if (attributeTable) then
			attribute = attributeTable.uniqueID

			if (gradual and attributes[attribute]) then
				if (amount > 0) then
					amount = math.max(amount - ((amount / attributeTable.maximum) * attributes[attribute].amount), amount / attributeTable.maximum)
				else
					amount = math.min((amount / attributeTable.maximum) * attributes[attribute].amount, amount / attributeTable.maximum)
				end
			end

			hook.Run("OnAttributeProgress", player, attribute, amount)

			if (attributes[attribute]) then
				if (attributes[attribute].amount == attributeTable.maximum) then
					if (amount > 0) then
						return false, "Вы достигли максимального значения атрибута!"
					end
				end
			else
				attributes[attribute] = {amount = 0, progress = 0}
			end

			local progress = attributes[attribute].progress + amount
			local remaining = math.max(progress - 100, 0)

			if (progress >= 100) then
				attributes[attribute].progress = 0

				player:UpdateAttribute(attribute, 1)

				if (remaining > 0) then
					return player:ProgressAttribute(attribute, remaining)
				end
			elseif (progress < 0) then
				attributes[attribute].progress = 100

				player:UpdateAttribute(attribute, -1)

				if (progress < 0) then
					return player:ProgressAttribute(attribute, progress)
				end
			else
				attributes[attribute].progress = progress
			end

			if (attributes[attribute].amount == 0 and attributes[attribute].progress == 0) then
				attributes[attribute] = nil
			end

			if (player:HasInitialized()) then
				if (attributes[attribute]) then
					player.cwAttrProgress[attribute] = math.floor(attributes[attribute].progress)
				else
					player.cwAttrProgress[attribute] = 0
				end
			end
		else
			return false, "That is not a valid attribute!"
		end
	end

	-- A function to update a player's attribute.
	function cw.attributes:Update(player, attribute, amount)
		local attributeTable = cw.attribute:FindByID(attribute)
		local attributes = player:GetAttributes()

		if (attributeTable) then
			attribute = attributeTable.uniqueID

			if (!attributes[attribute]) then
				attributes[attribute] = {amount = 0, progress = 0}
			elseif (attributes[attribute].amount == attributeTable.maximum) then
				if (amount and amount > 0) then
					return false, "Вы достигли максимального значения атрибута!"
				end
			end

			attributes[attribute].amount = math.Clamp(attributes[attribute].amount + (amount or 0), 0, attributeTable.maximum)

			if (amount and amount > 0) then
				attributes[attribute].progress = 0

				if (player:HasInitialized()) then
					player.cwAttrProgress[attribute] = 0
					player.cwAttrProgressTime = 0
				end
			end

			netstream.Start(player, "AttrUpdate", {
				index = attributeTable.index, amount = attributes[attribute].amount
			})

			if (attributes[attribute].amount == 0
			and attributes[attribute].progress == 0) then
				attributes[attribute] = nil
			end

			hook.Run("PlayerAttributeUpdated", player, attributeTable, amount)

			return true
		else
			return false, "That is not a valid attribute!"
		end
	end

	-- A function to clear a player's attribute boosts.
	function cw.attributes:ClearBoosts(player)
		netstream.Start(player, "AttrBoostClear", true)

		player.cwAttrBoosts = {}
	end

	--- A function to get whether a boost is active for a player.
	function cw.attributes:IsBoostActive(player, identifier, attribute, amount, duration)
		if (player.cwAttrBoosts) then
			local attributeTable = cw.attribute:FindByID(attribute)

			if (attributeTable) then
				attribute = attributeTable.uniqueID

				if (player.cwAttrBoosts[attribute]) then
					local attributeBoost = player.cwAttrBoosts[attribute][identifier]

					if (attributeBoost) then
						if (amount and duration) then
							return attributeBoost.amount == amount and attributeBoost.duration == duration
						elseif (amount) then
							return attributeBoost.amount == amount
						elseif (duration) then
							return attributeBoost.duration == duration
						else
							return true
						end
					end
				end
			end
		end
	end

	-- A function to boost a player's attribute.
	function cw.attributes:Boost(player, identifier, attribute, amount, duration)
		if (!IsValid(player) or !player:HasInitialized()) then return end

		local attributeTable = cw.attribute:FindByID(attribute)

		if (attributeTable) then
			attribute = attributeTable.uniqueID

			if (amount) then
				if (!identifier) then
					identifier = tostring({})
				end

				if (!player.cwAttrBoosts[attribute]) then
					player.cwAttrBoosts[attribute] = {}
				end

				if (duration) then
					player.cwAttrBoosts[attribute][identifier] = {
						duration = duration,
						endTime = CurTime() + duration,
						default = amount,
						amount = amount,
					}
				else
					player.cwAttrBoosts[attribute][identifier] = {
						amount = amount
					}
				end

				local cwIndex = attributeTable.index
				local cwAmount = player.cwAttrBoosts[attribute][identifier].amount
				local cwDuration = player.cwAttrBoosts[attribute][identifier].duration
				local cwEndTime = player.cwAttrBoosts[attribute][identifier].endTime
				local cwIdentifier = identifier

				netstream.Start(player, "AttrBoost", {
					index = cwIndex, amount = cwAmount, duration = cwDuration, endTime = cwEndTime, identifier = cwIdentifier
				})

				return identifier
			elseif (identifier) then
				if (self:IsBoostActive(player, identifier, attribute)) then
					if (player.cwAttrBoosts[attribute]) then
						player.cwAttrBoosts[attribute][identifier] = nil
					end

					netstream.Start(player, "AttrBoostClear", {
						index = attributeTable.index, identifier = identifier
					})
				end

				return true
			elseif (player.cwAttrBoosts[attribute]) then
				netstream.Start(player, "AttrBoostClear", {
					index = attributeTable.index
				})

				player.cwAttrBoosts[attribute] = {}

				return true
			end
		else
			self:ClearBoosts(player)

			return true
		end
	end

	-- A function to get a player's attribute as a fraction.
	function cw.attributes:Fraction(player, attribute, fraction, negative)
		if (!IsValid(player) or !player:HasInitialized()) then return 0 end

		local attributeTable = cw.attribute:FindByID(attribute)

		if (attributeTable) then
			local maximum = attributeTable.maximum
			local amount = self:Get(player, attribute, nil, negative) or 0

			if (amount < 0 and type(negative) == "number") then
				fraction = negative
			end

			if (!attributeTable.cache[amount][fraction]) then
				attributeTable.cache[amount][fraction] = (fraction / maximum) * amount
			end

			return attributeTable.cache[amount][fraction]
		end
	end

	-- A function to get whether a player has an attribute.
	function cw.attributes:Get(player, attribute, boostless, negative)
		if (!IsValid(player) or !player:HasInitialized()) then return end

		local attributeTable = cw.attribute:FindByID(attribute)

		if (attributeTable) then
			attribute = attributeTable.uniqueID

			if (cw.core:HasObjectAccess(player, attributeTable)) then
				local maximum = attributeTable.maximum
				local default = player:GetAttributes()[attribute]
				local boosts = player.cwAttrBoosts[attribute]

				if (boostless) then
					if (default) then
						return default.amount, default.progress
					end
				else
					local progress = 0
					local amount = 0

					if (default) then
						amount = amount + default.amount
						progress = progress + default.progress
					end

					if (boosts) then
						for k, v in pairs(boosts) do
							amount = amount + v.amount
						end
					end

					if (negative) then
						amount = math.Clamp(amount, -maximum, maximum)
					else
						amount = math.Clamp(amount, 0, maximum)
					end

					return math.ceil(amount), progress
				end
			end
		end
	end
else
	cw.attributes.stored = cw.attributes.stored or {}
	cw.attributes.boosts = cw.attributes.boosts or {}

	-- A function to get the attributes panel.
	function cw.attributes:GetPanel()
		return self.panel
	end

	-- A function to get the local player's attribute as a fraction.
	function cw.attributes:Fraction(attribute, fraction, negative)
		local attributeTable = cw.attribute:FindByID(attribute)

		if (attributeTable) then
			local maximum = attributeTable.maximum
			local amount = self:Get(attribute, nil, negative) or 0

			if (amount < 0 and type(negative) == "number") then
				fraction = negative
			end

			if (!attributeTable.cache[amount][fraction]) then
				attributeTable.cache[amount][fraction] = (fraction / maximum) * amount
			end

			return attributeTable.cache[amount][fraction]
		end
	end

	-- A function to get whether the local player has an attribute.
	function cw.attributes:Get(attribute, boostless, negative)
		local attributeTable = cw.attribute:FindByID(attribute)

		if (attributeTable) then
			attribute = attributeTable.uniqueID

			if (cw.core:HasObjectAccess(cw.client, attributeTable)) then
				local maximum = attributeTable.maximum
				local default = self.stored[attribute]
				local boosts = self.boosts[attribute]

				if (boostless) then
					if (default) then
						return default.amount, default.progress
					end
				else
					local progress = 0
					local amount = 0

					if (default) then
						amount = amount + default.amount
						progress = progress + default.progress
					end

					if (boosts) then
						for k, v in pairs(boosts) do
							amount = amount + v.amount
						end
					end

					if (negative) then
						amount = math.Clamp(amount, -maximum, maximum)
					else
						amount = math.Clamp(amount, 0, maximum)
					end

					return math.ceil(amount), progress
				end
			end
		end
	end

	netstream.Hook("AttrBoostClear", function(data)
		local index = nil
		local identifier = nil

		if (type(data) == "table") then
			index = data.index
			identifier = data.identifier
		end

		local attributeTable = cw.attribute:FindByID(index)

		if (attributeTable) then
			local attribute = attributeTable.uniqueID

			if (identifier and identifier != "") then
				if (cw.attributes.boosts[attribute]) then
					cw.attributes.boosts[attribute][identifier] = nil
				end
			else
				cw.attributes.boosts[attribute] = nil
			end
		else
			cw.attributes.boosts = {}
		end

		if (cw.menu:GetOpen()) then
			local panel = cw.attributes:GetPanel()

			if (panel and cw.menu:GetActivePanel() == panel) then
				panel:Rebuild()
			end
		end
	end)

	netstream.Hook("AttrBoost", function(data)
		local index = data.index
		local amount = data.amount
		local duration = data.duration
		local endTime = data.endTime
		local identifier = data.identifier
		local attributeTable = cw.attribute:FindByID(index)

		if (attributeTable) then
			local attribute = attributeTable.uniqueID

			if (!cw.attributes.boosts[attribute]) then
				cw.attributes.boosts[attribute] = {}
			end

			if (amount and amount == 0) then
				cw.attributes.boosts[attribute][identifier] = nil
			elseif (duration and duration > 0 and endTime and endTime > 0) then
				cw.attributes.boosts[attribute][identifier] = {
					duration = duration,
					endTime = endTime,
					default = amount,
					amount = amount
				}
			else
				cw.attributes.boosts[attribute][identifier] = {
					default = amount,
					amount = amount
				}
			end

			if (cw.menu:GetOpen()) then
				local panel = cw.attributes:GetPanel()

				if (panel and cw.menu:GetActivePanel() == panel) then
					panel:Rebuild()
				end
			end
		end
	end)

	netstream.Hook("AttributeProgress", function(data)
		local index = data.index
		local amount = data.amount
		local attributeTable = cw.attribute:FindByID(index)

		if (attributeTable) then
			local attribute = attributeTable.uniqueID

			if (cw.attributes.stored[attribute]) then
				cw.attributes.stored[attribute].progress = amount
			else
				cw.attributes.stored[attribute] = {amount = 0, progress = amount}
			end
		end
	end)

	netstream.Hook("AttrUpdate", function(data)
		local index = data.index
		local amount = data.amount
		local attributeTable = cw.attribute:FindByID(index)

		if (attributeTable) then
			local attribute = attributeTable.uniqueID

			if (cw.attributes.stored[attribute]) then
				cw.attributes.stored[attribute].amount = amount
			else
				cw.attributes.stored[attribute] = {amount = amount, progress = 0}
			end
		end
	end)

	netstream.Hook("AttrClear", function(data)
		cw.attributes.stored = {}
		cw.attributes.boosts = {}

		if (cw.menu:GetOpen()) then
			local panel = cw.attributes:GetPanel()

			if (panel and cw.menu:GetActivePanel() == panel) then
				panel:Rebuild()
			end
		end
	end)
end
