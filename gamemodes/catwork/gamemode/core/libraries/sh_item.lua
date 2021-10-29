--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

library.New("item", _G)

local stored = item.stored or {}
item.stored = stored

local buffer = item.buffer or {}
item.buffer = buffer

local weapons = item.weapons or {}
item.weapons = weapons

local instances = item.instances or {}
item.instances = instances

function item.GetStored()
	return stored
end

function item.GetBuffer()
	return buffer
end

function item.GetWeapons()
	return weapons
end

function item.GetInstances()
	return instances
end

--[[
	Begin defining the item class base for other item's to inherit from.
--]]

--[[ Set the __index meta function of the class. --]]
class "CItem"

CItem.name = "Item Base"
CItem.skin = 0
CItem.cost = 0
CItem.batch = 5
CItem.model = "models/error.mdl"
CItem.weight = 1
CItem.space = 1
CItem.itemID = 0
CItem.business = false
CItem.category = "Other"
CItem.description = "An item with no description."
CItem.proxies = {}

-- Call it in the constructor.
function CItem:CItem()

end

-- Called when the item is converted to a string.
function CItem:__tostring()
	return "ITEM["..self.itemID.."]"
end

function CItem:GetVar(varName, failSafe)
	--[[
		Check data first. We may be overriding this value
		or simply want to return it instead.
	--]]
	if (self.data[varName] != nil) then
		return self.data[varName]
	end

	local replacement = self.proxies[varName]

	if (isstring(replacement)) then
		varName = replacement
	elseif (isfunction(replacement)) then
		return replacement(self)
	end

	if (CLIENT) then
		if (varName:lower() == "name") then
			if (isstring(self.PrintName)) then
				varName = "PrintName"
			end
		end

		local var = self[varName]

		if (isstring(var)) then
			return cw.lang:TranslateText(var)
		end
	end

	return (self[varName] != nil and self[varName]) or failSafe
end

function CItem:AddQueryProxy(var, replacement)
	self.proxies[var] = replacement
end

--[[
	A function to override an item's base data. This is
	just a nicer way to set a value to go along with
	the method of querying.
--]]
function CItem:Override(varName, value)
	self[varName] = value
end

-- A function to add data to an item.
function CItem:AddData(dataName, value, bNetworked)
	self.data[dataName] = value
	self.defaultData[dataName] = value
	self.networkData[dataName] = bNetworked
end

-- A function to remove data from an item.
function CItem:RemoveData(dataName)
	self.data[dataName] = nil
	self.defaultData[dataName] = nil
	self.networkData[dataName] = nil
end

-- A function to get whether an item has the same data as another.
function item.HasSameDataAs(itemTable)
	return cw.core:AreTablesEqual(item.data, itemTable.data)
end

-- A function to get whether the item is an instance.
function CItem:IsInstance()
	return (self.itemID != 0)
end

-- A function to get whether the item is based from another.
function CItem:IsBasedFrom(uniqueID)
	local itemTable = self

	if (itemTable.uniqueID == uniqueID) then
		return true
	end

	while (itemTable and itemTable.baseItem) do
		if (itemTable.baseItem == uniqueID) then
			return true
		end

		itemTable = item.FindByID(itemTable.baseItem)
	end

	return false
end

-- A function to get a base class table from the item.
function CItem:GetBaseClass(uniqueID)
	return item.FindByID(uniqueID)
end

-- A function to get whether the item can be ordered.
function CItem:CanBeOrdered()
	return (!self.isBaseItem and self.business)
end

-- A function to get data from the item.
function CItem:GetData(dataName, default)
	return self.data[dataName] or self[dataName] or default
end

-- A function to add a new recipe for this item.
function CItem:AddRecipe(...)
	local arguments = {...}
	local currentItem = nil
	local recipeTable = {ingredients = {}}

	for k, v in pairs(arguments) do
		if (type(v) == "string") then
			currentItem = v
		elseif (type(v) == "number") then
			if (currentItem) then
				recipeTable.ingredients[currentItem] = v
			end
		end
	end

	self.recipes[#self.recipes + 1] = recipeTable

	return recipeTable
end

-- A function to get whether two items are the same.
function CItem:IsTheSameAs(itemTable)
	if (itemTable) then
		return (itemTable.uniqueID == self.uniqueID
		and itemTable.itemID == self.itemID)
	else
		return false
	end
end

-- A function to get whether data is networked.
function CItem:IsDataNetworked(key)
	return (self.networkData[key] == true)
end

if (SERVER) then
	-- A function to deduct neccessary funds from a plater after ordering.
	function CItem:DeductFunds(player)
		if (#self.recipes > 0) then
			for k, v in pairs(self.recipes) do
				if (cw.core:HasObjectAccess(player, v)) then
					local hasIngredients = true

					for k2, v2 in pairs(v.ingredients) do
						if (table.Count(player:GetItemsByID(k2)) < v2) then
							hasIngredients = false
						end
					end

					if (hasIngredients) then
						for k2, v2 in pairs(v.ingredients) do
							for i = 1, v2 do
								player:TakeItemByID(k2)
							end
						end

						break
					end
				end
			end
		end

		if (self.cost == 0) then
			return
		end

		if (self.batch > 1) then
			cw.player:GiveCash(player, -(self.cost * self.batch), self.batch.." "..cw.core:Pluralize(self.PrintName))
			cw.core:PrintLog(LOGTYPE_MINOR, player:Name().." has ordered "..self.batch.." "..cw.core:Pluralize(self.PrintName)..".")
		else
			cw.player:GiveCash(player, -(self.cost * self.batch), self.batch.." "..self.PrintName)
			cw.core:PrintLog(LOGTYPE_MINOR, player:Name().." has ordered "..self.batch.." "..self.PrintName..".")
		end
	end

	-- A function to get whether a player can afford to order the item.
	function CItem:CanPlayerAfford(player)
		if (!cw.player:CanAfford(player, self.cost * self.batch)) then
			return false
		end

		if (#self.recipes > 0) then
			for k, v in pairs(self.recipes) do
				if (cw.core:HasObjectAccess(player, v)) then
					local hasIngredients = true

					for k2, v2 in pairs(v.ingredients) do
						local itemList = player:GetItemsByID(k2)

						if (!itemList or table.Count(itemList) < v2) then
							hasIngredients = false
						end
					end

					if (hasIngredients) then
						return true
					end
				end
			end

			return false
		end

		return true
	end
end

-- A function to register a new item.
function CItem:Register()
	return item.Register(self)
end

if (SERVER) then
	function CItem:SetData(dataName, value)
		if (self:IsInstance() and self.data[dataName] != nil and self.data[dataName] != value) then
			self.data[dataName] = value

			if (self:IsDataNetworked(dataName)) then
				self.networkQueue[dataName] = value
				self:NetworkData()
			end
		end
	end

	-- A function to network the item data.
	function CItem:NetworkData()
		local timerName = "NetworkItem"..self.itemID

		if (timer.Exists(timerName)) then
			return
		end

		timer.Create(timerName, 1, 1, function()
			item.SendUpdate(
				self, self.networkQueue
			)
			self.networkQueue = {}
		end)
	end
else
	function CItem:SubmitOption(option, data, entity)
		netstream.Start("MenuOption", {option = option, data = data, item = self.itemID, entity = entity})
	end
end

--[[
	End defining the base item class and begin defining
	the item utility functions.
--]]

-- A function to get the item buffer.
function item.GetBuffer()
	return buffer
end

-- A function to get all items.
function item.GetAll()
	return stored
end

-- A function to get a new item.
function item.New(uniqueID)
	local object = CItem()
		object.networkQueue = {}
		object.networkData = {}
		object.defaultData = {}
		object.recipes = {}
		object.isBaseItem = nil
		object.baseItem = nil
		object.uniqueID = uniqueID
		object.data = {}
	return object
end

-- A function to register a new item.
function item.Register(itemTable)
	itemTable.uniqueID = string.lower(string.gsub(itemTable.uniqueID or string.gsub(itemTable.name, "%s", "_"), "['%.]", ""))
	itemTable.index = cw.core:GetShortCRC(itemTable.uniqueID)
	itemTable.PrintName = itemTable.PrintName or itemTable.name or "Unknown Item"

	stored[itemTable.uniqueID] = itemTable
	buffer[itemTable.index] = itemTable

	if (!_G["cwSharedBooted"]) then
		if (itemTable.model) then
			if (SERVER) then
				cw.core:AddFile(itemTable.model)
			end
		end

		if (itemTable.attachmentModel) then
			if (SERVER) then
				cw.core:AddFile(itemTable.attachmentModel)
			end
		end

		if (itemTable.replacement) then
			if (SERVER) then
				cw.core:AddFile(itemTable.replacement)
			end
		end
	end
end

-- A function to restore item's functions.
function item.Validate(itemTable, bShouldMerge)
	if (istable(itemTable)) then
		if (!isfunction(itemTable.Register)) then
			local blankItem = CItem()
			local oldItem = table.Copy(itemTable)

			setmetatable(itemTable, CItem)

			table.SafeMerge(itemTable, blankItem)
			table.SafeMerge(itemTable, oldItem)
		end

		if (bShouldMerge) then
			local template = item.FindByID(itemTable.uniqueID)

			if (template) then
				local copy = table.Copy(template)

				table.SafeMerge(copy, itemTable)

				itemTable = copy
			end
		end

		return itemTable
	end
end

-- A function to create a copy of an item instance.
function item.CreateCopy(itemTable)
	item.Validate(itemTable)

	return item.CreateInstance(
		itemTable.uniqueID, nil, itemTable.data
	)
end

-- A function to get whether an item is a weapon.
function item.IsWeapon(itemTable)
	item.Validate(itemTable)

	if (itemTable and itemTable:IsBasedFrom("weapon_base")) then
		return true
	end

	return false
end

-- A function to get a weapon instance by its object.
function item.GetByWeapon(weapon)
	item.Validate(itemTable)

	if (IsValid(weapon)) then
		local itemID = tonumber(weapon:GetNWString("ItemID"))
		if (itemID and itemID != 0) then
			return item.FindInstance(itemID)
		end
	end
end

-- A function to create an instance of an item.
function item.CreateInstance(uniqueID, itemID, data, customData)
	local itemTable = item.FindByID(uniqueID)
	
	item.Validate(itemTable)

	if (itemID) then itemID = tonumber(itemID) end

	if (itemTable) then
		if (!itemID) then
			itemID = item.GenerateID()
		end

		if (!instances[itemID]) then
			instances[itemID] = table.Copy(itemTable)
			instances[itemID].itemID = itemID
		end

		if (data) then
			table.Merge(instances[itemID].data, data)
		end

		if (customData) then
			table.Merge(instances[itemID], customData)
		end

		if (instances[itemID].OnInstantiated) then
			instances[itemID]:OnInstantiated()
		end

		return instances[itemID]
	end
end

do
	--[[ Just to make sure we never ever get the same ID. --]]
	local ITEM_INDEX = item.ITEM_INDEX or 0
	item.ITEM_INDEX = ITEM_INDEX

	-- A function to generate an item ID.
	function item.GenerateID()
		ITEM_INDEX = ITEM_INDEX + 1
		return os.time() + ITEM_INDEX
	end
end

-- A function to find an instance of an item.
function item.FindInstance(itemID)
	return instances[tonumber(itemID)]
end

-- A function to get an item definition.
function item.GetDefinition(itemTable, bNetworkData)
	item.Validate(itemTable)

	local definition = {
		itemID = itemTable.itemID,
		index = itemTable.index,
		data = {}
	}

	if (bNetworkData) then
		for k, v in pairs(itemTable.networkData) do
			definition.data[k] = itemTable:GetData(k)
		end
	end

	return definition
end

-- A function to get an item signature.
function item.GetSignature(itemTable)
	item.Validate(itemTable)

	return {uniqueID = itemTable.uniqueID, itemID = itemTable.itemID}
end

-- A function to get an item by its name.
function item.FindByID(identifier, bShouldValidate)
	if (!isbool(identifier) and identifier and identifier != 0) then
		if (buffer[identifier]) then
			return item.Validate(buffer[identifier], bShouldValidate)
		elseif (stored[identifier]) then
			return item.Validate(stored[identifier], bShouldValidate)
		elseif (weapons[identifier]) then
			return item.Validate(weapons[identifier], bShouldValidate)
		end

		local lowerName = string.utf8lower(identifier)
		local itemTable = nil

		for k, v in pairs(stored) do
			local itemName = v.name

			if (string.find(string.utf8lower(itemName), lowerName) and (!itemTable or string.utf8len(itemName) < string.utf8len(itemTable.name))) then
				itemTable = v
			end

			if (!itemTable and v.PrintName != itemName) then
				if (string.find(string.utf8lower(v.PrintName), lowerName)) then
					itemTable = v
				end
			end
		end

		return item.Validate(itemTable, bShouldValidate)
	end
end

-- A function to merge an item with a base item.
function item.Merge(itemTable, baseItem, bTemporary)
	item.Validate(itemTable, false)

	local baseTable = item.FindByID(baseItem)
	local isBaseItem = itemTable.isBaseItem

	if (baseTable and baseTable != itemTable) then
		local baseTableCopy = table.Copy(baseTable)

		if (baseTableCopy.baseItem) then
			baseTableCopy = item.Merge(
				baseTableCopy,
				baseTableCopy.baseItem,
				true
			)

			if (!baseTableCopy) then
				return
			end
		end

		table.Merge(baseTableCopy, itemTable)

		if (!bTemporary) then
			baseTableCopy.baseClass = baseTable
			baseTableCopy.isBaseItem = isBaseItem
			item.Register(baseTableCopy)
		end

		return baseTableCopy
	end
end

function item.Initialize()
	local itemsTable = item.GetAll()

	for k, v in pairs(itemsTable) do
		if (v.baseItem and !item.Merge(v, v.baseItem)) then
			itemsTable[k] = nil
		end
	end

	for k, v in pairs(itemsTable) do
		if (v.baseItem) then
			item.Merge(v, v.baseItem)
		end

		if (v.OnSetup) then v:OnSetup() end

		if (item.IsWeapon(v)) then
			weapons[(v.weaponClass or v.uniqueID)] = v
		end

		hook.Run("ClockworkItemInitialized", v)
	end

	hook.Run("ClockworkPostItemsInitialized", itemsTable)
end

if (SERVER) then
	local entities = item.entities or {}
	item.entities = entities

	-- A function to use an item for a player.
	function item.Use(player, itemTable, bNoSound)
		local itemEntity = player:GetItemEntity()

		itemTable = item.Validate(itemTable, true)

		if (player:HasItemInstance(itemTable)) then
			if (itemTable.OnUse) then
				if (itemEntity and itemEntity.cwItemTable == itemTable) then
					player:SetItemEntity(nil)
				end

				local onUse = itemTable:OnUse(player, itemEntity)

				if (onUse == nil) then
					player:TakeItem(itemTable)
				elseif (onUse == false) then
					return false
				end

				if (!bNoSound) then
					local useSound = itemTable.useSound

					if (useSound) then
						if (type(useSound) == "table") then
							player:EmitSound(useSound[math.random(1, #useSound)])
						else
							player:EmitSound(useSound)
						end
					elseif (useSound != false) then
						player:EmitSound("weapons/universal/uni_pistol_holster.wav")
					end
				end

				hook.Run("PlayerUseItem", player, itemTable, itemEntity)

				return true
			end
		end
	end

	-- A function to drop an item from a player.
	function item.Drop(player, itemTable, position, bNoSound, bNoTake)
		item.Validate(itemTable)

		if (itemTable and (bNoTake or player:HasItemInstance(itemTable))) then
			local traceLine = nil
			local entity = nil

			if (itemTable.OnDrop) then
				if (!position) then
					traceLine = player:GetEyeTraceNoCursor()
					position = traceLine.HitPos
				end

				if (itemTable:OnDrop(player, position) == false) then
					return false
				end

				if (!bNoTake) then
					player:TakeItem(itemTable)
				end

				if (itemTable.OnCreateDropEntity) then
					entity = itemTable:OnCreateDropEntity(player, position)
				end

				if (!IsValid(entity)) then
					entity = cw.entity:CreateItem(player, itemTable, position)
				end

				if (IsValid(entity)) then
					if (traceLine and traceLine.HitNormal) then
						cw.entity:MakeFlushToGround(entity, position, traceLine.HitNormal)
					end
				end

				if (!bNoSound) then
					local dropSound = itemTable.dropSound

					if (dropSound) then
						if (type(dropSound) == "table") then
							player:EmitSound(dropSound[math.random(1, #dropSound)])
						else
							player:EmitSound(dropSound)
						end
					elseif (dropSound != false) then
						player:EmitSound("physics/body/body_medium_impact_soft"..math.random(1, 7)..".wav")
					end
				end

				hook.Run("PlayerDropItem", player, itemTable, position, entity)

				return true
			end
		end
	end

	-- A function to destroy a player's item.
	function item.Destroy(player, itemTable, bNoSound)
		item.Validate(itemTable)

		if (player:HasItemInstance(itemTable) and itemTable.OnDestroy) then
			if (itemTable:OnDestroy(player) == false) then
				return false
			end

			player:TakeItem(itemTable)

			if (!bNoSound) then
				local destroySound = itemTable.destroySound

				if (destroySound) then
					if (type(destroySound) == "table") then
						player:EmitSound(destroySound[math.random(1, #destroySound)])
					else
						player:EmitSound(destroySound)
					end
				elseif (destroySound != false) then
					player:EmitSound("physics/body/body_medium_impact_soft"..math.random(1, 7)..".wav")
				end
			end

			hook.Run("PlayerDestroyItem", player, itemTable)

			return true
		end
	end

	-- A function to remove an item entity.
	function item.RemoveItemEntity(entity)
		local itemTable = entity:GetItemTable()

		item.Validate(itemTable)

		entities[itemTable.itemID] = nil
	end

	-- A function to add an item entity.
	function item.AddItemEntity(entity, itemTable)
		item.Validate(itemTable)

		entities[itemTable.itemID] = entity
	end

	-- A function to find an entity by an instance.
	function item.FindEntityByInstance(itemTable)
		item.Validate(itemTable)

		local entity = entities[itemTable.itemID]

		if (IsValid(entity)) then
			return entity
		end
	end

	--[[
		@codebase Server
		@details A function to send an item to a player.
	--]]
	function item.SendToPlayer(player, itemTable)
		if (itemTable) then
			netstream.Start(
				player, "ItemData", item.GetDefinition(itemTable, true)
			)
		end
	end

	--[[
		@codebase Server
		@details A function to send an item update to it's observers.
		@returns Table The table of observers.
	--]]
	function item.SendUpdate(itemTable, data)
		item.Validate(itemTable)

		local info = {
			observers = {}, sendToAll = false
		}

		if (hook.Run("ItemGetNetworkObservers", itemTable, info)
		or info.sendToAll) then
			info.observers = nil
		end

		netstream.Start(info.observers, "InvNetwork", {
			itemID = itemTable.itemID,
			data = data
		})

		return info.observers
	end	
else
	function item.GetIconInfo(itemTable)
		item.Validate(itemTable)

		local model = itemTable.iconModel or itemTable.model
		local skin = itemTable.iconSkin or itemTable.skin

		if (itemTable.GetClientSideModel) then
			model = itemTable:GetClientSideModel()
		end

		if (itemTable.GetClientSideSkin) then
			skin = itemTable:GetClientSideSkin()
		end

		if (!model) then
			model = "models/props_c17/oildrum001.mdl"
		end

		return model, skin
	end

	-- A function to get an item's markup tooltip.
	function item.GetMarkupToolTip(itemTable, bBusinessStyle, Callback)
		item.Validate(itemTable)

		local informationColor = cw.option:GetColor("information")
		local description = itemTable.description
		local toolTip = itemTable.toolTip
		local weight = tostring(itemTable.weight).."кг"
		local space = tostring(itemTable.space).."л"
		local name = itemTable.PrintName

		if (CLIENT) then
			name = cw.lang:TranslateText(name)
			description = cw.lang:TranslateText(description)
		end

		local weightText = itemTable.weightText

		if (weightText) then
			weight = weightText
		end

		local spaceText = itemTable.spaceText

		if (spaceText) then
			space = spaceText
		end

		if (itemTable.GetClientSideName) then
			if (itemTable:GetClientSideName()) then
				name = itemTable:GetClientSideName()
			end
		end

		if (bBusinessStyle and itemTable.batch > 1) then
			name = itemTable.batch.." x "..cw.core:Pluralize(name)
		end

		local toolTipTitle = ""
		local toolTipColor = informationColor
		local markupObject = cw.theme:GetMarkupObject()

		if (itemTable.GetClientSideInfo
		and itemTable:GetClientSideInfo()) then
			toolTip = itemTable:GetClientSideInfo(markupObject)
		end

		if (itemTable.GetClientSideDescription
		and itemTable:GetClientSideDescription()) then
			description = itemTable:GetClientSideDescription()
		end

		local displayInfo = {
			itemTitle = nil,
			toolTip = toolTip,
			weight = weight,
			space = space,
			name = name
		}

		if (Callback) then
			Callback(displayInfo)
		end

		if (cw.inventory:UseSpaceSystem()) then
			toolTipTitle = displayInfo.name..", "..displayInfo.weight..", "..displayInfo.space
		else
			toolTipTitle = displayInfo.name..", "..displayInfo.weight
		end

		if (displayInfo.itemTitle) then
			toolTipTitle = displayInfo.itemTitle
		end

		if (itemTable.color) then
			toolTipColor = itemTable.color
		end

		markupObject:Title(toolTipTitle, toolTipColor)

		if (displayInfo.toolTip) then
			markupObject:Add(description)
			markupObject:Title(L("#ItemContextMenu_Information"))
			markupObject:Add(displayInfo.toolTip)
		else
			markupObject:Add(description)
		end

		if (bBusinessStyle) then
			local redColor = Color(255, 50, 50, 255)
			local greenColor = Color(50, 255, 50, 255)

			local totalCost = itemTable.cost * itemTable.batch

			if (config.Get("cash_enabled"):Get()
			and totalCost != 0) then
				local costString = cw.core:FormatCash(totalCost)
				local colorToUse = redColor

				if (cw.player:GetCash() >= totalCost) then
					colorToUse = greenColor
				end

				markupObject:Title(L("#ItemContextMenu_Price"))
				markupObject:Add(costString, colorToUse, 1)
			end
		end

		markupObject:Title(L("#ItemContextMenu_Category"))
		markupObject:Add(L(itemTable.category))

		return markupObject:GetText()
	end

	netstream.Hook("ItemData", function(data)
		item.CreateInstance(
			data.index, data.itemID, data.data
		)
	end)
end

pipeline.Register("item", function(uniqueID, fileName, pipe)
	ITEM = item.New(uniqueID)

	util.Include(fileName)

	ITEM:Register() ITEM = nil
end)

function item.IncludeItems(directory)
	pipeline.IncludeDirectory("item", directory)
end
