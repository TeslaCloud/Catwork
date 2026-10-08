--- Registers the `/CharPhysDesc` command (aliases `/PhysDesc`, `/ChangeDesc`, `/ChangeDescription`), which sets the
-- caller's physical description or asks for it in a text request when none is given.

local COMMAND = cw.command:New('CharPhysDesc')
COMMAND.tip = '#Command_Charphysdesc_Description'
COMMAND.text = '#Command_Charphysdesc_Syntax'
COMMAND.flags = CMD_DEFAULT
COMMAND.arguments = 0
COMMAND.alias = { 'PhysDesc', 'ChangeDesc', 'ChangeDescription' }

--- Sets the caller's physical description; the arguments are the new description.
--
-- Without arguments it opens a text request on the caller's client and runs the command again with the answer.
-- The text must be at least `minimum_physdesc` characters long.
function COMMAND:OnRun(player, arguments)
  local minimumPhysDesc = config.GetVal('minimum_physdesc')

  if arguments[1] then
    local text = table.concat(arguments, ' ')

    if string.utf8len(text) < minimumPhysDesc then
      cw.player:Notify(player, L('CharCreation_Appearance_ErrorMessage7', minimumPhysDesc))
      return
    end

    player:SetCharacterData('PhysDesc', cw.core:ModifyPhysDesc(text))
  else
    cw.dermaRequest:RequestString(
      player,
      '#Command_Charphysdesc_RequestTitle',
      '#Command_Charphysdesc_RequestText',
      player:GetDTString(STRING_PHYSDESC),
      function(result)
        player:RunClockworkCmd(self.name, result)
      end
    )
  end
end

COMMAND:Register()
