--- Defines the `cw.selector` library, numbered on-screen option lists that players pick from with the number keys.
--
-- A selector is built with `cw.selector:New`, `AddText` and `AddOption`. Created on the server, it is sent to its
-- players over the `Selector` message and the callback receives their choice; created on the client, it is shown to
-- the local player.

library.New('selector', cw)
cw.selector.COLOR_ORANGE = Color(215, 150, 50, 255)
cw.selector.COLOR_CREAM = Color(225, 215, 175, 255)
cw.selector.COLOR_GREEN = Color(150, 215, 50, 255)
cw.selector.COLOR_RED = Color(215, 50, 50, 255)

--[[ Set the __index meta function of the class. --]]
local CLASS_TABLE = {}
CLASS_TABLE.__index = CLASS_TABLE

--- Creates a new selector, a numbered list of options the player picks with number keys.
--
-- Build it with `CLASS_TABLE:AddText` and `CLASS_TABLE:AddOption`, then call `CLASS_TABLE:Create`.
-- On the server the selector is sent to its players, who answer through the callback.
--
-- ```
-- local selector = cw.selector:New()
--   selector:AddText('Choose a ration:')
--   selector:AddOption('Standard')
--   selector:AddOption('Loyalist', cw.selector.COLOR_GREEN)
--   selector:SetPlayer(player)
--   selector:SetCallback(function(player, page, key, text)
--   end)
-- selector:Create()
-- ```
--
-- @return [Map The new selector object]
function cw.selector:New()
  local selector = cw.core:NewMetaTable(CLASS_TABLE)

  if CLIENT then
    selector.paginated = {}
    selector.isCreated = false
    selector.pages = { {} }
    selector.page = 1
    selector.key = 0
  else
    selector.data = {}
  end

  selector.paginateText = false
  selector.canExit = true

  return selector
end

--- Sets whether text lines also start a new page once a page has six entries.
--
-- @param bPaginateText [Boolean Whether text is paginated]
function CLASS_TABLE:SetPaginateText(bPaginateText)
  self.paginateText = bPaginateText
end

--- Sets the function called when an option is chosen.
--
-- On the server it is called as `Callback(player, page, key, text)`; on the client as
-- `Callback(page, key, text)`. Keys 1 to 6 are options, 7 is Back, 8 is Next and 9 is Exit.
--
-- @param Callback [Function Called with the chosen option]
function CLASS_TABLE:SetCallback(Callback)
  self.Callback = Callback
end

--- Sets whether the selector has an Exit option.
--
-- @param bCanExit [Boolean Whether the selector can be exited]
function CLASS_TABLE:SetCanExit(bCanExit)
  self.canExit = bCanExit
end

--- Adds a line of text that cannot be chosen.
--
-- @param text [String Text to show; converted with `tostring`]
-- @param color=nil [Color Text color; `cw.selector.COLOR_CREAM` when `nil`]
function CLASS_TABLE:AddText(text, color)
  if text then text = tostring(text) end

  if CLIENT then
    if #self.pages[self.page] == 6 and self.paginateText then
      self.page = self.page + 1 self.key = 1
      self.pages[self.page] = {}
    end

    self.pages[self.page][#self.pages[self.page] + 1] = {
      class = 'text',
      text = text,
      color = color
    }
  else
    self.data[#self.data + 1] = {
      class = 'text',
      text = text,
      color = color
    }
  end
end

--- Adds a numbered option.
--
-- On the client a new page starts after every six options.
--
-- @param text [String Option text; converted with `tostring`]
-- @param color=nil [Color Text color; `cw.selector.COLOR_ORANGE` when `nil`]
function CLASS_TABLE:AddOption(text, color)
  if text then text = tostring(text) end

  if CLIENT then
    if self.key == 6 then
      self.page = self.page + 1 self.key = 1
      self.pages[self.page] = {}
    else
      self.key = self.key + 1
    end

    self.pages[self.page][#self.pages[self.page] + 1] = {
      class = 'option',
      key = self.key,
      text = text,
      color = color
    }
  else
    self.data[#self.data + 1] = {
      class = 'option',
      text = text,
      color = color
    }
  end
end

if SERVER then
  local active = cw.selector.active or {}
  cw.selector.active = active

  --- Sets which players the selector is sent to.
  --
  -- Without a call, `CLASS_TABLE:Create` sends it to every player.
  --
  -- @param player [Player A single player, or a List of players]
  function CLASS_TABLE:SetPlayer(player)
    if type(player) != 'table' then
      self.player = { player }
    else
      self.player = player
    end
  end

  --- Sends the selector to its players and waits for their choice.
  --
  -- Falls back to every player when `CLASS_TABLE:SetPlayer` was not called. Choosing an option other
  -- than Back, Next or Exit ends the selector for that player.
  function CLASS_TABLE:Create()
    if !self.player then
      self.player = _player.GetAll()
    end

    cable.send(self.player, 'Selector', {
      paginateText = self.paginateText,
      canExit = self.canExit,
      data = self.data
    })

    for k, v in pairs(self.player) do
      active[v] = self
    end
  end

  cable.receive('Selector', function(player, data)
    if !istable(data) then return end

    local text = data[3]
    local page = data[1]
    local key = data[2]

    if type(page) == 'number' and type(key) == 'number'
    and type(text) == 'string' and active[player] then
      local Callback = active[player].Callback

      if Callback then
        if key != 7 and key != 8 and key != 9 then
          active[player] = nil
        end

        Callback(player, page, key, text)
      end
    end
  end)
else
  surface.CreateFont('cwSelector',
  {
    font		= 'Verdana',
    size		= 14,
    weight = 700,
    antialiase = true,
    additive = false
  })

  --- Chooses an option on the current page by its number key.
  --
  -- Calls the callback, then goes back or forward a page for keys 7 and 8.
  --
  -- @param key [Number Number key that was pressed]
  -- @return [Boolean `true` when the selector should close, `false` after changing page]
  -- @warning [Internal] Called by the player option set up in `CLASS_TABLE:Create`.
  function CLASS_TABLE:Select(key)
    local bSuccess = false
    local tOption = nil

    for k, v in pairs(self.pages[self.page]) do
      if v.class == 'option' and v.key == key then
        bSuccess = true
        tOption = v
        break
      end
    end

    if tOption then
      if self.Callback then
        self.Callback(
          self.page, tOption.key, tOption.text
        )

        if tOption.key == 7 then
          self:PreviousPage()
          return false
        elseif tOption.key == 8 then
          self:NextPage()
          return false
        end
      end

      surface.PlaySound('ui/buttonclickrelease.wav')

      if tOption.key != 7
      and tOption.key != 8 then
        return true
      end
    end

    if !bSuccess then
      return true
    end
  end

  --- Shows the selector's next page, if there is one.
  function CLASS_TABLE:NextPage()
    if self.pages[self.page + 1] then
      self.page = self.page + 1 self:Create()
    end
  end

  --- Shows the selector's previous page, if there is one.
  function CLASS_TABLE:PreviousPage()
    if self.pages[self.page - 1] then
      self.page = self.page - 1 self:Create()
    end
  end

  --- Shows the selector on the local player's screen.
  --
  -- Adds the Back, Next and Exit options to the current page the first time it is shown. Uses
  -- `cw.client:AddPlayerOption`, which is not defined in Catwork, so this errors unless a plugin
  -- provides it.
  function CLASS_TABLE:Create()
    if !self.isCreated then
      self.page = 1 self.isCreated = true
    end

    if !self.paginated[self.page] then
      if self.pages[self.page - 1] then
        self.pages[self.page][#self.pages[self.page] + 1] = {
          class = 'option',
          key = 7,
          text = '#Selector_Back'
        }
      end

      if self.pages[self.page + 1] then
        self.pages[self.page][#self.pages[self.page] + 1] = {
          class = 'option',
          key = 8,
          text = '#Selector_Next'
        }
      end

      if self.canExit then
        self.pages[self.page][#self.pages[self.page] + 1] = {
          class = 'option',
          key = 9,
          text = '#Selector_Exit'
        }
      end

      self.paginated[self.page] = true
    end

    local height = (18 * #self.pages[self.page]) + 16
    local width = 0

    surface.SetFont('cwSelector')

    for k, v in pairs(self.pages[self.page]) do
      if v.class == 'text' then
        if surface.GetTextSize(string.Replace(v.text, '&', 'U')) > width then
          width = surface.GetTextSize(string.Replace(v.text, '&', 'U'))
        end
      elseif v.class == 'option' then
        if surface.GetTextSize(string.Replace(v.key..'. '..v.text, '&', 'U')) > width then
          width = surface.GetTextSize(string.Replace(v.key..'. '..v.text, '&', 'U'))
        end
      end
    end

    width = width + 16

    cw.client:AddPlayerOption('cwSelector', -1, function(key)
      return self:Select(key)
    end, function()
      local x, y = ScrW() * 0.1, ScrH() * 0.2
        draw.RoundedBox(4, x, y, width, height, Color(0, 0, 0, 150))
      x, y = x + 8, y + 10

      for k, v in pairs(self.pages[self.page]) do
        local color = v.color
        local text = v.text

        if v.class == 'text' then
          color = color or cw.selector.COLOR_CREAM
        elseif v.class == 'option' then
          color = color or cw.selector.COLOR_ORANGE
          text = v.key..'. '..text
        end

        draw.DrawText(text, 'cwSelector', x, y, color)
        y = y + 18
      end
    end)
  end

  cable.receive('Selector', function(data)
    local selector = cw.selector:New()

    selector:SetPaginateText(data.paginateText)
    selector:SetCanExit(data.canExit)

    selector:SetCallback(function(page, key, text)
      cable.send('Selector', { page, key, text })
    end)

    for k, v in pairs(data.data) do
      if v.class == 'option' then
        selector:AddOption(v.text, v.color)
      elseif v.class == 'text' then
        selector:AddText(v.text, v.color)
      end
    end

    if !cw.client or !cw.client:IsValid() then
      timer.Create('cwSelectorCreate', 1, 1, function()
        selector:Create()
      end)
    else
      selector:Create()
    end
  end)
end
