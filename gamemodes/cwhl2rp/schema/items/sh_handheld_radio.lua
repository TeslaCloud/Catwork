--- Defines the Handheld Radio item, which lets its carrier use the radio and has a Frequency option that opens the
-- frequency prompt on the client.

ITEM.name = 'Handheld Radio'
ITEM.PrintName = '#ITEM_Handheld_Radio'
ITEM.cost = 20
ITEM.classes = { CLASS_EMP, CLASS_EOW }
ITEM.model = 'models/handheld_radio.mdl'
ITEM.weight = 0.4
ITEM.access = 'v'
ITEM.category = 'Communication'
ITEM.business = true
ITEM.description = '#ITEM_Handheld_Radio_Desc'
ITEM.customFunctions = { 'Frequency' }

--- Lets the item be dropped; nothing else happens.
function ITEM:OnDrop(player, position) end

if SERVER then
  --- Opens the frequency prompt on the player's client with their current frequency when Frequency is chosen.
  function ITEM:OnCustomFunction(player, name)
    if name == 'Frequency' then
      cable.send(player, 'Frequency', player:GetCharacterData('frequency', ''))
    end
  end
end
