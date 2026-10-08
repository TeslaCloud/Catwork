--- Client-side hooks of the Third Person plugin that create the `cwThirdPerson` client convar and run the `chasecam`
-- console command whenever it changes.
--
-- `Initialize` stores the convar as `CW_CONVAR_THIRDPERSON`, and `ClockworkConVarChanged` runs `chasecam 1` or
-- `chasecam 0` to match it.

local PLUGIN = PLUGIN

--- Called when the client initializes; creates the `cwThirdPerson` client convar as `CW_CONVAR_THIRDPERSON`.
function PLUGIN:Initialize()
  CW_CONVAR_THIRDPERSON = cw.core:CreateClientConVar('cwThirdPerson', 0, false, true)
end

--- Called when a Catwork client convar changes; runs `chasecam` to match the `cwThirdPerson` setting.
-- @param name [String The convar name]
-- @param previousValue [String The previous value]
-- @param newValue [String The new value]
function PLUGIN:ClockworkConVarChanged(name, previousValue, newValue)
  if name != 'cwThirdPerson' then return end

  if CW_CONVAR_THIRDPERSON:GetInt() == 1 then
    RunConsoleCommand('chasecam', '1')
  else
    RunConsoleCommand('chasecam', '0')
  end
end
