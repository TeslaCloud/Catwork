--- Defines the `cw.attributes` library, which reads and changes the attribute values, progress and boosts of players.
--
-- On the server it updates, progresses and boosts a player's attributes and networks the changes. On the client it
-- keeps the local player's values up to date from the `AttrUpdate`, `AttributeProgress`, `AttrBoost`, `AttrBoostClear`
-- and `AttrClear` messages.

library.New('attributes', cw)

if SERVER then
  --- Adds progress towards the next point of a player's attribute.
  --
  -- Progress runs from 0 to 100. Reaching 100 raises the attribute by one point with
  -- `Player:UpdateAttribute` and carries the remainder over; dropping below 0 lowers it by
  -- one point, or leaves it at no progress when the attribute has no points to lose. With
  -- `gradual`, positive progress shrinks as the attribute nears its maximum.
  -- Runs the `OnAttributeProgress` hook (via `hook.Run`) before applying the progress; a number it
  -- returns replaces the amount.
  --
  -- @param player [Player The player whose attribute progresses]
  -- @param attribute [Any Attribute index, unique ID or name, as accepted by `cw.attribute:FindByID`]
  -- @param amount [Number Progress to add; negative values remove progress]
  -- @param gradual=nil [Boolean Whether to scale positive progress down as the attribute grows]
  -- @return [Boolean `false` when the attribute is invalid or already at its maximum, String The
  -- reason, as a language phrase]
  -- @see Player:ProgressAttribute
  function cw.attributes:Progress(player, attribute, amount, gradual)
    local attributeTable = cw.attribute:FindByID(attribute)
    local attributes = player:GetAttributes()

    if attributeTable then
      attribute = attributeTable.uniqueID

      if gradual and attributes[attribute] then
        if amount > 0 then
          amount = math.max(
            amount - ((amount / attributeTable.maximum) * attributes[attribute].amount),
            amount / attributeTable.maximum
          )
        else
          amount =
            math.min((amount / attributeTable.maximum) * attributes[attribute].amount, amount / attributeTable.maximum)
        end
      end

      amount = hook.Run('OnAttributeProgress', player, attribute, amount) or amount

      if attributes[attribute] then
        if attributes[attribute].amount == attributeTable.maximum then
          if amount > 0 then
            return false, L('Attribute_MaximumReached')
          end
        end
      else
        attributes[attribute] = { amount = 0, progress = 0 }
      end

      local progress = attributes[attribute].progress + amount
      local remaining = math.max(progress - 100, 0)

      if progress >= 100 then
        attributes[attribute].progress = 0

        player:UpdateAttribute(attribute, 1)

        if remaining > 0 then
          return player:ProgressAttribute(attribute, remaining)
        end
      elseif progress < 0 and attributes[attribute].amount > 0 then
        attributes[attribute].progress = 100

        player:UpdateAttribute(attribute, -1)

        return player:ProgressAttribute(attribute, progress)
      else
        attributes[attribute].progress = math.max(progress, 0)
      end

      if attributes[attribute].amount == 0 and attributes[attribute].progress == 0 then
        attributes[attribute] = nil
      end

      if player:HasInitialized() then
        if attributes[attribute] then
          player.cwAttrProgress[attribute] = math.floor(attributes[attribute].progress)
        else
          player.cwAttrProgress[attribute] = 0
        end
      end
    else
      return false, L('Attribute_NotValid')
    end
  end

  --- Changes a player's attribute by a number of points.
  --
  -- The result is clamped between 0 and the attribute's maximum. Raising the attribute resets its
  -- progress. The new value is sent to the player and the `PlayerAttributeUpdated` hook is run
  -- (via `hook.Run`) with the player, the attribute table and `amount`.
  --
  -- @param player [Player The player whose attribute changes]
  -- @param attribute [Any Attribute index, unique ID or name, as accepted by `cw.attribute:FindByID`]
  -- @param amount=nil [Number Points to add; negative values remove points, `nil` adds none]
  -- @return [Boolean Whether the attribute was updated, String The reason it was not, as a language
  -- phrase]
  -- @see Player:UpdateAttribute
  function cw.attributes:Update(player, attribute, amount)
    local attributeTable = cw.attribute:FindByID(attribute)
    local attributes = player:GetAttributes()

    if attributeTable then
      attribute = attributeTable.uniqueID

      if !attributes[attribute] then
        attributes[attribute] = { amount = 0, progress = 0 }
      elseif attributes[attribute].amount == attributeTable.maximum then
        if amount and amount > 0 then
          return false, L('Attribute_MaximumReached')
        end
      end

      attributes[attribute].amount = math.Clamp(attributes[attribute].amount + (amount or 0), 0, attributeTable.maximum)

      if amount and amount > 0 then
        attributes[attribute].progress = 0

        if player:HasInitialized() then
          player.cwAttrProgress[attribute] = 0
          player.cwAttrProgressTime = 0
        end
      end

      cable.send(player, 'AttrUpdate', {
        index = attributeTable.index, amount = attributes[attribute].amount
      })

      if attributes[attribute].amount == 0
      and attributes[attribute].progress == 0 then
        attributes[attribute] = nil
      end

      hook.Run('PlayerAttributeUpdated', player, attributeTable, amount)

      return true
    else
      return false, L('Attribute_NotValid')
    end
  end

  --- Removes every attribute boost from a player and tells the client.
  --
  -- @param player [Player The player to clear]
  function cw.attributes:ClearBoosts(player)
    cable.send(player, 'AttrBoostClear', true)

    player.cwAttrBoosts = {}
  end

  --- Returns whether a player has a specific attribute boost.
  --
  -- When `amount` or `duration` is given, the boost must also match it.
  --
  -- @param player [Player The player to check]
  -- @param identifier [String Boost identifier, as returned by `cw.attributes:Boost`]
  -- @param attribute [Any Attribute index, unique ID or name]
  -- @param amount=nil [Number Amount the boost must have]
  -- @param duration=nil [Number Duration the boost must have, in seconds]
  -- @return [Boolean Whether the boost is active, or `nil` if the player or attribute has no such
  -- boost]
  function cw.attributes:IsBoostActive(player, identifier, attribute, amount, duration)
    if player.cwAttrBoosts then
      local attributeTable = cw.attribute:FindByID(attribute)

      if attributeTable then
        attribute = attributeTable.uniqueID

        if player.cwAttrBoosts[attribute] then
          local attributeBoost = player.cwAttrBoosts[attribute][identifier]

          if attributeBoost then
            if amount and duration then
              return attributeBoost.amount == amount and attributeBoost.duration == duration
            elseif amount then
              return attributeBoost.amount == amount
            elseif duration then
              return attributeBoost.duration == duration
            else
              return true
            end
          end
        end
      end
    end
  end

  --- Adds or removes a temporary or permanent boost to a player's attribute.
  --
  -- With an `amount`, the boost is added (replacing a boost with the same identifier) and sent to
  -- the client. Without one, the boost named by `identifier` is removed, or every boost of the
  -- attribute when `identifier` is also `nil`. With a `nil` attribute and no `amount`, the boost
  -- named by `identifier` is removed from every attribute, or all of the player's boosts are
  -- cleared when `identifier` is `nil` too. Does nothing for an attribute that cannot be found,
  -- or for invalid or uninitialized players.
  --
  -- ```
  -- local id = cw.attributes:Boost(player, 'drunk', ATB_STRENGTH, -10, 120)
  -- cw.attributes:Boost(player, id, ATB_STRENGTH)
  -- ```
  --
  -- @param player [Player The player to boost]
  -- @param identifier [String Boost identifier; a unique one is generated when `nil` and `amount` is
  -- given]
  -- @param attribute [Any Attribute index, unique ID or name]
  -- @param amount=nil [Number Points to add while the boost lasts, or `nil` to remove boosts]
  -- @param duration=nil [Number How long the boost lasts in seconds, or `nil` for no time limit]
  -- @return [String The boost identifier when a boost was added, `true` when boosts were removed, or
  -- `nil` when nothing was done]
  -- @see cw.attributes:ClearBoosts
  function cw.attributes:Boost(player, identifier, attribute, amount, duration)
    if !IsValid(player) or !player:HasInitialized() then return end

    local attributeTable = cw.attribute:FindByID(attribute)

    if attributeTable then
      attribute = attributeTable.uniqueID

      if amount then
        if !identifier then
          identifier = tostring({})
        end

        if !player.cwAttrBoosts[attribute] then
          player.cwAttrBoosts[attribute] = {}
        end

        if duration then
          player.cwAttrBoosts[attribute][identifier] = {
            duration = duration,
            endTime = CurTime() + duration,
            default = amount,
            amount = amount
          }
        else
          player.cwAttrBoosts[attribute][identifier] = {
            amount = amount
          }
        end

        local cwIndex = attributeTable.index
        local cwAmount = player.cwAttrBoosts[attribute][identifier].amount
        local cwDuration = player.cwAttrBoosts[attribute][identifier].duration
        local cwEndTime = player.cwAttrBoosts[attribute][identifier].endTime
        local cwIdentifier = identifier

        cable.send(player, 'AttrBoost', {
          index = cwIndex, amount = cwAmount, duration = cwDuration, endTime = cwEndTime, identifier = cwIdentifier
        })

        return identifier
      elseif identifier then
        if self:IsBoostActive(player, identifier, attribute) then
          if player.cwAttrBoosts[attribute] then
            player.cwAttrBoosts[attribute][identifier] = nil
          end

          cable.send(player, 'AttrBoostClear', {
            index = attributeTable.index, identifier = identifier
          })
        end

        return true
      elseif player.cwAttrBoosts[attribute] then
        cable.send(player, 'AttrBoostClear', {
          index = attributeTable.index
        })

        player.cwAttrBoosts[attribute] = {}

        return true
      end
    elseif attribute == nil and !amount then
      if !identifier then
        self:ClearBoosts(player)

        return true
      end

      for k, v in pairs(player.cwAttrBoosts) do
        if v[identifier] then
          v[identifier] = nil

          cable.send(player, 'AttrBoostClear', {
            index = cw.attribute:FindByID(k).index, identifier = identifier
          })
        end
      end

      return true
    end
  end

  --- Returns a player's attribute scaled to a range, so that the maximum value maps to `fraction`.
  --
  -- Boosts are included. Results are cached per attribute value.
  --
  -- @param player [Player The player to check]
  -- @param attribute [Any Attribute index, unique ID or name]
  -- @param fraction [Number Value the attribute's maximum maps to]
  -- @param negative=nil [Any When truthy, negative attribute values are allowed; when a Number, it is
  -- used instead of `fraction` for negative values]
  -- @return [Number The scaled value; 0 for invalid or uninitialized players, `nil` if the attribute
  -- cannot be found]
  function cw.attributes:Fraction(player, attribute, fraction, negative)
    if !IsValid(player) or !player:HasInitialized() then return 0 end

    local attributeTable = cw.attribute:FindByID(attribute)

    if attributeTable then
      local maximum = attributeTable.maximum
      local amount = self:Get(player, attribute, nil, negative) or 0

      if amount < 0 and type(negative) == 'number' then
        fraction = negative
      end

      if !attributeTable.cache[amount][fraction] then
        attributeTable.cache[amount][fraction] = (fraction / maximum) * amount
      end

      return attributeTable.cache[amount][fraction]
    end
  end

  --- Returns the value and progress of a player's attribute.
  --
  -- Boosts are added unless `boostless` is set, and the total is clamped to the attribute's range
  -- and rounded up. Returns nothing for invalid or uninitialized players, unknown attributes,
  -- attributes the player has no access to (see `cw.core:HasObjectAccess`), and with `boostless`
  -- when the player has never had the attribute.
  --
  -- @param player [Player The player to check]
  -- @param attribute [Any Attribute index, unique ID or name]
  -- @param boostless=nil [Boolean Return the raw value without boosts]
  -- @param negative=nil [Boolean Allow the total to drop below 0, down to minus the maximum]
  -- @return [Number The attribute value, Number The progress towards the next point (0 to 100)]
  function cw.attributes:Get(player, attribute, boostless, negative)
    if !IsValid(player) or !player:HasInitialized() then return end

    local attributeTable = cw.attribute:FindByID(attribute)

    if attributeTable then
      attribute = attributeTable.uniqueID

      if cw.core:HasObjectAccess(player, attributeTable) then
        local maximum = attributeTable.maximum
        local default = player:GetAttributes()[attribute]
        local boosts = player.cwAttrBoosts[attribute]

        if boostless then
          if default then
            return default.amount, default.progress
          end
        else
          local progress = 0
          local amount = 0

          if default then
            amount = amount + default.amount
            progress = progress + default.progress
          end

          if boosts then
            for k, v in pairs(boosts) do
              amount = amount + v.amount
            end
          end

          if negative then
            amount = math.Clamp(amount, -maximum, maximum)
          else
            amount = math.Clamp(amount, 0, maximum)
          end

          return math.ceil(amount), progress
        end
      end
    end
  end
else
  cw.attributes.stored = cw.attributes.stored or {}
  cw.attributes.boosts = cw.attributes.boosts or {}

  --- Returns the attributes menu panel, if one has been created.
  --
  -- @return [Panel The attributes panel, or `nil`]
  function cw.attributes:GetPanel()
    return self.panel
  end

  --- Returns the local player's attribute scaled to a range, so that the maximum value maps to
  -- `fraction`.
  --
  -- This is the client version of the server's `cw.attributes:Fraction`, without the player
  -- argument. Boosts are included and results are cached per attribute value.
  --
  -- @param attribute [Any Attribute index, unique ID or name]
  -- @param fraction [Number Value the attribute's maximum maps to]
  -- @param negative=nil [Any When truthy, negative attribute values are allowed; when a Number, it is
  -- used instead of `fraction` for negative values]
  -- @return [Number The scaled value, or `nil` if the attribute cannot be found]
  function cw.attributes:Fraction(attribute, fraction, negative)
    local attributeTable = cw.attribute:FindByID(attribute)

    if attributeTable then
      local maximum = attributeTable.maximum
      local amount = self:Get(attribute, nil, negative) or 0

      if amount < 0 and type(negative) == 'number' then
        fraction = negative
      end

      if !attributeTable.cache[amount][fraction] then
        attributeTable.cache[amount][fraction] = (fraction / maximum) * amount
      end

      return attributeTable.cache[amount][fraction]
    end
  end

  --- Returns the value and progress of the local player's attribute.
  --
  -- This is the client version of the server's `cw.attributes:Get`, without the player argument,
  -- reading the values the server has networked. Boosts are added unless `boostless` is set, and
  -- the total is clamped to the attribute's range and rounded up. Returns nothing for unknown
  -- attributes, attributes the player has no access to, and with `boostless` when the player does
  -- not have the attribute.
  --
  -- @param attribute [Any Attribute index, unique ID or name]
  -- @param boostless=nil [Boolean Return the raw value without boosts]
  -- @param negative=nil [Boolean Allow the total to drop below 0, down to minus the maximum]
  -- @return [Number The attribute value, Number The progress towards the next point (0 to 100)]
  function cw.attributes:Get(attribute, boostless, negative)
    local attributeTable = cw.attribute:FindByID(attribute)

    if attributeTable then
      attribute = attributeTable.uniqueID

      if cw.core:HasObjectAccess(cw.client, attributeTable) then
        local maximum = attributeTable.maximum
        local default = self.stored[attribute]
        local boosts = self.boosts[attribute]

        if boostless then
          if default then
            return default.amount, default.progress
          end
        else
          local progress = 0
          local amount = 0

          if default then
            amount = amount + default.amount
            progress = progress + default.progress
          end

          if boosts then
            for k, v in pairs(boosts) do
              amount = amount + v.amount
            end
          end

          if negative then
            amount = math.Clamp(amount, -maximum, maximum)
          else
            amount = math.Clamp(amount, 0, maximum)
          end

          return math.ceil(amount), progress
        end
      end
    end
  end

  --- Rebuilds the attributes panel when it is the one shown in the open menu.
  local function RebuildActivePanel()
    if cw.menu:GetOpen() then
      local panel = cw.attributes:GetPanel()

      if panel and cw.menu:GetActivePanel() == panel then
        panel:Rebuild()
      end
    end
  end

  cable.receive('AttrBoostClear', function(data)
    local index = nil
    local identifier = nil

    if type(data) == 'table' then
      index = data.index
      identifier = data.identifier
    end

    local attributeTable = cw.attribute:FindByID(index)

    if attributeTable then
      local attribute = attributeTable.uniqueID

      if identifier and identifier != '' then
        if cw.attributes.boosts[attribute] then
          cw.attributes.boosts[attribute][identifier] = nil
        end
      else
        cw.attributes.boosts[attribute] = nil
      end
    else
      cw.attributes.boosts = {}
    end

    RebuildActivePanel()
  end)

  cable.receive('AttrBoost', function(data)
    local index = data.index
    local amount = data.amount
    local duration = data.duration
    local endTime = data.endTime
    local identifier = data.identifier
    local attributeTable = cw.attribute:FindByID(index)

    if attributeTable then
      local attribute = attributeTable.uniqueID

      if !cw.attributes.boosts[attribute] then
        cw.attributes.boosts[attribute] = {}
      end

      if amount and amount == 0 then
        cw.attributes.boosts[attribute][identifier] = nil
      elseif duration and duration > 0 and endTime and endTime > 0 then
        cw.attributes.boosts[attribute][identifier] = {
          duration = duration,
          endTime = endTime,
          default = amount,
          amount = amount
        }
      else
        cw.attributes.boosts[attribute][identifier] = {
          default = amount,
          amount = amount
        }
      end

      RebuildActivePanel()
    end
  end)

  cable.receive('AttributeProgress', function(data)
    local index = data.index
    local amount = data.amount
    local attributeTable = cw.attribute:FindByID(index)

    if attributeTable then
      local attribute = attributeTable.uniqueID

      if cw.attributes.stored[attribute] then
        cw.attributes.stored[attribute].progress = amount
      else
        cw.attributes.stored[attribute] = { amount = 0, progress = amount }
      end
    end
  end)

  cable.receive('AttrUpdate', function(data)
    local index = data.index
    local amount = data.amount
    local attributeTable = cw.attribute:FindByID(index)

    if attributeTable then
      local attribute = attributeTable.uniqueID

      if cw.attributes.stored[attribute] then
        cw.attributes.stored[attribute].amount = amount
      else
        cw.attributes.stored[attribute] = { amount = amount, progress = 0 }
      end
    end
  end)

  cable.receive('AttrClear', function(data)
    cw.attributes.stored = {}
    cw.attributes.boosts = {}

    RebuildActivePanel()
  end)
end
