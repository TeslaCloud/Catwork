--- Defines the `cw.dermaRequest` library, which lets the server show a player a Derma text prompt, confirmation query
-- or message box and receive the answer.
--
-- `cw.dermaRequest:RequestString` and `cw.dermaRequest:RequestConfirmation` take a callback that runs on the server
-- once the client answers over the `dermaRequestCallback` message.

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

  --- Stores a request until its player answers, and forgets the requests of players who have left.
  -- @param player [Player The player being asked]
  -- @param Callback [Function Called with the answer]
  -- @param bString [Boolean Whether the answer is a string instead of a confirmation]
  -- @return [Number The ID of the new request]
  local function AddRequest(player, Callback, bString)
    for k, v in pairs(hooks) do
      if !IsValid(v.player) then
        hooks[k] = nil
      end
    end

    local rID = cw.dermaRequest:GenerateID()

    hooks[rID] = { Callback = Callback, player = player, isString = bString }

    return rID
  end

  --- Asks a player to type a string into a Derma text prompt.
  --
  -- The callback runs when the player submits the prompt; closing the prompt drops the request.
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
    cable.send(player, 'dermaRequest_stringQuery', {
      id = AddRequest(player, Callback, true),
      title = title,
      question = question,
      default = default
    })
  end

  --- Asks a player to confirm or cancel in a Derma query window.
  --
  -- The client answers `true` for confirm and `false` for cancel, but `cw.dermaRequest:Validate`
  -- rejects falsy answers, so the callback only runs when the player confirms.
  --
  -- @param player [Player The player to ask]
  -- @param title [String Window title]
  -- @param question [String Question shown in the window]
  -- @param Callback [Function Called with `true` when the player confirms]
  -- @see cw.dermaRequest:RequestString
  function cw.dermaRequest:RequestConfirmation(player, title, question, Callback)
    cable.send(player, 'dermaRequest_confirmQuery', {
      id = AddRequest(player, Callback, false),
      title = title,
      question = question
    })
  end

  --- Shows a player a Derma message box.
  --
  -- @param player [Player The player to show the message to]
  -- @param message [String Message text]
  -- @param title=nil [String Window title]
  -- @param button=nil [String Text of the close button]
  function cw.dermaRequest:Message(player, message, title, button)
    cable.send(player, 'dermaRequest_message', { message = message, title = title, button = button })
  end

  --- Returns whether a request answer from a client is valid.
  --
  -- The answer must name a pending request that was sent to the same player and carry the kind of
  -- `recv` value that request expects: a string for a text prompt, `true` for a confirmation.
  --
  -- @param player [Player The player who sent the answer]
  -- @param data [Map The answer, with `id` and `recv` keys]
  -- @return [Boolean Whether the answer is valid]
  -- @warning [Internal] Called by the `dermaRequestCallback` Cable receiver.
  function cw.dermaRequest:Validate(player, data)
    if !istable(data) then return false end

    local request = hooks[data.id]

    if !request or request.player != player then
      return false
    end

    if request.isString then
      return isstring(data.recv)
    end

    return data.recv == true
  end

  cable.receive('dermaRequestCallback', function(player, data)
    if !istable(data) then return end

    local request = hooks[data.id]

    if !request or request.player != player then return end

    local bValid = cw.dermaRequest:Validate(player, data)

    -- Any answer ends the request: a cancelled prompt answers `false` and cannot be answered again.
    hooks[data.id] = nil

    if bValid then
      request.Callback(data.recv)
    end
  end)
else
  --- Sends the answer to a Derma request back to the server.
  --
  -- @param id [Number The request ID received from the server]
  -- @param recv [Any The answer: the entered String or the confirmation Boolean]
  -- @warning [Internal] Called by the Derma request receivers.
  function cw.dermaRequest:Send(id, recv)
    cable.send('dermaRequestCallback', { id = id, recv = recv })
  end

  cable.receive('dermaRequest_stringQuery', function(data)
    Derma_StringRequest(data.title, data.question, data.default, function(recv)
      cw.dermaRequest:Send(data.id, recv)
    end, function()
      cw.dermaRequest:Send(data.id, false)
    end)
  end)

  cable.receive('dermaRequest_confirmQuery', function(data)
    Derma_Query(data.question, data.title,
      '#DermaRequest_confirmQuery_Confirm', function() cw.dermaRequest:Send(data.id, true) end,
      '#DermaRequest_confirmQuery_Cancel', function() cw.dermaRequest:Send(data.id, false) end)
  end)

  cable.receive('dermaRequest_message', function(data)
    Derma_Message(data.message, data.title, data.button)
  end)
end
