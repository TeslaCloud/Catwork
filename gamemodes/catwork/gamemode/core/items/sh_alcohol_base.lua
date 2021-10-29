--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

ITEM.isBaseItem = true
ITEM.name = "Alcohol Base"
ITEM.useText = "Drink"
ITEM.category = "Consumables"
ITEM.useSound = {"npc/barnacle/barnacle_gulp1.wav", "npc/barnacle/barnacle_gulp2.wav"}
ITEM.expireTime = 1800
ITEM.attributes = {}

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	for k, v in pairs(self.attributes) do
		player:BoostAttribute(self.PrintName, k, v, self.expireTime)
	end

	cw.player:SetDrunk(player, self.expireTime)

	if (self.OnDrink) then
		self:OnDrink(player)
	end
end

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end
