--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local langEn = cw.lang:GetTable("en")
local langRu = cw.lang:GetTable("ru")

langEn["#Zip_Tie_IsTying"] = "You are already tying a character!"
langEn["#Zip_Tie_LostContactInformation1"] = "Downloading lost radio contact information..."
langEn["#Zip_Tie_LostContactInformation2"] = "WARNING! Radio contact lost for unit at #1 ..."
langEn["#Zip_Tie_IsFacting"] = "You cannot tie characters that are facing you!"
langEn["#Zip_Tie_IsFarAway"] = "This character is too far away!"
langEn["#Zip_Tie_IsTied"] = "This character is already tied!"
langEn["#Zip_Tie_NotValidChar"] = "That is not a valid character!"
langEn["Tie"] = "Tie"

langRu["#Zip_Tie_IsTying"] = "Вы уже связали этого персонажа!"
langRu["#Zip_Tie_LostContactInformation1"] = "Загружается информация о потерянной связи..."
langEn["#Zip_Tie_LostContactInformation2"] = "ВНИМАНИЕ! Юнит потерял радиосвязь в #1 ..."
langRu["#Zip_Tie_IsFacting"] = "Вы не можете связать персонажа, который смотрит на вас!"
langRu["#Zip_Tie_IsFarAway"] = "Этот персонаж слишком далеко!"
langRu["#Zip_Tie_IsTied"] = "Этот персонаж уже связан"
langRu["#Zip_Tie_NotValidChar"] = "Вы должны смотреть на персонажа!"
langRu["Tie"] = "Связать"

ITEM.name = "Zip Tie"
ITEM.PrintName = "#ITEM_Zip_Tie"
ITEM.cost = 4
ITEM.model = "models/items/crossbowrounds.mdl"
ITEM.weight = 0.2
ITEM.access = "v"
ITEM.useText = "Tie"
ITEM.factions = {FACTION_MPF, FACTION_OTA}
ITEM.business = true
ITEM.uniqueID = "zip_tie"
ITEM.description = "#ITEM_Zip_Tie_Desc"

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	if (player.isTying) then
		cw.player:Notify(player, "You are already tying a character!")

		return false
	else
		local trace = player:GetEyeTraceNoCursor()
		local target = cw.entity:GetPlayer(trace.Entity)
		local tieTime = Schema:GetDexterityTime(player)

		if (target) then
			if (target:GetNetVar("tied") == 0) then
				if (target:GetShootPos():Distance(player:GetShootPos()) <= 192) then
					if (target:GetAimVector():DotProduct(player:GetAimVector()) > 0 or target:IsRagdolled()) then
						cw.player:SetAction(player, "tie", tieTime)

						cw.player:EntityConditionTimer(player, target, trace.Entity, tieTime, 192, function()
							if (player:Alive() and !player:IsRagdolled() and target:GetNetVar("tied") == 0
							and target:GetAimVector():DotProduct(player:GetAimVector()) > 0) then
								return true
							end
						end, function(success)
							if (success) then
								player.isTying = nil

								Schema:TiePlayer(target, true, nil, player:IsCombine())

								if (Schema:PlayerIsCombine(target)) then
									local location = Schema:PlayerGetLocation(player)

									Schema:AddCombineDisplayLine(cw.lang:TranslateText("#Zip_Tie_LostContactInformation1"), Color(255, 255, 255, 255), nil, player)
									Schema:AddCombineDisplayLine(cw.lang:TranslateText("#Zip_Tie_LostContactInformation2", location), Color(255, 0, 0, 255), nil, player)
								end

								player:TakeItem(self)
								player:ProgressAttribute(ATB_DEXTERITY, 15, true)
							else
								player.isTying = nil
							end

							cw.player:SetAction(player, "tie", false)
						end)
					else
						cw.player:Notify(player, "#Zip_Tie_IsFacting")

						return false
					end

					player.isTying = true

					cw.player:SetMenuOpen(player, false)

					return false
				else
					cw.player:Notify(player, "#Zip_Tie_IsFarAway")

					return false
				end
			else
				cw.player:Notify(player, "#Zip_Tie_IsTied")

				return false
			end
		else
			cw.player:Notify(player, "#Zip_Tie_NotValidChar")

			return false
		end
	end
end

-- Called when a player drops the item.
function ITEM:OnDrop(player, position)
	if (player.isTying) then
		cw.player:Notify(player, "You are currently tying a character!")

		return false
	end
end
