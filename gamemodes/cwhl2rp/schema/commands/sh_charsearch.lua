--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("CharSearch")
COMMAND.tip = "#Command_Charsearch_Description"
COMMAND.flags = CMD_DEFAULT

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = cw.entity:GetPlayer(player:GetEyeTraceNoCursor().Entity)

	if (target) then
		if (target:GetShootPos():Distance(player:GetShootPos()) <= 192) then
			if (player:GetNetVar("tied") == 0) then
				if (target:GetNetVar("tied") != 0) then
					if (target:GetVelocity():Length() == 0) then
						if (!player.searching) then
							target.beingSearched = true
							player.searching = target

							cw.storage:Open(player, {
								name = cw.player:FormatRecognisedText(player, "%s", target),
								weight = target:GetMaxWeight(),
								entity = target,
								distance = 192,
								cash = target:GetCash(),
								inventory = target:GetInventory(),
								OnClose = function(player, storageTable, entity)
									player.searching = nil

									if (IsValid(entity)) then
										entity.beingSearched = nil
									end
								end,
								OnTakeItem = function(player, storageTable, itemTable)
									local target = cw.entity:GetPlayer(storageTable.entity)

									if (target) then
										if (target:GetCharacterData("clothes") == itemTable.index) then
											if (!target:HasItemByID(itemTable.index)) then
												target:SetCharacterData("clothes", nil)

												itemTable:OnChangeClothes(target, false)
											end
										end
									end
								end,
								OnGiveItem = function(player, storageTable, itemTable)
									if (player:GetCharacterData("clothes") == itemTable.index) then
										if (!player:HasItemByID(itemTable.index)) then
											player:SetCharacterData("clothes", nil)

											itemTable:OnChangeClothes(player, false)
										end
									end
								end
							})
						else
							cw.player:Notify(player, "You are already searching a character!")
						end
					else
						cw.player:Notify(player, "You cannot search a moving character!")
					end
				else
					cw.player:Notify(player, "This character is not tied!")
				end
			else
				cw.player:Notify(player, "You don't have permission to do this right now!")
			end
		else
			cw.player:Notify(player, "This character is too far away!")
		end
	else
		cw.player:Notify(player, "You must look at a character!")
	end
end

COMMAND:Register();
