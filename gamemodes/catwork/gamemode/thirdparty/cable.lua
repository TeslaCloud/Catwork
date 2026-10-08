--[[
  Cable - A simple Garry's Mod net wrapper.
  2018 TeslaCloud Studios
--]]

--[[
  Catwork edition, based on https://github.com/Meow/cable (commit 7eaad3d). The Flux edition of Cable
  (https://github.com/TeslaCloud/flux-ce, packages/cable) was the reference for the switch to SFS.
  What differs from upstream, and why:

  - SFS (https://github.com/Srlion/sfs) replaces pON, and the whole argument list is encoded as one SFS value
    instead of going through net.WriteType one argument at a time. net.WriteVector and net.WriteAngle compress
    their values and net.WriteString stops at the first NUL byte, while netstream, which Cable replaces here,
    delivered all of them intact.
  - The number of arguments is taken from select('#', ...), so that a nil argument keeps its position. Upstream
    counted with ipairs, which stops at the first nil.
  - SFS is told to refuse functions, as the SFS package of Flux does (it skips them otherwise, which corrupts the
    table they are in), and to send colors as the plain tables pON sent them as.
  - A message that cannot be encoded or does not fit into one net message raises an error on the sender before
    anything is written. A message that cannot be decoded is reported and dropped without calling its receiver.
  - On the server only nil or false as the target means everyone. Upstream also sent to everyone when the
    target was an invalid player, which turns a message for one player who has just left into a broadcast.
    Entries of a target list that are not valid players are skipped.
  - No message is delayed. Upstream pooled a name on its first cable.send and sent that message 0.25 seconds
    later, which lets later messages overtake it, and a client that is still loading in does not know a string
    pooled after it connected. A name only gets its own network string here when the server pools it while it
    loads (cable.receive or cable.check_networked_string); everything else travels on the shared 'cable' string
    with the name written in front of it. A client does the same for a name it has no network string for yet,
    where upstream ran into the net.Start error.
  - The table.map and _player definitions are gone, nothing uses them anymore.
--]]

-- Cable shouldn't be reloaded
if cable then return end
if !sfs then sfs = include('sfs.lua') end

do
  local encoder = sfs.Encoder

  -- SFS skips functions by writing nothing at all, which silently corrupts the table
  -- they are in. Fail like it does for every other unsupported type instead.
  encoder.encoders['function'] = function(buf)
    encoder.write_str(buf, 'unsupported type: ')
    encoder.write_str(buf, 'function')

    return true
  end

  -- Without its own encoder a color is written as the table it is ({ r, g, b, a } by name), which is what
  -- receivers have always been given. The SFS color type would also floor its components into single bytes.
  local color_meta = FindMetaTable('Color')

  if color_meta then
    encoder.encoders[color_meta] = nil
  end
end

cable = cable or {}

-- Messages without a network string of their own are sent under this one.
local shared_id = 'cable'

-- The most SFS data a single message carries. A net message is limited to 64 KB, the rest is left for the
-- argument count, the length and the name of the message.
local max_length = 65000

local net_cache = {}
local receivers = {}

local function read_args(id)
  local count = net.ReadUInt(8)

  if count == 0 then return 0, {} end

  local success, args, err = pcall(sfs.decode, net.ReadData(net.ReadUInt(16)))

  if !success or err or !istable(args) then
    local reason = tostring(!success and args or err or 'not a table')

    ErrorNoHalt('cable.receive - failed to decode "'..id..'" ('..reason..')\n')

    return
  end

  return count, args
end

local function run_callback(id, callback, player)
  local count, args = read_args(id)

  if !count then return end

  if SERVER then
    if !IsValid(player) then return end

    callback(player, unpack(args, 1, count))
  else
    callback(unpack(args, 1, count))
  end
end

function cable.receive(id, callback)
  if SERVER then cable.check_networked_string(id) end

  -- net.Receive ignores the case of a name as well.
  receivers[string.lower(id)] = callback

  return net.Receive(id, function(length, player)
    run_callback(id, callback, player)
  end)
end

net.Receive(shared_id, function(length, player)
  local id = net.ReadString()
  local callback = receivers[string.lower(id)]

  if callback then
    run_callback(id, callback, player)
  end
end)

local function encode_args(id, ...)
  local count = select('#', ...)

  if count == 0 then return 0 end

  if count > 255 then
    error('cable.send - too many values for "'..id..'" ('..count..', 255 at most)\n', 3)
  end

  local data, err = sfs.encode({...})

  if err then
    error('cable.send - failed to encode "'..id..'" ('..err..')\n', 3)
  end

  if #data > max_length then
    error('cable.send - "'..id..'" does not fit into one net message ('..#data..' of '..max_length..' bytes)\n', 3)
  end

  return count, data
end

local function write_sendable_args(count, data)
  net.WriteUInt(count, 8)

  if count > 0 then
    -- SFS data is binary, so it has to be written along with its length.
    net.WriteUInt(#data, 16)
    net.WriteData(data, #data)
  end
end

if SERVER then
  -- True until the server starts to run, which is before the first client connects. Clients get the names that
  -- are pooled by then when they connect, so only those are safe to send under at any later time.
  local loading = true

  timer.Simple(0, function()
    loading = false
  end)

  util.AddNetworkString(shared_id)

  function cable.check_networked_string(id)
    if net_cache[id] == nil then
      util.AddNetworkString(id)
      net_cache[id] = loading
      return false
    end
    return true
  end

  function cable.send(target, id, ...)
    if isstring(target) then
      error('cable.send - bad argument #1 (must not be a string)\n', 2)
    end

    if !istable(target) then
      if target then
        target = { target }
      else
        target = player.GetAll()
      end
    end

    local recipients = {}

    for k, v in ipairs(target) do
      if type(v) == 'Player' and IsValid(v) then
        table.insert(recipients, v)
      end
    end

    if #recipients == 0 then return end

    local count, data = encode_args(id, ...)

    if net_cache[id] then
      net.Start(id)
    else
      net.Start(shared_id)
      net.WriteString(id)
    end

    write_sendable_args(count, data)
    net.Send(recipients)
  end
else
  function cable.send(id, ...)
    local count, data = encode_args(id, ...)

    if util.NetworkStringToID(id) != 0 then
      net.Start(id)
    else
      net.Start(shared_id)
      net.WriteString(id)
    end

    write_sendable_args(count, data)
    net.SendToServer()
  end
end
