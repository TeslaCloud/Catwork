--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

ITEM.baseItem = "weapon_base"
ITEM.name = "Suitcase"
ITEM.PrintName = "#ITEM_Suitcase"
ITEM.cost = 12
ITEM.model = "models/weapons/w_suitcase_passenger.mdl"
ITEM.weight = 2
ITEM.access = "1"
ITEM.business = true
ITEM.category = "Reusables"
ITEM.uniqueID = "cw_suitcase"
ITEM.isFakeWeapon = true
ITEM.isMeleeWeapon = true
ITEM.description = "#ITEM_Suitcase_Desc"
ITEM.isAttachment = true
ITEM.attachmentBone = "ValveBiped.Bip01_R_Hand"
ITEM.attachmentOffsetAngles = Angle(0, 90, -10)
ITEM.attachmentOffsetVector = Vector(0, 0, 4)
ITEM.customFunctions = {"Unpack"}

-- A function to get whether the attachment is visible.
function ITEM:GetAttachmentVisible(player, entity)
	return (cw.player:GetWeaponClass(player) == self:GetWeaponClass())
end

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end

if (SERVER) then
function ITEM:OnCustomFunction(player, name)
		if (name == "Unpack") then
			local clothes = {
				"blue_beanie",
				"green_beanie",
				"cit_uniform_2"
			}

			local food = {
				"chips",
				"sardine",
				"chinese_takeout",
				"choko",
				"orange",
				"apple",
				"citizen_supplements",
				"bread"
			}

			local drink = {
				"beer",
				"beer_bad",
				"whiskey",
				"vodka",
				"tea",
				"coffee",
				"milk_carton",
				"milk_jug",
				"breens_water",
				"smooth_breens_water",
				"special_breens_water",
				"vegetable_oil",
				"large_soda"
			}

			player:GiveItem(table.Random(clothes))
			player:GiveItem(table.Random(food))
			player:GiveItem(table.Random(drink))
			player:EmitSound("physics/cardboard/cardboard_box_break"..math.random(1, 3)..".wav")
			player:TakeItem(self)
		end
	end
end
