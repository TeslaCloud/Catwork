--[[
models/barnes/refugee/female_72.mdl
--]]

ITEM.baseItem = "clothes_base"
ITEM.name = "Biohazard suit";
ITEM.replacement = "models/industrial_uniforms/industrial_uniform.mdl";
ITEM.weight = 3;
ITEM.access = "m";
ITEM.business = false;
ITEM.protection = 0.4;
ITEM.description = "Black unifrm with armor plates on it and with NVG";
ITEM.radProtection = true

-- Called when a replacement is needed for a player.
function ITEM:GetReplacement(player)
	if (string.lower(player:GetModel()) == "models/humans/group01/jasona.mdl") then
		return "models/industrial_uniforms/industrial_uniform.mdl"
	end
end