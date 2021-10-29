--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

-- Called when an entity's target ID HUD should be painted.
function cwStorage:HUDPaintEntityTargetID(entity, info)
	local colorTargetID = cw.option:GetColor("target_id")
	local colorWhite = cw.option:GetColor("white")

	if (cw.entity:IsPhysicsEntity(entity)) then
		local model = string.lower(entity:GetModel())

		if (self.containerList[model]) then
			if (entity:GetNetworkedString("Name") != "") then
				info.y = cw.core:DrawInfo(entity:GetNetworkedString("Name"), info.x, info.y, colorTargetID, info.alpha)
			else
				info.y = cw.core:DrawInfo(self.containerList[model][2], info.x, info.y, colorTargetID, info.alpha)
			end

			info.y = cw.core:DrawInfo("Вы можете положить сюда что-нибудь.", info.x, info.y, colorWhite, info.alpha)
		end
	end
end

-- Called when an entity's menu options are needed.
function cwStorage:GetEntityMenuOptions(entity, options)
	if (cw.entity:IsPhysicsEntity(entity)) then
		local model = string.lower(entity:GetModel())

		if (self.containerList[model]) then
			options["Открыть"] = "cwContainerOpen"
		end
	end
end

-- Called when the local player's storage is rebuilt.
function cwStorage:PlayerStorageRebuilt(panel, categories)
	if (panel.storageType == "Container") then
		local entity = cw.storage:GetEntity()

		if (IsValid(entity) and entity.cwMessage) then
			local messageForm = vgui.Create("DForm", panel)
			local helpText = messageForm:Help(entity.cwMessage)
				messageForm:SetPadding(5)
				messageForm:SetName("Сообщение")
				helpText:SetFont("Default")
			panel:AddItem(messageForm)
		end
	end
end
