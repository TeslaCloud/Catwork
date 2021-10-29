--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

library.New("door", cw)

-- A function to get whether the door panel is open.
function cw.door:IsDoorPanelOpen()
	local panel = self:GetPanel()

	if (IsValid(panel)) then
		return true
	end
end

-- A function to get whether the door has shared text.
function cw.door:HasSharedText()
	return self.cwDoorSharedTxt
end

-- A function to get whether the door has shared access.
function cw.door:HasSharedAccess()
	return self.cwDoorSharedAxs
end

-- A function to get whether the door is a parent.
function cw.door:IsParent()
	return self.isParent
end

-- A function to get whether the door is unsellable.
function cw.door:IsUnsellable()
	return self.unsellable
end

-- A function to get the door's access list.
function cw.door:GetAccessList()
	return self.accessList
end

-- A function to get the door's name.
function cw.door:GetName()
	return self.name
end

-- A function to get the door panel.
function cw.door:GetPanel()
	if (IsValid(self.panel)) then
		return self.panel
	end
end

-- A function to get the door owner.
function cw.door:GetOwner()
	if (IsValid(self.owner)) then
		return self.owner
	end
end

-- A function to get the door entity.
function cw.door:GetEntity()
	return self.entity
end
