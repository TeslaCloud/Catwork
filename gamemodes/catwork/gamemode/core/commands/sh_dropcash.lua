--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local NAME_CASH = cw.option:GetKey("name_cash")

local COMMAND = cw.command:New("DropCash")
COMMAND.tip = "#Command_Dropcash_Description"..string.lower(NAME_CASH).." at your target position."
COMMAND.text = "#Command_Dropcash_Syntax"..string.gsub(NAME_CASH, "%s", "")..">"
COMMAND.flags = CMD_DEFAULT
COMMAND.arguments = 1
COMMAND.alias = {"DropCash", "DropTokens"}
COMMAND.cooldown = 8

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local trace = player:GetEyeTraceNoCursor()
	local cash = tonumber(arguments[1])

	if (cash and cash > 1) then
		cash = math.floor(cash)

		if (player:GetShootPos():Distance(trace.HitPos) <= 192) then
			if (cw.player:CanAfford(player, cash)) then
				cw.player:GiveCash(player, -cash, "Dropping "..cw.option:GetKey("name_cash"))

				local entity = cw.entity:CreateCash(player, cash, trace.HitPos)

				if (IsValid(entity)) then
					cw.entity:MakeFlushToGround(entity, trace.HitPos, trace.HitNormal)
				end
			else
				local amount = cash - player:GetCash()
				cw.player:Notify(player, "You need another "..cw.core:FormatCash(amount, nil, true).."!")
			end
		else
			cw.player:Notify(player, "You cannot drop "..string.lower(NAME_CASH).." that far away!")
		end
	else
		cw.player:Notify(player, "This is not a valid amount!")
	end
end

COMMAND:Register();
