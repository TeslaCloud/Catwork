--- Client-side hooks of the Display Typing plugin that draw a typing indicator above players' heads and report the
-- local player's typing to the server.
--
-- `ChatBoxTextChanged` picks the typing mode from the chat prefix and runs the `cwTypingStart` console command, and
-- `ChatBoxClosed` runs `cwTypingFinish`. `PostDrawTranslucentRenderables` draws the text for each player's `Typing`
-- net var, within a range based on the `talk_radius` config.

--[[
  Micro-optimizations, because local variables are faster
  to access than global variables.
--]]

local cwDisplayTyping = cwDisplayTyping
local playerGetAll = _player.GetAll
local string = string

local offsetDefault = Vector(0, 0, 80)
local offsetVehicle = Vector(0, 0, 128)
local offsetRagdoll = Vector(0, 0, 16)
local offsetCrouch = Vector(0, 0, 64)
local offsetHead = Vector(0, 0, 16)
local typingTexts = nil

--- Called after translucent renderables are drawn; draws the typing indicator above typing players' heads.
--
-- Shows the text for the player's `Typing` net var (talking, whispering, yelling, radioing, performing or
-- typing OOC) above the head bone, or at the position returned by the `GetPlayerTypingDisplayPosition`
-- hook. The indicator fades with distance; the range depends on the `talk_radius` config and the typing
-- mode. Skips the depth and 3D skybox passes.
--
-- @param bDrawingDepth [Boolean Whether this is the depth pass]
-- @param bDrawingSkybox [Boolean Whether the skybox is being drawn]
-- @param bDrawing3DSkybox [Boolean Whether the 3D skybox is being drawn]
function cwDisplayTyping:PostDrawTranslucentRenderables(bDrawingDepth, bDrawingSkybox, bDrawing3DSkybox)
  if bDrawing3DSkybox or bDrawingDepth then return end
  if !cw.client or !cw.client:HasInitialized() then return end

  -- The `TYPING_*` enums are defined after this file is included.
  typingTexts = typingTexts or {
    [TYPING_WHISPER] = '#TD_Whispering',
    [TYPING_PERFORM] = '#TD_Performing',
    [TYPING_NORMAL] = '#TD_Talking',
    [TYPING_RADIO] = '#TD_Radioing',
    [TYPING_YELL] = '#TD_Yelling',
    [TYPING_OOC] = '#TD_Typing'
  }

  local realEyeAngles = cw.client:EyeAngles()
  local clientPos = cw.client:GetPos()
  local colorWhite = cw.option:GetColor('white')
  local large3D2DFont = cw.option:GetFont('large_3d_2d')
  local talkRadius = config.Get('talk_radius'):Get()

  for k, player in ipairs(playerGetAll()) do
    local typing = player:GetNetVar('Typing')
    local drawText = typing and typingTexts[typing]

    if drawText and player:HasInitialized() and player:Alive() and player:GetMoveType() != MOVETYPE_NOCLIP then
      local fadeDistance = talkRadius

      if typing == TYPING_YELL or typing == TYPING_PERFORM then
        fadeDistance = talkRadius * 2
      elseif typing == TYPING_WHISPER then
        fadeDistance = math.min(talkRadius / 3, 80)
      end

      if player:GetPos():Distance(clientPos) <= fadeDistance and player:GetMaterial() != 'sprites/heatwave'
      and (player:GetColor().a != 0 or player:IsRagdolled()) then
        local alpha = cw.core:CalculateAlphaFromDistance(fadeDistance, cw.client, player)
        local position = hook.Run('GetPlayerTypingDisplayPosition', player)

        if !position then
          local headBone = 'ValveBiped.Bip01_Head1'
          local bonePosition = nil
          local offset = offsetDefault
          local entity = player

          if string.find(player:GetModel(), 'vortigaunt') then
            headBone = 'ValveBiped.Head'
          end

          if player:IsRagdolled() then
            entity = player:GetRagdollEntity()
          end

          if IsValid(entity) then
            local physBone = entity:LookupBone(headBone)

            if physBone then
              bonePosition = entity:GetBonePosition(physBone)
            end
          end

          if player:InVehicle() then
            offset = offsetVehicle
          elseif player:IsRagdolled() then
            offset = offsetRagdoll
          elseif player:Crouching() then
            offset = offsetCrouch
          end

          if bonePosition then
            position = bonePosition + offsetHead
          else
            position = player:GetPos() + offset
          end
        end

        if position then
          local eyeAngles = Angle(realEyeAngles)

          position = position + eyeAngles:Up()
          eyeAngles:RotateAroundAxis(eyeAngles:Forward(), 90)
          eyeAngles:RotateAroundAxis(eyeAngles:Right(), 90)

          cam.Start3D2D(position, Angle(0, eyeAngles.y, 90), 0.04)
            cw.core:OverrideMainFont(large3D2DFont)
            cw.core:DrawInfo(drawText, 0, 0, colorWhite, alpha, nil, nil, 4)
            cw.core:OverrideMainFont(false)
          cam.End3D2D()
        end
      end
    end
  end
end

--- Called when the chat box is closed; tells the server the player stopped typing.
--
-- @param textTyped [Boolean Whether the player sent a message, which plays the faction's end chat noise]
function cwDisplayTyping:ChatBoxClosed(textTyped)
  if textTyped then
    RunConsoleCommand('cwTypingFinish', '1')
  else
    RunConsoleCommand('cwTypingFinish')
  end
end

--- Called when the chat box text changes; tells the server which kind of message the player is typing.
--
-- Runs `cwTypingStart` with a mode code picked from the command prefix (radio, me, pm, w, y), an OOC
-- prefix, or plain text once the message reaches four characters.
--
-- @param previousText [String The chat box text before the change]
-- @param newText [String The chat box text after the change]
function cwDisplayTyping:ChatBoxTextChanged(previousText, newText)
  local prefix = config.Get('command_prefix'):Get()

  if string.utf8sub(newText, 1, string.utf8len(prefix) + 5) == prefix..'radio' then
    if string.utf8sub(previousText, 1, string.utf8len(prefix) + 5) != prefix..'radio' then
      RunConsoleCommand('cwTypingStart', 'r')
    end
  elseif string.utf8sub(newText, 1, string.utf8len(prefix) + 2) == prefix..'me' then
    if string.utf8sub(previousText, 1, string.utf8len(prefix) + 2) != prefix..'me' then
      RunConsoleCommand('cwTypingStart', 'p')
    end
  elseif string.utf8sub(newText, 1, string.utf8len(prefix) + 2) == prefix..'pm' then
    if string.utf8sub(previousText, 1, string.utf8len(prefix) + 2) != prefix..'pm' then
      RunConsoleCommand('cwTypingStart', 'o')
    end
  elseif string.utf8sub(newText, 1, string.utf8len(prefix) + 1) == prefix..'w' then
    if string.utf8sub(previousText, 1, string.utf8len(prefix) + 1) != prefix..'w' then
      RunConsoleCommand('cwTypingStart', 'w')
    end
  elseif string.utf8sub(newText, 1, string.utf8len(prefix) + 1) == prefix..'y' then
    if string.utf8sub(previousText, 1, string.utf8len(prefix) + 1) != prefix..'y' then
      RunConsoleCommand('cwTypingStart', 'y')
    end
  elseif string.utf8sub(newText, 1, 2) == '//' then
    if string.utf8sub(previousText, 1, 2) != '//' then
      RunConsoleCommand('cwTypingStart', 'o')
    end
  elseif string.utf8sub(newText, 1, 3) == './/' then
    if string.utf8sub(previousText, 1, 3) != './/' then
      RunConsoleCommand('cwTypingStart', 'o')
    end
  elseif newText != '' and string.utf8len(newText) >= 4 and previousText != ''
  and string.utf8len(previousText) < 4 then
    RunConsoleCommand('cwTypingStart', 'n')
  end
end
