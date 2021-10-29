--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Author = "kurozael"
ENT.PrintName = "Salesman"
ENT.Spawnable = false
ENT.AdminSpawnable = false

-- Called when the entity is removed.
function ENT:OnRemove()
	if (SERVER and IsValid(self.cwChatBubble)) then
		self.cwChatBubble:Remove()
	end
end
