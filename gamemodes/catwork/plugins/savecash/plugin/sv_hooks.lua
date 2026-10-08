--- Server-side hooks of the Save Cash plugin that respawn the saved cash once the map's entities have loaded, if the
-- `cash_enabled` config is on, and save it whenever Catwork saves its data.

--- Called after Catwork has loaded all of its entities; restores saved cash when the `cash_enabled` config is on.
function cwSaveCash:ClockworkInitPostEntity()
  if config.Get('cash_enabled'):Get() then
    self:LoadCash()
  end
end

--- Called after Catwork saves its data; saves the cash lying on the map.
function cwSaveCash:PostSaveData()
  self:SaveCash()
end
