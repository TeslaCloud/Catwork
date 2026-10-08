--- Client-side code of the Craft plugin that opens the `cwCraft` menu and decides which blueprints it lists.
--
-- The `Craft::OpenMenu` netstream creates the menu for a crafting station, and `cwCraft:PlayerCanSeeCraft` hides
-- blueprints whose attribute requirements are well above the player's attributes.

--- Checks whether the local player may see a blueprint in the craft menu.
--
-- Attribute requirements are bucketed at 25, 50 and 75: a blueprint is hidden while the player's
-- attribute is below the highest of those thresholds its requirement reaches.
--
-- @param bpTable [Map The blueprint; its `reqatt` list holds `{ attributeID, minimum }` pairs]
-- @return [Boolean Whether the blueprint is listed]
function cwCraft:PlayerCanSeeCraft(bpTable)
  local flags = bpTable['flag']
  local atts = bpTable['reqatt']

  if atts then
    for k, v in pairs(atts) do
      local att = cw.attributes:Fraction(v[1], 100)

      if v[2] and att then
        if (v[2] >= 25 and att < 25) or
        (v[2] >= 50 and att < 50) or
        (v[2] >= 75 and att < 75) then
          return false
        end
      end
    end
  end

  return true
end

netstream.Hook('Craft::OpenMenu', function(class, name)
  if CRAFT_TABLE_MENU then
    CRAFT_TABLE_MENU:Remove()
    CRAFT_TABLE_MENU = nil
  end

  CRAFT_TABLE_MENU = vgui.Create('cwCraft')
  CRAFT_TABLE_MENU:MakePopup()
  CRAFT_TABLE_MENU:Center()
  CRAFT_TABLE_MENU.class = class
  CRAFT_TABLE_MENU.name = name
end)
