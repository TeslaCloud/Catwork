--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

library.New('door', cw)

--- Returns whether the door management panel is open.
-- @return [Boolean `true` if it is open, `nil` otherwise]
function cw.door:IsDoorPanelOpen()
  local panel = self:GetPanel()

  if IsValid(panel) then
    return true
  end
end

--- Returns whether the managed door shares its text with its parent door.
-- @return [Boolean Whether the text is shared, as sent by the server]
function cw.door:HasSharedText()
  return self.cwDoorSharedTxt
end

--- Returns whether the managed door shares its access list with its parent door.
-- @return [Boolean Whether access is shared, as sent by the server]
function cw.door:HasSharedAccess()
  return self.cwDoorSharedAxs
end

--- Returns whether the managed door is the parent of other doors.
-- @return [Boolean Whether the door is a parent]
function cw.door:IsParent()
  return self.isParent
end

--- Returns whether the managed door cannot be sold.
-- @return [Boolean Whether the door is unsellable]
function cw.door:IsUnsellable()
  return self.unsellable
end

--- Returns the access list of the managed door.
--
-- The list is updated by the server while the panel is open.
-- @return [Map<Number> Door access levels keyed by player]
function cw.door:GetAccessList()
  return self.accessList
end

--- Returns the name of the managed door.
-- @return [String The door's name, or the `#Doors_Name` phrase if it has none]
function cw.door:GetName()
  return self.name
end

--- Returns the door management panel.
-- @return [Panel The panel, or `nil` if it is not open]
function cw.door:GetPanel()
  if IsValid(self.panel) then
    return self.panel
  end
end

--- Returns the owner of the managed door.
-- @return [Player The owner, or `nil` if the door has no valid owner]
function cw.door:GetOwner()
  if IsValid(self.owner) then
    return self.owner
  end
end

--- Returns the door being managed in the door panel.
-- @return [Entity The door entity]
function cw.door:GetEntity()
  return self.entity
end
