--- Server-side hooks of the Books plugin that handle the View and Take menu options of `cw_book` entities and load and
-- save the placed books.
--
-- View sends the `ViewBook` netstream to the player, and Take gives them the book's item and removes the entity.

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
  if entity:GetClass() != 'cw_book' then return end

  if arguments == 'cw_bookView' then
    netstream.Start(player, 'ViewBook', entity)
  elseif arguments == 'cw_bookTake' then
    self:TakeBook(player, entity)
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
