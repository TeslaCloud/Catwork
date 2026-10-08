--- Client-side hook of the Books plugin that adds the View and Take options to the entity menu of `cw_book` entities.

local PLUGIN = PLUGIN

--- Called when an entity's menu options are needed; adds View and Take to books.
--
-- @param entity [Entity The entity the menu is for]
-- @param options [Map The menu options, display text to option value, modified in place]
function PLUGIN:GetEntityMenuOptions(entity, options)
  local class = entity:GetClass()

  if class == 'cw_book' then
    options['#Books_View'] = 'cw_bookView'
    options['#EntityMenuOptions_Take'] = 'cw_bookTake'
  end
end
