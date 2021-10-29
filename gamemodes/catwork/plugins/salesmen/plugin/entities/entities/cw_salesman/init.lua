--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

util.Include("shared.lua")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

-- Called when the entity initializes.
function ENT:Initialize()
	self:DrawShadow(true)
	self:SetSolid(SOLID_BBOX)
	self:PhysicsInit(SOLID_BBOX)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetUseType(SIMPLE_USE)
end

-- A function to setup the salesman.
function ENT:SetupSalesman(name, physDesc, animation, bShowChatBubble)
	self:SetNetworkedString("Name", name)
	self:SetNetworkedString("PhysDesc", physDesc)
	self:SetupAnimation(animation)

	if (bShowChatBubble) then
		self:MakeChatBubble()
	end
end

-- A function to talk to a player.
function ENT:TalkToPlayer(player, text, default)
	local sayString = text.text or default

	if (text.bHideName != true) then
		sayString = self:GetNetworkedString("Name").." говорит \""..sayString.."\""
	end

	if (!text.text or (text.text and text.text != "")) then
		cw.player:Notify(player, sayString)
	end

	if (text.sound and text.sound != "") then
		netstream.Start(player, "SalesmanPlaySound", {text.sound, self})
	end
end

-- Called to setup the animation.
function ENT:SetupAnimation(animation)
	if (animation and animation != -1) then
		self:ResetSequence(animation)
	else
		self:ResetSequence(4)
	end
end

-- Called to make the chat bubble.
function ENT:MakeChatBubble()
	self.cwChatBubble = ents.Create("cw_chatbubble")
	self.cwChatBubble:SetParent(self)
	self.cwChatBubble:SetPos(self:GetPos() + Vector(0, 0, 90))
	self.cwChatBubble:SetNWEntity("salesman", self)
	self.cwChatBubble:Spawn()
end

-- A function to get the chat bubble.
function ENT:GetChatBubble()
	return self.cwChatBubble
end

-- Called when the entity is used.
function ENT:Use(activator, caller)
	if (IsValid(activator) and activator:IsPlayer()) then
		if (activator:GetEyeTraceNoCursor().HitPos:Distance(self:GetPos()) < 196) then
			if (hook.Run("PlayerCanUseSalesman", activator, self) != false) then
				hook.Run("PlayerUseSalesman", activator, self)
			end
		end
	end
end
