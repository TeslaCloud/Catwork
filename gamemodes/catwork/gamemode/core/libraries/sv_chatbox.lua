--[[
	(C) TeslaCloud Studios LLC.
	For internal use only.
--]]

library.New("chatbox", _G)
chatbox.prefixes = chatbox.prefixes or {}; // Chatbox prefixes for serverside processing. Will be networked to clients for message styling.
chatbox.filters = chatbox.filters or {}

function chatbox.AddPrefix(prefix, callback)
	if (!prefix or prefix == "") then return end

	local oldCB = callback

	function callback(msgData)
		local result = oldCB(msgData)

		if (result) then
			msgData.text = msgData.text:utf8sub((prefix == "/?" and 2) or (prefix:utf8len() + 1), msgData.text:utf8len())
		end
	end

	chatbox.prefixes[prefix] = {}
	chatbox.prefixes[prefix].Callback = callback
	chatbox.prefixes[prefix].length = prefix:utf8len()
end

function chatbox.GetPrefix(prefix)
	if (chatbox.prefixes[prefix]) then
		return chatbox.prefixes[prefix]
	end
end

function chatbox.AddFilter(id, callback)
	if (!id or id == "") then return end

	chatbox.filters[id] = callback
end

function chatbox.GetFilter(id)
	if (chatbox.filters[id]) then
		return chatbox.filters[id]
	end
end

function chatbox.CanHear(listener, position, radius)
	if (listener:HasInitialized()) then
		if (!isnumber(radius)) then return false end
		if (radius == 0) then return true end
		if (radius < 0) then return false end

		if (cw.player:GetRealTrace(listener).HitPos:Distance(position) <= (radius / 2) or position:Distance(listener:GetPos()) <= radius) then
			return true
		end
	end

	return false
end

do
	chatbox.AddFilter("ooc", function(listener, msgData)
		return true -- todo chat types blocking
	end)

	chatbox.AddFilter("pm", function(listener, msgData)
		return true
	end)

	-- variables in these 2 filters are locals because we may wanna use them a bit later.
	chatbox.AddFilter("looc", function(listener, msgData)
		local pos = msgData.position
		local rad = msgData.radius or config.GetVal("talk_radius")

		return chatbox.CanHear(listener, pos, rad)
	end)

	chatbox.AddFilter("ic", function(listener, msgData)
		pos = msgData.position

		if (!pos and IsValid(msgData.sender)) then
			pos = msgData.sender:GetPos()
		end

		local rad = msgData.radius or config.GetVal("talk_radius")

		return chatbox.CanHear(listener, pos, rad)
	end)

	chatbox.AddFilter("player_events", function(listener, msgData)
		local pos = msgData.position
		local rad = msgData.radius or config.GetVal("talk_radius")

		return chatbox.CanHear(listener, pos, rad)
	end)

	chatbox.AddFilter("events", function(listener, msgData)
		return true
	end)

	chatbox.AddFilter("admin", function(listener, msgData)
		return (listener:IsAdmin() or listener:IsUserGroup("operator"))
	end)

	chatbox.AddFilter("default", function(listener, msgData)
		return true
	end)

	-- prevent commands from appearing in chatbox.
	chatbox.AddFilter("command", function(listener, msgData)
		return false
	end)

	chatbox.AddFilter("command_no_announcement", function(listener, msgData)
		return false
	end)

	chatbox.AddFilter("player_as_system", function(listener, msgData)
		return true
	end)
end

do
	chatbox.AddPrefix("//", function(msgData)
		local text = msgData.text

		if (text:StartWith("//")) then
			msgData.filter = "ooc"
			msgData.radius = 0

			while (text:StartWith("// ")) do
				text = "//"..text:utf8sub(4, text:utf8len())
			end

			msgData.text = text

			return true -- tell the system that we set everything!
		end
	end)

	chatbox.AddPrefix(".//", function(msgData)
		local text = msgData.text

		if (text:StartWith(".//")) then
			msgData.filter = "looc"
			msgData.radius = config.GetVal("talk_radius"); -- todo

			while (text:StartWith(".// ")) do
				text = ".//"..text:utf8sub(5, text:utf8len())
			end

			msgData.text = text

			return true
		end
	end)

	-- who even does [[ anyway
	chatbox.AddPrefix("[[", function(msgData)
		local text = msgData.text

		if (text:StartWith("[[")) then
			msgData.filter = "looc"
			msgData.radius = config.GetVal("talk_radius"); -- todo

			while (text:StartWith("[[ ")) do
				text = "[["..text:utf8sub(4, text:utf8len())
			end

			msgData.text = text

			return true
		end
	end)

	chatbox.AddPrefix("/", function(msgData)
		local text = msgData.text

		if (text:StartWith("/") and !text:StartWith("//") and !text:StartWith("/?")) then
			msgData.filter = "command"
			msgData.isCommand = true
			msgData.radius = -1

			return true
		end
	end)

	chatbox.AddPrefix("/?", function(msgData)
		local text = msgData.text

		if (IsValid(msgData.sender) and msgData.sender:IsAdmin() and text:StartWith("/?")) then
			msgData.filter = "command_no_announcement"
			msgData.isCommand = true
			msgData.isCommandSilent = true
			msgData.radius = -1

			return true
		end
	end)

	chatbox.AddPrefix("@", function(msgData)
		local text = msgData.text

		if (text:StartWith("@")) then
			msgData.filter = "admin"
			msgData.radius = 0

			return true
		end
	end)

	chatbox.AddPrefix("<sys>", function(msgData)
		local text = msgData.text

		if (text:StartWith("<sys>")) then
			msgData.filter = "player_as_system"
			msgData.radius = 0

			return true
		end
	end)
end

function chatbox.PlayerCanHear(listener, messageData)
	if (!IsValid(listener)) then
		return messageData.filter != "ic"
	end

	return chatbox.GetFilter(messageData.filter or "default")(listener, messageData)
end

function chatbox.AddText(listeners, ...)
	local args = {...}
	local message = {
		text = "",
		filter = "default",
		icon = "icon16/information.png",
		time = os.time(),
		sendTime = CurTime(),
		drawAvatar = false,
		drawTime = true,
		drawModel = false,
		isPlayerMessage = false,
		rich = true,
		translate = true,
		players = {},
		data = {}
	}

	if (listeners == nil) then
		listeners = _player.GetAll()
	end

	local colored = false
	local curColor = Color(255, 255, 255)

	for k, v in pairs(args) do
		if (isstring(v)) then
			if (colored) then
				message.text = message.text.."[color="..curColor.r..","..curColor.g..","..curColor.b..","..curColor.a.."]"
			end

			message.text = message.text..v

			if (colored and v:lower():find("[/color]")) then
				colored = false
			end
		elseif (IsColor(v)) then
			if (colored) then
				message.text = message.text.."[/color]"
			end

			message.text = message.text.."[color="..v.r..","..v.g..","..v.b..","..v.a.."]"

			colored = true
			curColor = v
		elseif (typeof(v) == "player") then
			message.text = message.text..v:Name()
			message.position = v:GetPos()
			table.insert(message.players, v)
		elseif (istable(v)) then
			table.Merge(message, v)
		end
	end

	if (colored) then
		message.text = message.text.."[/color]"
	end

	if (IsValid(listeners)) then
		message.position = message.position or listeners:GetPos()
	else
		if (IsValid(message.players[1])) then
			message.position = message.position or message.players[1]:GetPos()
		end
	end

	hook.Run("ChatAddText", listeners, message)

	if (hook.Run("ChatboxAdjustMessageInfo", message, listeners) == false) then
		return
	end

	if (cw.DeveloperVersion) then
		print("[Chat::"..message.filter:upper().."] "..message.text)
	end

	if (!IsValid(listeners)) then
		for k, v in ipairs(listeners) do
			if (chatbox.GetFilter(message.filter)(v, message)) then
				netstream.Start(v, "ChatboxAddText", message)
			end
		end
	else
		if (chatbox.GetFilter(message.filter)(listeners, message)) then
			netstream.Start(listeners, "ChatboxAddText", message)
		end
	end

	message.listeners = listeners or _player.GetAll()

	hook.Run("ChatboxMessageSent", message)

	return message
end

function chatbox.SayAsPlayer(player, radius, text)
	chatbox.AddText(nil, "\""..text.."\"", {sender = player, isPlayerMessage = true, filter = "ic", radius = radius, textColor = Color(255, 255, 200, 255)})
end

function chatbox.SetClientMode(isclient)
	chatbox.clientMode = isclient
end

netstream.Hook("ChatboxAddText", function(player, ...)
	chatbox.SetClientMode(true)
	chatbox.AddText(player, ...)
	chatbox.SetClientMode(false)
end)

local adminNames = {
	"Console", "kurozael", "alexgrist",
	"John Smith", "John Doe", "Jane Doe",
	"Ivan", "Admin", "An Admin", "Administrator",
	"Gabe Newell", "Tim Cook", "Vladimir Putin",
	"Bill Gates", "Donald Trump", "Barrack Obama",
	"Russian Hackers", "Ukranians", "Ponis", "A",
	"Wheatley", "GLaDOS", "Chell", "Mel", "Gordon Freeman",
	"Wallace Breen", "Robots", "Machines", "Heavy", "Scout",
	"Spy", "Medic", "Pyro", "Soldier", "Eye of Harmony",
	"Eye of Chaos", "Garry Newman", "Robotboy665", "D}|{et",
	"NightAngel", "Mr. Meow", "Zig", "DarkMind187", "Matew",
	"Fixxer", "RJ", "duck", "Gurrazor", "$30", "CloudAuthX",
	"CloudAuth", "kuro's backdoors", "kurozael's backdoors",
	"Microsoft", "Apple", "John Cena", "BOT Gabe", "BOT Ivan",
	"You", "Schwarz Kruppzo", "The Combine", "Universal Union",
	"OTA", "Rebels"
}

local slanderPhrases = {
	["сервер говно"] = true, ["сервер гавно"] = true, ["сирвир говно"] = true,
	["сирвир гавно"] = true, ["этот сервер говно"] = true, ["ваш сервер говно"] = true,
	["блоубек говно"] = true, ["мяу лох"] = true, ["этот сервер гавно"] = true,
	["ваш сервер гавно"] = true, ["блоубек гавно"] = true, ["blowback говно"] = true,
	["сервер параша"] = true, ["ваш сервер параша"] = true, ["этот сервер параша"] = true,
	["сервер дерьмо"] = true, ["этот сервер дерьмо"] = true, ["ваш сервер дерьмо"] = true,
	["пони для девочек"] = true, ["пони для долбоебов"] = true
}

netstream.Hook("ChatboxTextEntered", function(player, msgText)
	if (!isstring(msgText) or msgText == "") then return end
	if (!IsValid(player)) then
		print("[Catwork Debug] Player is not valid. This should never happen.")

		return
	end

	local lowerText = msgText:utf8lower()
	lowerText = lowerText:Replace(".//", "")
	lowerText = lowerText:Replace("//", "")
	lowerText = lowerText:Replace("[[", "")
	lowerText = lowerText:Replace("/y", "")
	lowerText = lowerText:Replace("/w", "")

	if (slanderPhrases[lowerText]) then
		cw.player:NotifyAll("Фреймворк Catwork кикнул "..player:Name().." с сервера.")

		if (lowerText:find("пони для девочек")) then
			player:Kick("Сам ты для девочек.")
		elseif (lowerText:find("пони для долбоебов")) then
			player:Kick("Сам ты для долбоебов.")
		elseif (lowerText:find("лох")) then
			player:Kick("Сам ты лох.")
		else
			player:Kick("Сам ты говно.")
		end

		return
	end

	local message = {
		text = msgText, -- text of the message
		playerName = player:Name(), -- name of the player who sent this message
		sender = player, -- player object
		filter = "ic", -- filter id
		time = os.time(),
		sendTime = CurTime(),
		position = player:GetPos(),
		steamID = player:SteamID(),
		steamID64 = player:SteamID64(),
		data = {}
	}

	if (msgText:StartWith("/?") and !player:IsAdmin()) then
		cw.player:Notify(player, "This is not a valid command or alias!")

		return
	end

	if (msgText:StartWith("//")) then
		chatbox.GetPrefix("//").Callback(message)
	else
		for k, v in pairs(chatbox.prefixes) do
			if (k == "//") then continue; end

			if (msgText:StartWith(k)) then
				if (v.Callback(message)) then
					break
				end
			end
		end
	end

	local prefix = config.GetVal("command_prefix")
	local maxChatLength = config.GetVal("max_chat_length")
	local curTime = CurTime()

	if (string.utf8len(message.text) >= maxChatLength) then
		message.text = string.utf8sub(message.text, 0, maxChatLength)
		message.text = message.text.."..."
	end

	hook.Run("ChatboxPlayerSay", player, message)

	if (hook.Run("ChatboxAdjustMessageInfo", message, listeners) == false) then
		return
	end

	if (message.isCommand) then
		print("[Catwork Debug] Command detected: "..msgText)

		if (message.isCommandSilent) then
			player:OverrideName(table.Random(adminNames))
		end

		local prefixLength = string.utf8len(prefix)
		local arguments = cw.core:ExplodeByTags(message.text, " ", "\"", "\"", true)

		cw.command:ConsoleCommand(player, "cwCmd", arguments)

		player:OverrideName(nil)

		return
	elseif (message.data.anon) then
		message.playerName = "Кто-то"
	end

	local shouldSend = true

	if (message.filter == "ooc") then
		if (hook.Run("PlayerCanSayOOC", player, message.text)) then
			if (!player.cwNextTalkOOC or curTime > player.cwNextTalkOOC or player:IsAdmin()) then
				player.cwNextTalkOOC = curTime + config.Get("ooc_interval"):Get()
			else
				cw.player:Notify(
					player, "Вы не сможете говорить в ООС чат еще "..math.ceil(player.cwNextTalkOOC - CurTime()).." секунд!"
				)

				return
			end
		end
	elseif (message.filter == "looc") then
		if (message.text != "") then
			if (hook.Run("PlayerCanSayLOOC", player, message.text)) then
				if (!player.cwNextTalkLOOC or curTime > player.cwNextTalkLOOC or player:IsAdmin()) then
					player.cwNextTalkLOOC = curTime + config.Get("looc_interval"):Get()
				else
					cw.player:Notify(
						player, "Вы не сможете говорить в LООС чат еще "..math.ceil(player.cwNextTalkLOOC - CurTime()).." секунд!"
					)

					return
				end	
			end
		end
	elseif (message.filter == "ic") then
		if (hook.Run("PlayerCanSayIC", player, message.text) == false) then
			shouldSend = false
		else
			if (cw.player:GetDeathCode(player, true)) then
				cw.player:UseDeathCode(player, nil, {message.text})
			end

			message.text = "\""..message.text.."\""
		end
	end

	if (cw.player:GetDeathCode(player)) then
		cw.player:TakeDeathCode(player)
	end

	if (!shouldSend) then return end
	if (message.text == "" or message.text == " ") then return end

	print("["..message.filter:upper().."] "..player:Name()..": "..message.text)

	local listeners = {}

	for k, v in ipairs(_player.GetAll()) do
		if (chatbox.GetFilter(message.filter)(v, message)) then
			netstream.Start(v, "ChatboxTextEnter", player, message)
			table.insert(listeners, v)
		end
	end

	message.listeners = listeners or _player.GetAll()

	hook.Run("ChatboxMessageSent", message)
end);
