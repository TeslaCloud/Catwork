--- Client-side Cable handlers of the Storage plugin: `StorageMessage` stores a container's message on the entity
-- and `ContainerPassword` asks the player for a container's password.

cable.receive('StorageMessage', function(data)
  local entity = data.entity
  local message = data.message

  if IsValid(entity) then
    entity.cwMessage = message
  end
end)

cable.receive('ContainerPassword', function(data)
  local entity = data

  Derma_StringRequest('#Container_Password', '#Container_PasswordRequest', nil, function(text)
    cable.send('ContainerPassword', { text, entity })
  end)
end)
