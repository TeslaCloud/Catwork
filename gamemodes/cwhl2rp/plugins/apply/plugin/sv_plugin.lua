--- Server-side part of the Apply plugin, which adds the `apply_recognise_enable` config, on by default, and defines
-- `PLUGIN:RecogniseNearby`, used by the plugin's commands.

local PLUGIN = PLUGIN

config.Add('apply_recognise_enable', true)

--- Makes the players around a player recognise them, when the `apply_recognise_enable` config is on.
-- @param player [Player The player who introduced themselves]
-- @param radius [Number How far away other players still recognise them]
function PLUGIN:RecogniseNearby(player, radius)
  if !config.Get('apply_recognise_enable'):Get() then return end

  local position = player:GetPos()
  local radiusSqr = radius * radius

  for k, v in ipairs(_player.GetAll()) do
    if v:HasInitialized() and v:GetPos():DistToSqr(position) <= radiusSqr then
      cw.player:SetRecognises(v, player, RECOGNISE_TOTAL)
    end
  end
end
