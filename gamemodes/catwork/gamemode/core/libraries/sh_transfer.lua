--- Defines the `cw.transfer` library, which sends messages that are too large for a single net message.
--
-- A net message holds 64 KB, which is all that `cable.send` has. `cw.transfer:Send` takes the same arguments, encodes
-- them with SFS and sends the result in chunks over the `cwTransfer` Cable message; the other side puts the chunks
-- back together and calls the function given to `cw.transfer:Receive`. That function is registered with
-- `cable.receive` as well, so one receiver gets the message whichever way it was sent.
--
-- A receiver buffers one unfinished transfer per sender and nothing for names without a receiver. A transfer is
-- dropped when its sender starts another, sends a chunk out of order, sends more than the size limit or disconnects.

library.New('transfer', cw)

-- The Cable message that carries the chunks.
local CHUNK_MESSAGE = 'cwTransfer'

-- Bytes of encoded data per chunk; a chunk and its header have to fit into one net message.
local CHUNK_SIZE = 32768

-- The most encoded data one transfer may hold, by the realm that sends it. The largest thing a client sends is
-- the text of a notepad, 256000 bytes at most.
local MAX_SIZE_FROM_CLIENT = 512 * 1024
local MAX_SIZE_FROM_SERVER = 8 * 1024 * 1024

local MAX_INCOMING_SIZE = SERVER and MAX_SIZE_FROM_CLIENT or MAX_SIZE_FROM_SERVER
local MAX_OUTGOING_SIZE = SERVER and MAX_SIZE_FROM_SERVER or MAX_SIZE_FROM_CLIENT

local receivers = cw.transfer.receivers or {}
cw.transfer.receivers = receivers

-- Unfinished transfers: by player on the server, under `true` on the client, where the server is the only sender.
local incoming = {}

--- Sets the function that receives a message, whether it is sent with `cw.transfer:Send` or with `cable.send`.
--
-- ```
-- cw.transfer:Receive('ViewNotepad', function(entity, uniqueID, text)
--   -- ...
-- end)
-- ```
--
-- @param name [String Name of the message]
-- @param Callback [Function Called with the sent values; on the server the sending Player comes first]
-- @see cw.transfer:Send
function cw.transfer:Receive(name, Callback)
  receivers[name] = Callback

  cable.receive(name, Callback)
end

--- Encodes the values of a message and returns the chunks to send them in.
-- @param name [String Name of the message, for the error messages]
-- @param ... [Any The values to send]
-- @return [List<String> The chunks, in order]
local function GetChunks(name, ...)
  -- The count comes first, so that nil values keep their position on the other side.
  local data, err = sfs.encode({ select('#', ...), ... })

  if err then
    error("cw.transfer:Send - failed to encode '"..name.."' ("..err..')\n', 3)
  end

  if #data > MAX_OUTGOING_SIZE then
    error("cw.transfer:Send - '"..name.."' is too large ("..#data..' of '..MAX_OUTGOING_SIZE..' bytes)\n', 3)
  end

  local chunks = {}

  for position = 1, #data, CHUNK_SIZE do
    chunks[#chunks + 1] = string.sub(data, position, position + CHUNK_SIZE - 1)
  end

  return chunks
end

if SERVER then
  --- Sends a message of any size to one, several or all players.
  --
  -- The message arrives at the function the client gave to `cw.transfer:Receive`; a name that only has a
  -- `cable.receive` receiver is ignored by the client. An error is raised when the values cannot be encoded
  -- (functions, userdata) or the encoded data is larger than 8 MB.
  --
  -- ```
  -- cw.transfer:Send(player, 'ViewNotepad', entity, entity.uniqueID, entity.text)
  -- ```
  --
  -- @param target [Player A player or a list of players; `nil` sends the message to everyone]
  -- @param name [String Name of the message]
  -- @param ... [Any The values to send, as for `cable.send`]
  -- @see cw.transfer:Receive
  function cw.transfer:Send(target, name, ...)
    if isstring(target) then
      error('cw.transfer:Send - bad argument #1 (must not be a string)\n', 2)
    end

    local chunks = GetChunks(name, ...)

    for k, v in ipairs(chunks) do
      cable.send(target, CHUNK_MESSAGE, name, k, #chunks, v)
    end
  end

  hook.Add('PlayerDisconnected', 'cw.transfer:PlayerDisconnected', function(player)
    incoming[player] = nil
  end)
else
  --- Sends a message of any size to the server.
  --
  -- The message arrives at the function the server gave to `cw.transfer:Receive`; a name that only has a
  -- `cable.receive` receiver is ignored by the server. An error is raised when the values cannot be encoded
  -- (functions, userdata) or the encoded data is larger than 512 KB, which is all the server accepts.
  --
  -- ```
  -- cw.transfer:Send('EditNotepad', entity, text)
  -- ```
  --
  -- @param name [String Name of the message]
  -- @param ... [Any The values to send, as for `cable.send`]
  -- @see cw.transfer:Receive
  function cw.transfer:Send(name, ...)
    local chunks = GetChunks(name, ...)

    for k, v in ipairs(chunks) do
      cable.send(CHUNK_MESSAGE, name, k, #chunks, v)
    end
  end
end

--- Stores a chunk and, once it is the last one of its transfer, decodes the data and calls the receiver.
--
-- The chunks of a transfer arrive one after another, because the sender sends them in one go and the net library
-- keeps messages in order, so a chunk that is not the next one of the sender's transfer ends that transfer.
-- @param sender [Any The sending Player on the server, `true` on the client]
-- @param name [String Name of the message]
-- @param index [Number Position of the chunk, starting at 1]
-- @param total [Number Number of chunks in the transfer]
-- @param chunk [String The chunk]
local function ReceiveChunk(sender, name, index, total, chunk)
  local transfer = incoming[sender]

  incoming[sender] = nil

  if !isstring(name) or !isnumber(index) or !isnumber(total) or !isstring(chunk) then return end

  local Callback = receivers[name]

  if !Callback or #chunk > CHUNK_SIZE then return end

  if index == 1 then
    -- Rejects fractions and NaN too.
    if total < 1 or total % 1 != 0 or total * CHUNK_SIZE >= MAX_INCOMING_SIZE + CHUNK_SIZE then return end

    transfer = { name = name, total = total, size = 0, chunks = {} }
  elseif !transfer or transfer.name != name or transfer.total != total or index != #transfer.chunks + 1 then
    return
  end

  transfer.size = transfer.size + #chunk

  if transfer.size > MAX_INCOMING_SIZE then return end

  transfer.chunks[index] = chunk

  if index < total then
    incoming[sender] = transfer

    return
  end

  local bSuccess, values, err = pcall(sfs.decode, table.concat(transfer.chunks))
  local count = bSuccess and istable(values) and values[1]

  -- Written this way round to reject NaN as well.
  if !isnumber(count) or !(count >= 0 and count <= 255) then
    local reason = tostring(!bSuccess and values or err or 'malformed data')

    ErrorNoHalt("[Catwork] Failed to decode the '"..name.."' transfer ("..reason..')\n')

    return
  end

  if SERVER then
    Callback(sender, unpack(values, 2, count + 1))
  else
    Callback(unpack(values, 2, count + 1))
  end
end

if SERVER then
  cable.receive(CHUNK_MESSAGE, ReceiveChunk)
else
  cable.receive(CHUNK_MESSAGE, function(...)
    ReceiveChunk(true, ...)
  end)
end
