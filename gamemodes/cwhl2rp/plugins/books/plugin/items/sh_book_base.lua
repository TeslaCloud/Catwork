--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

ITEM.isBaseItem = true
ITEM.name = "Book Base"
ITEM.weight = 0.4
ITEM.access = "3"
ITEM.category = "Literature"

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	local trace = player:GetEyeTraceNoCursor()

	if (trace.HitPos:Distance(player:GetShootPos()) <= 192) then
		local entity = ents.Create("cw_book")

		cw.player:GiveProperty(player, entity)

		entity:SetModel(self.model)
		entity:SetBook(self.uniqueID)
		entity:SetPos(trace.HitPos)
		entity:Spawn()

		if (IsValid(itemEntity)) then
			local physicsObject = itemEntity:GetPhysicsObject()

			entity:SetPos(itemEntity:GetPos())
			entity:SetAngles(itemEntity:GetAngles())

			if (IsValid(physicsObject)) then
				if (!physicsObject:IsMoveable()) then
					physicsObject = entity:GetPhysicsObject()

					if (IsValid(physicsObject)) then
						physicsObject:EnableMotion(false)
					end
				end
			end
		else
			cw.entity:MakeFlushToGround(entity, trace.HitPos, trace.HitNormal)
		end
	else
		cw.player:Notify(player, "You cannot drop a book that far away!")

		return false
	end
end

-- Called when the item should be setup.
function ITEM:OnSetup()
	if (self.bookInformation) then
		self.bookInformation = string.gsub(string.gsub(self.bookInformation, "\n", "<br>"), "\t", string.rep("&nbsp;", 4))
		self.bookInformation = "<html><font face='Arial' size='2'>"..self.bookInformation.."</font></html>"
	end
end
