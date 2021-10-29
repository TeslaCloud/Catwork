--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.
--]]

local playerMeta = FindMetaTable("Player")

function playerMeta:HasPermission(id)
	id = (isstring(id) and string.lower(id)) or false

	if (!id or id == "") then return end

	local permissions = self:GetData("permissions", {})

	return permissions[id]
end

if (SERVER) then
	function playerMeta:SetPermission(id, value)
		if (!isstring(id)) then return end

		local permissions = self:GetData("permissions", {})
		local bHasChanged = (permissions[id] != value)

		permissions[id] = value

		self:SetData("permissions", permissions)

		return bHasChanged
	end

	function playerMeta:GivePermission(id)
		self:SetPermission(id, true)
	end

	function playerMeta:TakePermission(id)
		self:SetPermission(id, false)
	end
end
