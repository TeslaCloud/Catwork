--- Defines the Suitcase item (`cw_suitcase`), a fake melee weapon held in the hand whose Unpack option replaces it with
-- a random piece of clothing, food and drink.

ITEM.baseItem = 'weapon_base'
ITEM.name = 'Suitcase'
ITEM.PrintName = '#ITEM_Suitcase'
ITEM.cost = 12
ITEM.model = 'models/weapons/w_suitcase_passenger.mdl'
ITEM.weight = 2
ITEM.access = '1'
ITEM.business = true
ITEM.category = 'Reusables'
ITEM.uniqueID = 'cw_suitcase'
ITEM.isFakeWeapon = true
ITEM.isMeleeWeapon = true
ITEM.description = '#ITEM_Suitcase_Desc'
ITEM.isAttachment = true
ITEM.attachmentBone = 'ValveBiped.Bip01_R_Hand'
ITEM.attachmentOffsetAngles = Angle(0, 90, -10)
ITEM.attachmentOffsetVector = Vector(0, 0, 4)
ITEM.customFunctions = { 'Unpack' }

--- Shows the suitcase attachment only while the player has the suitcase weapon out.
-- @param player [Player The player wearing the attachment]
-- @param entity [Entity The `cw_gear` attachment entity]
-- @return [Boolean Whether the attachment is drawn]
function ITEM:GetAttachmentVisible(player, entity)
  return (cw.player:GetWeaponClass(player) == self:GetWeaponClass())
end

--- Lets the item be dropped; nothing else happens.
function ITEM:OnDrop(player, position) end

if SERVER then
  --- Unpacks the suitcase into a random set of clothes, food and drink when Unpack is chosen, then removes it.
  function ITEM:OnCustomFunction(player, name)
    if name == 'Unpack' and player:HasItemInstance(self) then
      local clothes = {
        'blue_beanie',
        'green_beanie',
        'cit_uniform_2'
      }

      local food = {
        'chips',
        'sardine',
        'chinese_takeout',
        'choko',
        'orange',
        'apple',
        'citizen_supplements',
        'bread'
      }

      local drink = {
        'beer',
        'beer_bad',
        'whiskey',
        'vodka',
        'tea',
        'coffee',
        'milk_carton',
        'milk_jug',
        'breens_water',
        'smooth_breens_water',
        'special_breens_water',
        'vegetable_oil',
        'large_soda'
      }

      -- The contents are forced in once the suitcase is gone; without room for them they would just be lost.
      player:TakeItem(self)
      player:GiveItem(table.Random(clothes), true)
      player:GiveItem(table.Random(food), true)
      player:GiveItem(table.Random(drink), true)
      player:EmitSound('physics/cardboard/cardboard_box_break'..math.random(1, 3)..'.wav')
    end
  end
end
