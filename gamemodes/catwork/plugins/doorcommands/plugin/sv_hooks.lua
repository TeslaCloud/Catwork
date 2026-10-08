--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

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
