--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("PermitBuy")
COMMAND.tip = "#Command_Permitbuy_Description"
COMMAND.text = "#Command_Permitbuy_Syntax"
COMMAND.flags = CMD_DEFAULT
COMMAND.arguments = 1

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	if (config.Get("permits"):Get()) then
		if (player:GetFaction() == FACTION_CITIZEN) then
			if (cw.player:HasFlags(player, "x")) then
				local permits = {}
				local permit = string.lower(arguments[1])

				for k, v in pairs(item.GetAll()) do
					if (v.cost and v.access and !cw.core:HasObjectAccess(player, v)) then
						if (string.find(v.access, "1")) then
							permits.generalGoods = (permits.generalGoods or 0) + (v.cost * v.batch)
						else
							for k2, v2 in pairs(Schema.customPermits) do
								if (string.find(v.access, v2.flag)) then
									permits[v2.key] = (permits[v2.key] or 0) + (v.cost * v.batch)

									break
								end
							end
						end
					end
				end

				if (table.Count(permits) > 0) then
					for k, v in pairs(permits) do
						if (string.lower(k) == permit) then
							local cost = v

							if (cw.player:CanAfford(player, cost)) then
								if (permit == "generalgoods") then
									cw.player:GiveCash(player, -cost, "buying general goods permit")
									cw.player:GiveFlags(player, "1")
								else
									local permitTable = Schema.customPermits[permit]

									if (permitTable) then
										cw.player:GiveCash(player, -cost, "buying "..string.lower(permitTable.name).." permit")
										cw.player:GiveFlags(player, permitTable.flag)
									end
								end

								timer.Simple(0.5, function()
									if (IsValid(player)) then
										netstream.Start(player, "RebuildBusiness", true)
									end
								end)
							else
								local amount = cost - player:QueryCharacter("cash")
								cw.player:Notify(player, "You need another "..cw.core:FormatCash(amount, nil, true).."!")
							end

							return
						end
					end

					if (permit == "generalgoods" or Schema.customPermits[permit]) then
						cw.player:Notify(player, "You already have this permit!")
					else
						cw.player:Notify(player, "This is not a valid permit!")
					end
				else
					cw.player:Notify(player, "You already have this permit!")
				end
			elseif (string.lower(arguments[1]) == "business") then
				local cost = config.Get("business_cost"):Get()

				if (cw.player:CanAfford(player, cost)) then
					cw.player:GiveCash(player, -cost, "buying business permit")
					cw.player:GiveFlags(player, "x")

					timer.Simple(0.25, function()
						if (IsValid(player)) then
							netstream.Start(player, "RebuildBusiness", true)
						end
					end)
				else
					local amount = cost - player:QueryCharacter("cash")
					cw.player:Notify(player, "You need another "..cw.core:FormatCash(amount, nil, true).."!")
				end
			else
				cw.player:Notify(player, "This is not a valid permit!")
			end
		else
			cw.player:Notify(player, "You are not a citizen!")
		end
	else
		cw.player:Notify(player, "The permit system has not been enabled!")
	end
end

COMMAND:Register();
