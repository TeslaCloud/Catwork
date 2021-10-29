--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

netstream.Hook("StorageMessage", function(data)
	local entity = data.entity
	local message = data.message

	if (IsValid(entity)) then
		entity.cwMessage = message
	end
end)

netstream.Hook("ContainerPassword", function(data)
	local entity = data

	Derma_StringRequest("Пароль", "Какой пароль к этому контейнеру?", nil, function(text)
		netstream.Start("ContainerPassword", {text, entity})
	end)
end);
