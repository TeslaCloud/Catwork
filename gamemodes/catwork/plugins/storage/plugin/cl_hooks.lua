--- Client-side hooks of the Storage plugin that label containers, give them an Open menu option and show their message.
--
-- A container is a physics prop whose model is in `cwStorage.containerList`. Its target ID shows its custom or default
-- name, and its message is shown above the contents in the storage panel.

--- Called when an entity's target ID is painted; labels containers with their custom or default name
-- and an "open" hint.
-- @param entity [Entity The entity being looked at]
-- @param info [Map Drawing state with `x`, `y` and `alpha`; `y` is advanced past the drawn lines]
function cwStorage:HUDPaintEntityTargetID(entity, info)
  local colorTargetID = cw.option:GetColor('target_id')
  local colorWhite = cw.option:GetColor('white')

  if cw.entity:IsPhysicsEntity(entity) then
    local model = string.lower(entity:GetModel())

    if self.containerList[model] then
      if entity:GetNWString('Name') != '' then
        info.y = cw.core:DrawInfo(entity:GetNWString('Name'), info.x, info.y, colorTargetID, info.alpha)
      else
        info.y = cw.core:DrawInfo(self.containerList[model][2], info.x, info.y, colorTargetID, info.alpha)
      end

      info.y = cw.core:DrawInfo('#Container_TargetID', info.x, info.y, colorWhite, info.alpha)
    end
  end
end

--- Called when an entity's menu options are collected; adds an "Open" option to containers.
-- @param entity [Entity The entity the menu is for]
-- @param options [Map Option labels mapped to their arguments; changed in place]
function cwStorage:GetEntityMenuOptions(entity, options)
  if cw.entity:IsPhysicsEntity(entity) then
    local model = string.lower(entity:GetModel())

    if self.containerList[model] then
      options['#EntityMenuOptions_Open'] = 'cwContainerOpen'
    end
  end
end

--- Called when the local player's storage panel is rebuilt; shows the container's message above its
-- contents.
-- @param panel [Panel The storage panel list]
-- @param categories [List The item categories shown in the panel]
function cwStorage:PlayerStorageRebuilt(panel, categories)
  if panel.storageType == 'Container' then
    local entity = cw.storage:GetEntity()

    if IsValid(entity) and entity.cwMessage then
      local messageForm = vgui.Create('DForm', panel)
      local helpText = messageForm:Help(entity.cwMessage)
        messageForm:SetPadding(5)
        messageForm:SetName('#Container_Message')
        helpText:SetFont('Default')
      panel:AddItem(messageForm)
    end
  end
end
