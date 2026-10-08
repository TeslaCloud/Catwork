--- Defines the `ammo_base` base item for ammunition: using one gives `ammoAmount` rounds of `ammoClass` if the player
-- carries a weapon that takes that ammo.
--
-- Each instance has a networked `Rounds` data field, and the item's weight and space scale with the rounds left.

ITEM.isBaseItem = true
ITEM.name = 'Ammo Base'
ITEM.useText = 'Load'
ITEM.useSound = false
ITEM.category = 'Ammunition'
ITEM.ammoClass = 'pistol'
ITEM.ammoAmount = 0
ITEM.roundsText = 'Rounds'
ITEM:AddData('Rounds', -1, true)

--- Returns the item's weight scaled by the rounds left out of `ammoAmount`.
-- @return [Number The weight of the remaining rounds]
function ITEM:GetItemWeight()
  return (self.weight / self.ammoAmount) * self:GetData('Rounds')
end

--- Returns the item's inventory space scaled by the rounds left out of `ammoAmount`.
-- @return [Number The space taken by the remaining rounds]
function ITEM:GetItemSpace()
  return (self.space / self.ammoAmount) * self:GetData('Rounds')
end

--- Gives `ammoAmount` rounds of `ammoClass` if the player carries a weapon that uses it, consuming the item.
-- @return [Boolean `false` (keeping the item) when no carried weapon uses this ammo, otherwise `nil`]
function ITEM:OnUse(player, itemEntity)
  local ammoAmount = self.ammoAmount
  local ammoClass = string.lower(self.ammoClass)

  for k, v in pairs(player:GetWeapons()) do
    local itemTable = item.GetByWeapon(v)

    -- Engine weapons have no `Primary` and `Secondary` tables.
    if itemTable and (string.lower(tostring(itemTable.primaryAmmoClass)) == ammoClass
    or string.lower(tostring(itemTable.secondaryAmmoClass)) == ammoClass
    or (v.Primary and string.lower(tostring(v.Primary.Ammo)) == ammoClass)
    or (v.Secondary and string.lower(tostring(v.Secondary.Ammo)) == ammoClass)) then
      player:GiveAmmo(ammoAmount, ammoClass)

      return
    end
  end

  cw.player:Notify(
    player, '#WeaponUsesAmmo'
  )

  return false
end

--- Called when a player drops the ammo; does nothing, so dropping is allowed.
function ITEM:OnDrop(player, position) end

if SERVER then
  --- Sets the new instance's `Rounds` data from the item's `ammoCount` field.
  function ITEM:OnInstantiated()
    self:SetData('Rounds', self.ammoCount)
  end
else
  --- Returns the tooltip line showing how many rounds the item holds.
  -- @return [String Markup line with `roundsText` and `ammoAmount`]
  function ITEM:GetClientSideInfo()
    return cw.core:AddMarkupLine(
      '', L(self.roundsText)..': '..self.ammoAmount
    )
  end
end
