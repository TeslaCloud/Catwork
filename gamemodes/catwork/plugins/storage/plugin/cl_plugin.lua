--- Client-side netstream handlers of the Storage plugin: `StorageMessage` stores a container's message on the entity
-- and `ContainerPassword` asks the player for a container's password.

netstream.Hook('StorageMessage', function(data)
  local entity = data.entity
  local message = data.message

  if IsValid(entity) then
    entity.cwMessage = message
  end
end)

netstream.Hook('ContainerPassword', function(data)
  local entity = data

  Derma_StringRequest('#Container_Password', '#Container_PasswordRequest', nil, function(text)
    netstream.Start('ContainerPassword', { text, entity })
  end)
end)
