--[[
  © 2016 TeslaCloud Studios.
  Feel free to use, edit or share the plugin, but
  do not re-distribute without the permission of it's author.
--]]

local COMMAND = cw.command:New('CharSetSkin')
COMMAND.tip = '#Command_Charsetskin_Description'
COMMAND.text = '#Command_Charsetskin_Syntax'
COMMAND.access = 'a'
COMMAND.arguments = 2
COMMAND.alias = { 'SetSkin', 'CharSkin' }

--- Sets the target character's skin and saves it so it is reapplied on spawn.
function COMMAND:OnRun(player, arguments)
  local target = _player.Find(arguments[1])
  local skin = tonumber(arguments[2])

  if skin != nil then
    if IsValid(target) then
      target:SetSkin(skin)
      target:SetCharacterData('CustomSkin', skin)
    end
  end
end

COMMAND:Register()
