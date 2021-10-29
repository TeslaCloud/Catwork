--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

library.New("icon", cw)

cw.icon.stored = cw.icon.stored or {}

-- A function to add a chat icon.
function cw.icon:Add(uniqueID, path, callback, bIsPlayer)
	if (uniqueID) then
		if (path) then
			if (callback) then
				self.stored[uniqueID] = {
					path = path,
					callback = callback,
					isPlayer = bIsPlayer
				}
			else
				MsgC(Color(255, 100, 0, 255), "[CW:Icon] Error: Attempting to add icon without providing a callback.\n")
			end
		else
			MsgC(Color(255, 100, 0, 255), "[CW:Icon] Error: Attempting to add icon without providing a path..\n")
		end
	else
		MsgC(Color(255, 100, 0, 255), "[CW:Icon] Error: Attempting to add an icon without providing a uniqueID.\n")
	end
end

-- A function to remove a chat icon.
function cw.icon:Remove(uniqueID)
	if (uniqueID) then
		self.stored[uniqueID] = nil
	else
		MsgC(Color(255, 100, 0, 255), "[CW:Icon] Error: Attempting to remove an icon without providing a uniqueID.\n")
	end
end

-- A function to set a player's icon.
function cw.icon:PlayerSet(steamID, uniqueID, path)
	cw.icon:Add(uniqueID, path, function(player)
		if (steamID == player:SteamID()) then
			return true
		end
	end, true)
end

-- A function to set a group's icon.
function cw.icon:GroupSet(group, uniqueID, path)
	cw.icon:Add(uniqueID, path, function(player)
		if (player:IsUserGroup(group)) then
			return true
		end
	end)
end

-- A function to return the stored icons.
function cw.icon:GetAll()
	return cw.icon.stored
end

cw.icon:GroupSet("superadmin", "SuperAdminShield", "icon16/shield.png")
cw.icon:GroupSet("admin", "AdminStar", "icon16/star.png")
cw.icon:GroupSet("operator", "OperatorSmile", "icon16/emoticon_smile.png");
