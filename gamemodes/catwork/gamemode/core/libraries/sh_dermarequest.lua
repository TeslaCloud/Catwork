--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

library.New("dermaRequest", cw)

local REQUEST_INDEX = 0

function cw.dermaRequest:GenerateID()
	REQUEST_INDEX = REQUEST_INDEX + 1

	return os.time() + REQUEST_INDEX
end

if (SERVER) then
	local hooks = cw.dermaRequest.hooks or {}
	cw.dermaRequest.hooks = hooks

	function cw.dermaRequest:RequestString(player, title, question, default, Callback)
		local rID = self:GenerateID()
		netstream.Start(player, "dermaRequest_stringQuery", {id = rID, title = title, question = question, default = default})
		hooks[rID] = {Callback = Callback, player = player}
	end

	function cw.dermaRequest:RequestConfirmation(player, title, question, Callback)
		local rID = self:GenerateID()
		netstream.Start(player, "dermaRequest_confirmQuery", {id = rID, title = title, question = question})
		hooks[rID] = {Callback = Callback, player = player}
	end

	function cw.dermaRequest:Message(player, message, title, button)
		netstream.Start(player, "dermaRequest_message", {message = message, title = title or nil, button = button or nil})
	end

	-- An internal function to validate a return
	function cw.dermaRequest:Validate(player, data)
		if (data.id and data.recv and hooks[data.id] and hooks[data.id].player == player) then
			return true
		end

		return false
	end

	netstream.Hook("dermaRequestCallback", function(player, data)
		if (!cw.dermaRequest:Validate(player, data)) then return end

		hooks[data.id].Callback(data.recv)
		hooks[data.id] = nil
	end)
else
	function cw.dermaRequest:Send(id, recv)
		netstream.Start("dermaRequestCallback", {id = id, recv = recv})
	end

	netstream.Hook("dermaRequest_stringQuery", function(data)
		Derma_StringRequest(data.title, data.question, data.default, function(recv)
			cw.dermaRequest:Send(data.id, recv)
		end)
	end)

	netstream.Hook("dermaRequest_confirmQuery", function(data)
		Derma_Query(data.question, data.title,
			"#DermaRequest_confirmQuery_Confirm", function() cw.dermaRequest:Send(data.id, true) end,
			"#DermaRequest_confirmQuery_Cancel", function() cw.dermaRequest:Send(data.id, false); end)
	end)

	netstream.Hook("dermaRequest_message", function(data)
		local title = data.title or nil
		local button = data.button or nil

		Derma_Message(data.message, data.title, data.button)
	end)
end
