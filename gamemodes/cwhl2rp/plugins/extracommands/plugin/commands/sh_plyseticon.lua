--- Registers the superadmin command `/PlySetIcon` of the Extra Commands plugin, which gives the target player a custom
-- PNG icon from a local path or a URL and sends it to clients.

local COMMAND = cw.command:New('PlySetIcon')
COMMAND.tip = '#Command_Plyseticon_Description'
COMMAND.text = '#Command_Plyseticon_Syntax'
COMMAND.access = 's'
COMMAND.arguments = 2
COMMAND.alias = { 'SetIcon' }

--- Sets a custom PNG icon for the target player and sends it to clients.
--
-- The icon is a local path or an http(s) URL; URLs are cached as `catwork/icon_<SteamID64>.png`.
-- Stored in the player's `CustomIcon` data and sent with `Schema:SendIconData`.
function COMMAND:OnRun(player, arguments)
  local target = _player.Find(arguments[1])
  local icon = arguments[2]
  local bIsIcon = icon:lower():EndsWith('.png')

  if IsValid(target) then
    if bIsIcon then
      local path = ''

      if icon:find('^http[s]?://') then
        path = 'catwork/icon_'..target:SteamID64()..'.png'
      else
        path = icon
      end

      target:SetData('CustomIcon', { icon = icon, path = path })
      Schema:SendIconData(target, true)

      cw.player:Notify(player, L('ExtraCommands_IconSet', target:Name())..' '..icon..' ['..path..'].')
    else
      cw.player:Notify(player, arguments[2]..' '..L('ExtraCommands_NotPng'))
    end
  else
    cw.player:Notify(player, L('NotValidPlayer', arguments[1]))
  end
end

COMMAND:Register()
