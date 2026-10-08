--- Client entry point of the Catwork gamemode, which creates the global `cw` table and loads the framework.
--
-- Includes the third-party `utf8`, `pon`, `netstream` and `md5` libraries when they are not loaded yet, then `cw.lua`
-- and `shared.lua`.

cw = cw or {}

--[[
  Include pON and UTF-8 library
--]]

if !string.utf8len or !pon or !netstream then
  include('thirdparty/utf8.lua')
  include('thirdparty/pon.lua')
  include('thirdparty/netstream.lua')
  include('thirdparty/md5.lua')
end

--[[
  Include the shared Lua table and
  the Clockwork kernel.
--]]
include('cw.lua')
include('shared.lua')
