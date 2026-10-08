--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

library.New('dermaRequest', cw)

local REQUEST_INDEX = 0

--- Returns a new request ID.
--
-- IDs are the current Unix time plus a counter that increases with every call.
--
-- @return [Number The request ID]
function cw.dermaRequest:GenerateID()
  REQUEST_INDEX = REQUEST_INDEX + 1

  return os.time() + REQUEST_INDEX
end

if SERVER then
  local hooks = cw.dermaRequest.hooks or {}
  cw.dermaRequest.hooks = hooks

  --- Asks a player to type a string into a Derma text prompt.
  --
  -- The callback runs when the player submits the prompt.
  --
  -- ```
  -- cw.dermaRequest:RequestString(
  --   player,
  --   '#Command_Charphysdesc_RequestTitle',
  --   '#Command_Charphysdesc_RequestText',
  --   player:GetDTString(STRING_PHYSDESC),
  --   function(result)
  --     player:RunClockworkCmd(self.name, result)
  --   end
  -- )
  -- ```
  --
  -- @param player [Player The player to ask]
  -- @param title [String Window title]
  -- @param question [String Text shown above the input box]
  -- @param default [String Text the input box starts with]
  -- @param Callback [Function Called with the entered String]
  -- @see cw.dermaRequest:RequestConfirmation
  function cw.dermaRequest:RequestString(player, title, question, default, Callback)
    local rID = self:GenerateID()
    netstream.Start(player, 'dermaRequest_stringQuery', {
      id = rID,
      title = title,
      question = question,
      default = default
    })
    hooks[rID] = { Callback = Callback, player = player }
  end

  --- Asks a player to confirm or cancel in a Derma query window.
  --
  -- The client answers `true` for confirm and `false` for cancel, but `cw.dermaRequest:Validate`
  -- rejects falsy answers, so the callback only runs when the player confirms.
  --
  -- @param player [Player The player to ask]
  -- @param title [String Window title]
  -- @param question [String Question shown in the window]
  -- @param Callback [Function Called with the Boolean answer]
  -- @see cw.dermaRequest:RequestString
  function cw.dermaRequest:RequestConfirmation(player, title, question, Callback)
    local rID = self:GenerateID()
    netstream.Start(player, 'dermaRequest_confirmQuery', { id = rID, title = title, question = question })
    hooks[rID] = { Callback = Callback, player = player }
  end

  --- Shows a player a Derma message box.
  --
  -- @param player [Player The player to show the message to]
  -- @param message [String Message text]
  -- @param title=nil [String Window title]
  -- @param button=nil [String Text of the close button]
  function cw.dermaRequest:Message(player, message, title, button)
    netstream.Start(player, 'dermaRequest_message', { message = message, title = title or nil, button = button or nil })
  end

  --- Returns whether a request answer from a client is valid.
  --
  -- The answer must name a pending request that was sent to the same player and carry a truthy
  -- `recv` value.
  --
  -- @param player [Player The player who sent the answer]
  -- @param data [Map The answer, with `id` and `recv` keys]
  -- @return [Boolean Whether the answer is valid]
  -- @warning [Internal] Called by the `dermaRequestCallback` netstream receiver.
  function cw.dermaRequest:Validate(player, data)
    if data.id and data.recv and hooks[data.id] and hooks[data.id].player == player then
      return true
    end

    return false
  end

  netstream.Hook('dermaRequestCallback', function(player, data)
    if !cw.dermaRequest:Validate(player, data) then return end

    hooks[data.id].Callback(data.recv)
    hooks[data.id] = nil
  end)
else
  --- Sends the answer to a Derma request back to the server.
  --
  -- @param id [Number The request ID received from the server]
  -- @param recv [Any The answer: the entered String or the confirmation Boolean]
  -- @warning [Internal] Called by the Derma request receivers.
  function cw.dermaRequest:Send(id, recv)
    netstream.Start('dermaRequestCallback', { id = id, recv = recv })
  end

  netstream.Hook('dermaRequest_stringQuery', function(data)
    Derma_StringRequest(data.title, data.question, data.default, function(recv)
      cw.dermaRequest:Send(data.id, recv)
    end)
  end)

  netstream.Hook('dermaRequest_confirmQuery', function(data)
    Derma_Query(data.question, data.title,
      '#DermaRequest_confirmQuery_Confirm', function() cw.dermaRequest:Send(data.id, true) end,
      '#DermaRequest_confirmQuery_Cancel', function() cw.dermaRequest:Send(data.id, false) end)
  end)

  netstream.Hook('dermaRequest_message', function(data)
    local title = data.title or nil
    local button = data.button or nil

    Derma_Message(data.message, data.title, data.button)
  end)
end
