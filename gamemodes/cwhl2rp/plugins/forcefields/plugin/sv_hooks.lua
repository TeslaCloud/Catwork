--- Called after Catwork has loaded the map entities; restores the saved forcefields.
function cwForceField:ClockworkInitPostEntity()
  self:LoadForceFields()
end

--- Called after data is saved; saves the forcefields.
function cwForceField:PostSaveData()
  self:SaveForceFields()
end

--- Called when an item is taken from a player; makes forcefields block them again.
--
-- Sets the `ShouldForceFieldCollide` net var to `true` when the player loses a
-- `combine_forcefield_card` and has fewer than two left.
--
-- @param player [Player The player who lost the item]
-- @param itemTable [Item The item taken]
function cwForceField:PlayerItemTaken(player, itemTable)
  if itemTable.uniqueID == 'combine_forcefield_card' and player:GetItemCountByID('combine_forcefield_card') < 2 then
    player:SetNetVar('ShouldForceFieldCollide', true)
  end
end

--- Called when a player is given an item; a forcefield card lets them pass through forcefields.
--
-- Sets the `ShouldForceFieldCollide` net var to `false` for a `combine_forcefield_card`.
--
-- @param player [Player The player given the item]
-- @param itemTable [Item The item given]
-- @param bForce [Boolean Whether the item was forced into the inventory]
function cwForceField:PlayerItemGiven(player, itemTable, bForce)
  if itemTable.uniqueID == 'combine_forcefield_card' then
    player:SetNetVar('ShouldForceFieldCollide', false)
  end
end
