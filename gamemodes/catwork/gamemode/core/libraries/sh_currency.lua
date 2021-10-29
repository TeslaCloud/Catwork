--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

library.New("currency", cw)

local stored = cw.currency.stored or {}
cw.currency.stored = stored

--[[ Set the __index meta function of the class. --]]
local CLASS_TABLE = {__index = CLASS_TABLE}

function CLASS_TABLE:__call(parameter, failSafe)
	return self:Query(parameter, failSafe)
end

function CLASS_TABLE:Create(name)
	local object = cw.core:NewMetaTable(CLASS_TABLE)
		object.name = name
		object.data = {}
	return object
end

function CLASS_TABLE:Query(key, failSafe)
	if (self.data and self.data[key] != nil) then
		return self.data[key]
	else
		return failSafe
	end
end

function CLASS_TABLE:SetData(key, value)
	if (self.data) then
		self.data[key] = value
	end

	stored[key] = self
end

function CLASS_TABLE:GetModel()
	return self("model", "models/props_c17/briefcase001a.mdl")
end

function CLASS_TABLE:SetModel(model)
	self:SetData("model", model)
end

function CLASS_TABLE:GetDefault()
	return self("default", 0)
end

function CLASS_TABLE:SetDefault(amount)
	self:SetData("default", amount)
end

-- A function to add a currency.
function cw.currency:Add(name, model, defaultValue)
	local key = string.lower(string.gsub(name, "%s", "_"))

	if (!stored[key]) then
		local currencyObject = CLASS_TABLE:Create(name)

		if (model != nil) then
			currencyObject:SetModel(model)
		end

		if (defaultValue != 0) then
			currencyObject:SetDefault(defaultValue)
		end

		if (currencyObject.data) then
			stored[key] = currencyObject
		end

		return currencyObject
	end
end

-- A function to get a currency table.
function cw.currency:Get(name)
	if (config.Get("cash_enabled"):Get()) then
		local key = string.lower(string.gsub(name, "%s", "_"))

		if (!stored[key]) then
			return self:Add(name)
		else
			return stored[key]
		end
	else
		return {}
	end
end

-- A function to get all of the stored currencies.
function cw.currency:GetAll()
	if (config.Get("cash_enabled"):Get()) then
		return stored
	else
		return {}
	end
end
