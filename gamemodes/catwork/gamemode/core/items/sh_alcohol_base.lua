--- Defines the `alcohol_base` base item for alcoholic drinks: drinking one boosts the item's `attributes` and makes the
-- player drunk for `expireTime` seconds, then calls the item's optional `OnDrink`.

ITEM.isBaseItem = true
ITEM.name = 'Alcohol Base'
ITEM.useText = 'Drink'
ITEM.category = 'Consumables'
ITEM.useSound = { 'npc/barnacle/barnacle_gulp1.wav', 'npc/barnacle/barnacle_gulp2.wav' }
ITEM.expireTime = 1800
ITEM.attributes = {}

--- Boosts the item's `attributes` and makes the player drunk for `expireTime` seconds, then calls `OnDrink`.
function ITEM:OnUse(player, itemEntity)
  for k, v in pairs(self.attributes) do
    player:BoostAttribute(self.PrintName, k, v, self.expireTime)
  end

  cw.player:SetDrunk(player, self.expireTime)

  if self.OnDrink then
    self:OnDrink(player)
  end
end

--- Called when a player drops the drink; does nothing, so dropping is allowed.
function ITEM:OnDrop(player, position) end
