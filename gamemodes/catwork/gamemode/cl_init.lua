--- Client entry point of the Catwork gamemode, which creates the global `cw` table and loads the framework.
--
-- Includes the third-party `utf8`, `cable` (which includes `sfs`) and `md5` libraries when they are not loaded yet,
-- then `cw.lua` and `shared.lua`.

cw = cw or {}

--[[
  Include the UTF-8 library, Cable (which includes SFS) and MD5
--]]

if !string.utf8len or !sfs or !cable then
  include('thirdparty/utf8.lua')
  include('thirdparty/cable.lua')
  include('thirdparty/md5.lua')
end

--[[
  Include the shared Lua table and
  the Clockwork kernel.
--]]
include('cw.lua')
include('shared.lua')
