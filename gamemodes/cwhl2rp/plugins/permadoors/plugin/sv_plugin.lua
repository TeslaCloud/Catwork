--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

function cwPermaDoors:SetPermaDoor(player, door, title)
	local secretKey = player:GetCharacterData("PermaDoorSecret")

	if (!secretKey) then
		secretKey = "doorkey_"..math.random(0, 999999).."_"player:SteamID64()
		player:SetCharacterData("PermaDoorSecret", secretKey)
	end

	self.stored[door] = self.stored[door] or {}
	self.stored[door].secret = secretKey
	self.stored[door].text = player:Name()
	self.stored[door].name = title
	self.stored[door].position = door:GetPos()

	cw.entity:SetDoorUnownable(door, true)
	cw.entity:SetDoorText(door, player:Name())
	cw.entity:SetDoorName(door, title)

	self:SavePermaDoors()
end

function cwPermaDoors:ResetPermaDoor(door, title)
	self.stored[door] = self.stored[door] or {}
	self.stored[door].secret = "door_no_owner_"..math.random(0, 999999)
	self.stored[door].text = "#Door_Vacant"
	self.stored[door].name = title
	self.stored[door].position = door:GetPos()

	cw.entity:SetDoorUnownable(door, true)
	cw.entity:SetDoorText(door, "#Door_Vacant")
	cw.entity:SetDoorName(door, title)

	self:SavePermaDoors()
end
