--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

cw = cw or {}

--[[
	Include pON and UTF-8 library
--]]
if (!string.utf8len or !pon or !netstream) then
	include("thirdparty/utf8.lua")
	include("thirdparty/pon.lua")
	include("thirdparty/netstream.lua")
	include("thirdparty/md5.lua")
end

--[[
	Include the shared Lua table and
	the Clockwork kernel.
--]]
include("cw.lua")
include("shared.lua")
