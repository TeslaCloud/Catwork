--- Server-side code of the `cw_salesman` entity, the NPC a player uses to open a trade menu.
--
-- `ENT:SetupSalesman` sets its networked name and description, its animation and an optional `cw_chatbubble`,
-- `ENT:TalkToPlayer` delivers one of its responses, and `ENT:Use` runs the `PlayerCanUseSalesman` and
-- `PlayerUseSalesman` hooks.

util.Include('shared.lua')

AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

--- Gives the salesman a solid bounding box and makes it usable with a single press.
function ENT:Initialize()
  self:DrawShadow(true)
  self:SetSolid(SOLID_BBOX)
  self:PhysicsInit(SOLID_BBOX)
  self:SetMoveType(MOVETYPE_NONE)
  self:SetUseType(SIMPLE_USE)

  -- A salesman sells and buys nothing until the plugin fills these in after spawning it.
  self.cwCash = -1
  self.cwStock = {}
  self.cwBuyTab = {}
  self.cwSellTab = {}
  self.cwTextTab = {}
  self.cwClasses = {}
  self.cwFactions = {}
end

--- Sets the salesman's networked name and physical description, starts its animation and optionally
-- spawns its chat bubble.
-- @param name [String Name shown in the target ID and in the salesman's lines]
-- @param physDesc [String Physical description shown in the target ID]
-- @param animation [Number Sequence to play; `nil` or `-1` plays sequence 4]
-- @param bShowChatBubble [Boolean Whether to spawn a chat bubble above the salesman]
function ENT:SetupSalesman(name, physDesc, animation, bShowChatBubble)
  self:SetNWString('Name', name)
  self:SetNWString('PhysDesc', physDesc)
  self:SetupAnimation(animation)

  if bShowChatBubble then
    self:MakeChatBubble()
  end
end

--- Sends one of the salesman's responses to a player as a notification and plays its sound.
--
-- The line is prefixed with the salesman's name unless `text.bHideName` is `true`. A response whose
-- `text` is an empty string is not shown, but its sound still plays.
-- @param player [Player The player to talk to]
-- @param text [Map The response, with `text`, `sound` and `bHideName` keys; `nil` says the default line]
-- @param default [String Line to say when the response has no `text`]
function ENT:TalkToPlayer(player, text, default)
  text = text or {}

  local sayString = text.text or default

  if text.bHideName != true then
    sayString = self:GetNWString('Name')..' '..L('Salesman_Says')..' "'..sayString..'"'
  end

  if !text.text or (text.text and text.text != '') then
    cw.player:Notify(player, sayString)
  end

  if text.sound and text.sound != '' then
    netstream.Start(player, 'SalesmanPlaySound', { text.sound, self })
  end
end

--- Plays an animation sequence on the salesman.
-- @param animation [Number Sequence to play; `nil` or `-1` plays sequence 4]
function ENT:SetupAnimation(animation)
  if animation and animation != -1 then
    self:ResetSequence(animation)
  else
    self:ResetSequence(4)
  end
end

--- Spawns a `cw_chatbubble` entity parented to the salesman, 90 units above it.
function ENT:MakeChatBubble()
  self.cwChatBubble = ents.Create('cw_chatbubble')

  if !IsValid(self.cwChatBubble) then return end

  self.cwChatBubble:SetParent(self)
  self.cwChatBubble:SetPos(self:GetPos() + Vector(0, 0, 90))
  self.cwChatBubble:SetNWEntity('salesman', self)
  self.cwChatBubble:Spawn()
end

--- Returns the salesman's chat bubble.
-- @return [Entity The `cw_chatbubble` entity, or `nil` if the salesman has none]
function ENT:GetChatBubble()
  return self.cwChatBubble
end

--- Opens trade with a player who uses the salesman from within 196 units.
--
-- Runs the `PlayerCanUseSalesman` hook and then `PlayerUseSalesman` unless it returned `false`.
function ENT:Use(activator, caller)
  if IsValid(activator) and activator:IsPlayer() then
    if activator:GetEyeTraceNoCursor().HitPos:Distance(self:GetPos()) < 196 then
      if hook.Run('PlayerCanUseSalesman', activator, self) != false then
        hook.Run('PlayerUseSalesman', activator, self)
      end
    end
  end
end
