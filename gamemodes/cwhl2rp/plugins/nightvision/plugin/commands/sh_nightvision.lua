--- Registers the `/Nightvision` command of the Nightvision plugin, which toggles night vision for players allowed to
-- use it by flipping their `nightvisionfx` networked boolean.

local Clockwork = Clockwork

local COMMAND = cw.command:New('Nightvision')
COMMAND.tip = '#Command_Nightvision_Description'
COMMAND.text = ''
COMMAND.flags = bit.bor(CMD_DEFAULT, CMD_DEATHCODE, CMD_FALLENOVER)
COMMAND.arguments = 0

--- Toggles night vision for players allowed to use it, with the goggle on or off sound.
--
-- The state is stored in the `nightvisionfx` networked boolean, which drives the client effect.
function COMMAND:OnRun(player, arguments)
  if Schema:PlayerCanUseNightvision(player) then
    if player:GetNWBool('nightvisionfx') then
      player:EmitSound(Sound('items/nvg_off.wav'))
      player:SetNWBool('nightvisionfx', false)
    else
      player:EmitSound(Sound('items/nvg_on.wav'))
      player:SetNWBool('nightvisionfx', true)
    end
  else
    cw.player:Notify(player, L('Nightvision_NoGoggles'))
  end
end

COMMAND:Register()
