--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

library.New('flag', cw)

local stored = cw.flag.stored or {}
cw.flag.stored = stored

--- Registers a player flag.
--
-- On the client the flag is also added to the Flags page of the directory, shown in green when
-- the local player has it. The details are translated when the page is shown.
--
-- ```
-- cw.flag:Add('x', 'Voice Access', '#Flag_VoiceAccess_Details')
-- ```
--
-- @param flag [String The single flag character]
-- @param name [String Display name of the flag]
-- @param details [String Description of what the flag allows, can be a language phrase]
function cw.flag:Add(flag, name, details)
  if CLIENT and !stored[flag] then
    cw.directory:AddCode('Flags', [[
			<tr>
				<td class="cwTableContent"><b><font color="red">]]..flag..[[</font></b></td>
				<td class="cwTableContent"><i>[details]</i></td>
			</tr>
		]], nil, flag, function(htmlCode, sortData)
      -- The details may be a language phrase, so they are translated when the page is shown.
      htmlCode = string.Replace(htmlCode, '[details]', cw.lang:TranslateText(details or ''))

      if cw.player:HasFlags(cw.client, sortData) then
        return cw.core:Replace(
          cw.core:Replace(htmlCode, [[<font color="red">]], [[<font color="green">]]),
          '</font>',
          '</font>'
        )
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

--- Returns a registered flag.
--
-- @param flag [String The flag character]
-- @return [Map The flag's `name` and `details`, or `nil` if it is not registered]
function cw.flag:Get(flag)
  return stored[flag]
end

--- Returns every registered flag.
--
-- @return [Map<Map> Flag tables with `name` and `details` keys, keyed by flag character]
function cw.flag:GetStored()
  return stored
end

--- Returns a flag's display name.
--
-- @param flag [String The flag character]
-- @param default=nil [Any Value returned when the flag is not registered]
-- @return [String The flag's name, or `default`]
function cw.flag:GetName(flag, default)
  if stored[flag] then
    return stored[flag].name
  else
    return default
  end
end

--- Returns a flag's details.
--
-- @param flag [String The flag character]
-- @param default=nil [Any Value returned when the flag is not registered]
-- @return [String The flag's details, or `default`]
function cw.flag:GetDescription(flag, default)
  if stored[flag] then
    return stored[flag].details
  else
    return default
  end
end

--- Finds a flag by its display name, ignoring case.
--
-- @param name [String Display name of the flag]
-- @param default=nil [Any Value returned when no flag has that name]
-- @return [String The flag character, or `default`]
function cw.flag:GetFlagByName(name, default)
  local lowerName = string.lower(name)

  for k, v in pairs(stored) do
    if string.lower(v.name) == lowerName then
      return k
    end
  end

  return default
end

cw.flag:Add('C', 'Spawn Vehicles', '#Flag_SpawnVehicles_Details')
cw.flag:Add('r', 'Spawn Ragdolls', '#Flag_SpawnRagdolls_Details')
cw.flag:Add('c', 'Spawn Chairs', '#Flag_SpawnChairs_Details')
cw.flag:Add('e', 'Spawn Props', '#Flag_SpawnProps_Details')
cw.flag:Add('p', 'Physics Gun', '#Flag_PhysicsGun_Details')
cw.flag:Add('n', 'Spawn NPCs', '#Flag_SpawnNPCs_Details')
cw.flag:Add('t', 'Tool Gun', '#Flag_ToolGun_Details')
cw.flag:Add('G', 'Give Item', '#Flag_GiveItem_Details')
cw.flag:Add('D', 'Door Access', '#Flag_DoorAccess_Details')
cw.flag:Add('x', 'Voice Access', '#Flag_VoiceAccess_Details')
