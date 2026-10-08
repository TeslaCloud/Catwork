local PLUGIN = PLUGIN

--- Called after Catwork has loaded all map entities; restores the saved vending machines.
function PLUGIN:ClockworkInitPostEntity()
  self:LoadNuttyVendingMachines()
end

--- Called when data should be saved; saves the vending machines on the current map.
function PLUGIN:SaveData()
  self:SaveNuttyVendingMachines()
end
