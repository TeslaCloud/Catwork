--- Server-side hooks of the Door Commands plugin that restore the saved door data when the map loads and save the door
-- states along with the rest of the data.
--
-- Door states are only saved and restored when the `doors_save_state` config is on.

--- Called after Catwork has loaded all map entities; restores the saved door parents, names and
-- ownability, and the saved open and locked states when `doors_save_state` is enabled.
function cwDoorCmds:ClockworkInitPostEntity()
  self:LoadParentData()
  self:LoadDoorData()

  if config.Get('doors_save_state'):Get() then
    self:LoadDoorStates()
  end
end

--- Called just after data is saved; saves the door states when `doors_save_state` is enabled and at
-- least one player is connected.
function cwDoorCmds:PostSaveData()
  if config.Get('doors_save_state'):Get() and #player.GetAll() > 0 then
    self:SaveDoorStates()
  end
end
