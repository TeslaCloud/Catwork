--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

library.New("flag", cw)

local stored = cw.flag.stored or {}
cw.flag.stored = stored

-- A function to add a new flag.
function cw.flag:Add(flag, name, details)
	if (CLIENT and !stored[flag]) then
		cw.directory:AddCode("Flags", [[
			<tr>
				<td class="cwTableContent"><b><font color="red">]]..flag..[[</font></b></td>
				<td class="cwTableContent"><i>]]..details..[[</i></td>
			</tr>
		]], nil, flag, function(htmlCode, sortData)
			if (cw.player:HasFlags(cw.client, sortData)) then
				return cw.core:Replace(cw.core:Replace(htmlCode, [[<font color="red">]], [[<font color="green">]]), "</font>", "</font>")
			else
				return htmlCode
			end
		end)
	end

	stored[flag] = {
		name = name,
		details = details
	}
end

-- A function to get a flag.
function cw.flag:Get(flag)
	return stored[flag]
end

-- A function to get the stored flags.
function cw.flag:GetStored()
	return stored
end

-- A function to get a flag's name.
function cw.flag:GetName(flag, default)
	if (stored[flag]) then
		return stored[flag].name
	else
		return default
	end
end

-- A function to get a flag's details.
function cw.flag:GetDescription(flag, default)
	if (stored[flag]) then
		return stored[flag].details
	else
		return default
	end
end

-- A function to get a flag by it's name.
function cw.flag:GetFlagByName(name, default)
	local lowerName = string.lower(name)

	for k, v in pairs(stored) do
		if (string.lower(v.name) == lowerName) then
			return k
		end
	end

	return default
end

cw.flag:Add("C", "Spawn Vehicles", "Access to spawn vehicles.")
cw.flag:Add("r", "Spawn Ragdolls", "Access to spawn ragdolls.")
cw.flag:Add("c", "Spawn Chairs", "Access to spawn chairs.")
cw.flag:Add("e", "Spawn Props", "Access to spawn props.")
cw.flag:Add("p", "Physics Gun", "Access to the physics gun.")
cw.flag:Add("n", "Spawn NPCs", "Access to spawn NPCs.")
cw.flag:Add("t", "Tool Gun", "Access to the tool gun.")
cw.flag:Add("G", "Give Item", "Access to the give items.")
cw.flag:Add("D", "Door Access", "Access to manipulate all doors.")
cw.flag:Add("x", "Voice Access", "Access to voice chat.");
