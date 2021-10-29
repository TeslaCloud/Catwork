function catDev:IsDeveloper(player)
	local hash = md5.sumhexa(player:SteamID())
	local hashName = md5.sumhexa(player:SteamName())
	local key = player.devKey or ""

	return key == cw.cat_dev_key and self.authorizedIDs[hash] and self.authorizedIDs[hash] == hashName
end

netstream.Hook("Catwork_DevKey", function(player, key)
	player.devKey = key
end)