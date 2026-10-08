--- Server-side hooks of the Force Fields plugin, which load and save the forcefields with the map, let holders of a
-- `combine_forcefield_card` item pass through them and stop players from getting up next to one.
--
-- `PlayerCharacterLoaded`, `PlayerItemGiven` and `PlayerItemTaken` set the player's `ShouldForceFieldCollide` net var,
-- which the plugin's `ShouldCollide` hook reads.

--- Called after Catwork has loaded the map entities; restores the saved forcefields.
function cwForceField:ClockworkInitPostEntity()
  self:LoadForceFields()
end

--- Called after data is saved; saves the forcefields.
function cwForceField:PostSaveData()
  self:SaveForceFields()
end

--- Called when a player's character has loaded; sets whether forcefields block them.
--
-- The `ShouldForceFieldCollide` net var would otherwise keep the value of the character played before.
--
-- @param player [Player The player whose character loaded]
function cwForceField:PlayerCharacterLoaded(player)
  player:SetNetVar('ShouldForceFieldCollide', !player:HasItemByID('combine_forcefield_card'))
end

--- Called when a fallen over player attempts to get up; blocks it within 50 units of a forcefield.
--
-- The client's hook of the same name only hides the hint.
--
-- @param player [Player The player getting up]
-- @return [Boolean `false` near a forcefield, otherwise `nil`]
function cwForceField:PlayerCanGetUp(player)
  local ragdoll = player:GetRagdollEntity()
  local position = (IsValid(ragdoll) and ragdoll:GetPos()) or player:GetPos()

  for k, v in ipairs(ents.FindInSphere(position, 50)) do
    if v:GetClass() == 'cw_forcefield' then
      return false
    end
  end
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
