--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

local PLUGIN = PLUGIN

--- Called when an entity's menu option is chosen; opens or picks up a book.
--
-- View sends the `ViewBook` netstream to open the book on the player's screen. Take gives
-- the player the book's item and removes the entity, or tells them why it failed.
--
-- @param player [Player The player who chose the option]
-- @param entity [Entity The entity the option was chosen on]
-- @param option [String The option's display text]
-- @param arguments [String The option value, `cw_bookView` or `cw_bookTake`]
function PLUGIN:EntityHandleMenuOption(player, entity, option, arguments)
  local class = entity:GetClass()

  if class == 'cw_book' and arguments == 'cw_bookTake' or arguments == 'cw_bookView' then
    if arguments == 'cw_bookView' then
      netstream.Start(player, 'ViewBook', entity)
    else
      local success, fault = player:GiveItem(item.CreateInstance(entity.book.uniqueID))

      if !success then
        cw.player:Notify(player, fault)
      else
        entity:Remove()
      end
    end
  end
end

--- Called after Catwork has loaded the map entities; restores the saved books.
function PLUGIN:ClockworkInitPostEntity()
  self:LoadBooks()
end

--- Called after data is saved; saves the books.
function PLUGIN:PostSaveData()
  self:SaveBooks()
end
