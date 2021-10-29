function catDev:ClockworkInitPostEntity()
	local key = file.Read("cat_dev_key.txt", "DATA")

	if (key and key != "") then
		cw.client.devKey = key

		netstream.Start("Catwork_DevKey", key)
	end
end