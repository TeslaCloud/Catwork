--[[
	This script has been purchased for "Blt950's HL2RP & Clockwork plugins" from CoderHire.com
	© 2014 Blt950 do not share, re-distribute or modify
	without permission.
--]]

function PLUGIN:ChatboxAdjustMessageInfo(info, listeners)
	if (info.filter == "ic") then
		local len = info.text:utf8len()

		// Add capital
		if (info.text:StartWith("\"")) then
			info.text = info.text:utf8sub(1, 2):utf8upper()..info.text:utf8sub(3, len)
		else
			info.text = info.text:utf8sub(1, 1):utf8upper()..info.text:utf8sub(2, len)
		end

		// Add period
		local endText = info.text:utf8sub(-1)
		local b

		if (endText == '"') then
			endText = info.text:utf8sub(len - 1, len - 1)
			info.text = info.text:utf8sub(1, len - 1)
			b = true
		end

		if ((endText != ".") and (endText != "!") and (endText != "?") and ((endText != '"'))) then
			info.text = info.text.."."
		end

		if (b) then
			info.text = info.text.."\""
		end
	end
end