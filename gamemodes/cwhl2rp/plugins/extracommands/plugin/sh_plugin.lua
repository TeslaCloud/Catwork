--[[
	© 2016 TeslaCloud Studios.
	Feel free to use, edit or share the plugin, but
	do not re-distribute without the permission of it's author.
--]]

if (SERVER) then
	function PLUGIN:PostPlayerSpawn(player, lightSpawn, changeClass, firstSpawn)
		local bodyGroup = player:GetCharacterData("CustomBodyGroup")
		local skin = player:GetCharacterData("CustomSkin")

		if (istable(bodyGroup)) then
			for k, v in pairs(bodyGroup) do
				player:SetBodygroup(k, v)
			end
		end

		if (skin) then
			player:SetSkin(skin)
		end
	end

	function PLUGIN:PlayerUnragdolled(player, state, ragdollTable)
		local bodyGroup = player:GetCharacterData("CustomBodyGroup")

		if (istable(bodyGroup)) then
			for k, v in pairs(bodyGroup) do
				player:SetBodygroup(k, v)
			end
		end
	end
end