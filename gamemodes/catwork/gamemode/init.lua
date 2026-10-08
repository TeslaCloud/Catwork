--- Server entry point of the Catwork gamemode.
--
-- Requires the `file` binary module (gmsv_file) and aborts start-up without it, sends and includes the third-party
-- libraries (UTF-8, pON, netstream and MD5), then includes `shared.lua` and prints how long the boot or AutoRefresh
-- took. Defines the global `GetTimeSinceBoot`.

cw = cw or {}

do
  cw.startTime = os.clock()
  local startTime = cw.startTime

  local function SafeRequire(mod)
    local success, value = pcall(require, mod)

    if !success then
      ErrorNoHalt("[Catwork] Critical Error - Failed to open '"..mod.."' module!\n")

      return false
    end

    return true
  end

  if cw and cw.core then
    MsgC(Color(0, 255, 100, 255), '[Catwork] Change detected! Refreshing...\n')
  else
    MsgC(Color(0, 255, 100, 255), '[Catwork] Framework is initializing...\n')
  end

  -- https://github.com/Meow/gmsv_file (the gmsv_file_*.dll matching the server's architecture, in garrysmod/lua/bin).
  if !SafeRequire('file') or !istable(File) then
    ErrorNoHalt(
      "[Catwork] The 'file' binary module (gmsv_file) is missing or has failed to load!\n"..
        'Get it from https://github.com/Meow/gmsv_file and put it into garrysmod/lua/bin.\nAborting startup...\n'
    )

    return
  end

  --- Returns how long the server has been loading Catwork, in seconds.
  --
  -- Measured with `os.clock` from the start of `init.lua`, which resets the start time on every Lua refresh.
  -- @return [Number Seconds since the framework started booting, rounded to three decimals]
  function GetTimeSinceBoot()
    return math.Round(os.clock() - startTime, 3)
  end

  -- No need to re-include the stuff that doesn't change.
  if !string.utf8len or !pon or !netstream then
    AddCSLuaFile('thirdparty/utf8.lua')
    AddCSLuaFile('thirdparty/pon.lua')
    AddCSLuaFile('thirdparty/netstream.lua')
    AddCSLuaFile('thirdparty/md5.lua')
  end

  AddCSLuaFile('cl_init.lua')

  --[[
    Include pON and UTF-8 library.
  --]]

  if !string.utf8len or !pon or !netstream or !vnet then
    include('thirdparty/utf8.lua')
    include('thirdparty/pon.lua')
    include('thirdparty/netstream.lua')
    include('thirdparty/md5.lua')
  end

  include('shared.lua')

  if cw and cwBootComplete then
    MsgC(Color(0, 255, 100, 255), '[Catwork] AutoRefresh handled serverside in '..GetTimeSinceBoot()..' second(s)\n')
  else
    local version = cw.core:GetVersionBuild()

    MsgC(
      Color(0, 255, 100, 255),
      '[Catwork] Framework version ['..version..'] loading took '..GetTimeSinceBoot()..' second(s)\n'
    )

    -- For benchmarking.
    cw.LastBootTime = startTime
  end
end

_G['cwBootComplete'] = true
