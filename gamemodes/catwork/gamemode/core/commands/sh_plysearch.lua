--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("PlySearch")
COMMAND.tip = "#Command_Plysearch_Description"
COMMAND.text = "#Command_Plysearch_Syntax"
COMMAND.access = "s"
COMMAND.arguments = 1

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = _player.Find(arguments[1])

	if (target) then
		if (!target.cwBeingSearched) then
			if (!player.cwSearching) then
				target.cwBeingSearched = true
				player.cwSearching = target

				cw.storage:Open(player, {
					name = target:Name(),
					cash = target:GetCash(),
					weight = target:GetMaxWeight(),
					space = target:GetMaxSpace(),
					entity = target,
					inventory = target:GetInventory(),
					OnClose = function(player, storageTable, entity)
						player.cwSearching = nil

						if (IsValid(entity)) then
							entity.cwBeingSearched = nil
						end
					end,
					OnTakeItem = function(player, storageTable, itemTable)
						local target = cw.entity:GetPlayer(storageTable.entity)
						if (target) then
							if (target:GetCharacterData("clothes") == itemTable.index) then
								if (!target:HasItemByID(itemTable.index)) then
									target:SetCharacterData("clothes", nil)

									if (itemTable.OnChangeClothes) then
										itemTable:OnChangeClothes(target, false)
									end
								end
							end
						end
					end,
					OnGiveItem = function(player, storageTable, itemTable)
						if (player:GetCharacterData("clothes") == itemTable.index) then
							if (!player:HasItemByID(itemTable.index)) then
								player:SetCharacterData("clothes", nil)

								if (itemTable.OnChangeClothes) then
									itemTable:OnChangeClothes(player, false)
								end
							end
						end
					end
				})
			else
				cw.player:Notify(player, "You are already searching a character!")
			end
		else
			cw.player:Notify(player, target:Name().." is already being searched!")
		end
	else
		cw.player:Notify(player, arguments[1].." is not a valid player!")
	end
end

COMMAND:Register();
