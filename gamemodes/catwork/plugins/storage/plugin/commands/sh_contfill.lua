--- Registers the `/ContFill` superadmin command, which fills the container the player is looking at with random items
-- to a scale of 1 to 5, optionally from one item category.

local COMMAND = cw.command:New('ContFill')
COMMAND.tip = '#Command_Contfill_Description'
COMMAND.text = '#Command_Contfill_Syntax'
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 's'
COMMAND.arguments = 1
COMMAND.optionalArguments = 1

--- Fills the container the player is looking at with random items.
--
-- The first argument is a scale from 1 to 5 (5 fills it to its full capacity, 1 to a fifth of it); the
-- optional second argument limits the items to categories containing that text.
function COMMAND:OnRun(player, arguments)
  local trace = player:GetEyeTraceNoCursor()
  local scale = tonumber(arguments[1])

  if scale then
    scale = math.Clamp(math.Round(scale), 1, 5)

    if IsValid(trace.Entity) then
      if cw.entity:IsPhysicsEntity(trace.Entity) then
        local model = string.lower(trace.Entity:GetModel())

        if cwStorage.containerList[model] then
          if !trace.Entity.cwInventory then
            cwStorage.storage[trace.Entity] = trace.Entity

            trace.Entity.cwInventory = {}
          end

          local containerWeight = cwStorage.containerList[model][1] / (6 - scale)
          local weight = cw.inventory:CalculateWeight(trace.Entity.cwInventory)

          if !arguments[2] or cwStorage:CategoryExists(arguments[2]) then
            while weight < containerWeight do
              local randomItem = cwStorage:GetRandomItem(arguments[2])

              if randomItem then
                cw.inventory:AddInstance(
                  trace.Entity.cwInventory, item.CreateInstance(randomItem[1])
                )

                weight = weight + randomItem[2]
              end
            end

            cwStorage:SaveStorage()

            cw.player:Notify(player, L('Container_Filled'))
            return
          else
            cw.player:Notify(player, L('Container_CategoryNotExist'))
            return
          end
        end

        cw.player:Notify(player, L('Container_NotValid'))
      else
        cw.player:Notify(player, L('Container_NotValid'))
      end
    else
      cw.player:Notify(player, L('Container_NotValid'))
    end
  else
    cw.player:Notify(player, L('Container_NotValidScale'))
  end
end

COMMAND:Register()
